% burstdetect - detect burst events in each channel
% Version: v1.0
% Author: Zitong Li, UCL, 2020
%
% Summary
%   Detect burst actvities in each channel based on the ovelapping of slow
%   waves and fast waves. Both waves are identified by applying
%   amplitude-thresholding method to band-passed slowfrequency component
%   and band-passed fast frequency component. 

% Inputs:
%   INEEG      - input dataset
%
% Optional inputs:
%   'channels'  - [integer] selected channel(s) {default all}
channels = [1:EEG.nbchan];
%   'threshold' - [float] wave detection threshold in standard deviation
%                of the RMS of the selected channel {default 1.5}
threshold = 1.5;
%   'rmswinLo'    - [min max] window limit in seconds for applying
%                 root-mean-square transformation to slow frequency component.
%                 Window size should cover one or more complete cycles
%                 {default [-1 1]}.
rmswinLo = [-1 1];
%   'rmswinHi'    - [min max] window limit in seconds for applying
%                 root-mean-square transformation to fast frequency component
%                 Window size should cover one or more complete cycles
%                 {default [-0.2 0.2]}.
rmswinHi = [-0.2 0.2];
%   'eventwin'    - [min max] window limit for burst. The signal must be
%                 above 'threshold' for at least 'min' second and at most 'max' seconds.
%                 {default [0.5 5]}
eventwin = [0.5 5];
%   'eventname'    - [string] general event name. This script would automatically
%                  name each event as '(Channel Name) + '_' + eventname' (eg. Cz_burst)
%                 {default 'burst'}.  
eventname = 'burst';
%
% Outputs:
%   OUTEEG     - output dataset with update events 

for iChan = 1:length(channels)
    
    for iepoch = 1:EEG.trials
        
        %look for slow waves and fast waves
        
        % initialize waveThresh to zeros/FALSE (indicate the exisitance of slow
        % wave
        % or fast wave)
        waveThreshLo = zeros(1, EEG.pnts);
        waveThreshHi = zeros(1, EEG.pnts);
        
        
        % filter data to 0.5-2 Hz slow frequency component and 8-22 Hz fast
        % frequency component
        sigLo = eegfiltfft(EEG.data(channels(iChan),:,iepoch),EEG.srate,0.5,2);
        sigHi = eegfiltfft(EEG.data(channels(iChan),:,iepoch),EEG.srate,8,22);
        % compute RMS value using sliding window method for slow frequency
        % component
        windowLo = round(EEG.srate*rmswinLo);
        winSamplesLo = [windowLo(1):windowLo(2)];
        rmsMoveAvLo = zeros(1, EEG.pnts);
        for iSample = 1+windowLo(2):EEG.pnts+windowLo(1)-1
            rmsMoveAvLo(iSample) = rmsave(sigLo(1, iSample+winSamplesLo));
        end
        % compute RMS value using sliding window method for fast frequency
        % component
        windowHi = round(EEG.srate*rmswinHi);
        winSamplesHi = [windowHi(1):windowHi(2)];
        rmsMoveAvHi = zeros(1, EEG.pnts);
        for iSample = 1+windowHi(2):EEG.pnts+windowHi(1)-1
            rmsMoveAvHi(iSample) = rmsave(sigHi(1, iSample+winSamplesHi));
        end
        % compute amplitude threshold for each signals
        thresholdLo = std(rmsMoveAvLo)*threshold;
        thresholdHi = std(rmsMoveAvHi)*threshold;
        % update waveThresh to one/TRUE if RMS is above threshold in each
        % signal
        waveThreshLo = waveThreshLo | rmsMoveAvLo > thresholdLo;
        waveThreshHi = waveThreshHi | rmsMoveAvHi > thresholdHi;
        
        
        %look for bursts regions (overlapping of slow and fast waves)
        
        burstLowLimits = round(EEG.srate*eventwin(1));
        burstHiLimits = round(EEG.srate*eventwin(2));
        continuousAboveTheshold = 0;
        onsetBurst = 0;
        for iSample = 1:EEG.pnts
            % check if slow wave and fast waves coexist
            if waveThreshLo(iSample) & waveThreshHi(iSample)
                offsetBurst = 0;
                continuousAboveTheshold = continuousAboveTheshold+1;
            else
                offsetBurst = iSample;
                continuousAboveTheshold = 0;
            end
            % check if above event low limit
            if continuousAboveTheshold > burstLowLimits
                onsetBurst = iSample-continuousAboveTheshold;
            end
            
            if onsetBurst ~= 0 && offsetBurst ~= 0
                % you have a burst
                % set event name and time
                EEG.event(end+1).type = strcat(EEG.chanlocs(channels(iChan)).labels, '_', eventname);
                EEG.event(end).latency = onsetBurst + EEG.pnts* (iepoch-1);
                EEG.event(end).duration = offsetBurst-onsetBurst;
                onsetBurst = 0;
                offsetBurst = 0;
            end
        end
        
    end
end

% resort events
[~,ind] = sort([EEG.event.latency]);
EEG.event = EEG.event(ind);
