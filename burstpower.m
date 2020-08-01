% burstpowerPlot - Calculate burst power and plot against position.
% Version: v1.0
% Author: Zitong Li, UCL, 2020
%
% Summary
%   Calculate the power of burst events, power of slow wave components and power of fast wave components. Plot power against time position.   

% Inputs:
%   INEEG      - input dataset
%
% Notes:
%   Burst event needs to be named in the form of Channel Name + '_burst'
%   (eg. 'Cz_burst'). 
%
% Optional inputs:
%   'channels'  - [integer] selected channel(s) {default all}
channels = [1:EEG.nbchan];
%
% Outputs:
%   OUTEEG     - output dataset with update events

for ichan = 1:length(channels)
   %% Calulate power of bursts and power of different frequency components
    position = []; % time position
    powerlo = []; % power of slow wave
    duration =[]; % duration of burst
    powerhi = []; % power of fast wave
    powerall = []; % power of original burst signal
    
    %filter the signal
    signal1 = eegfiltfft(EEG.data(channels(ichan),:),EEG.srate,0.5,2);
    signal2 = eegfiltfft(EEG.data(channels(ichan),:),EEG.srate,0.5,70);

    for(ievent = 1:length(EEG.event))
        % check whether the burst belongs to current channel
        burstname = strcat(EEG.chanlocs(channels(ichan)).labels, '_burst');
        if EEG.event(ievent).type == burstname
            position = [position, EEG.event(ievent).latency];
            duration = [duration, EEG.event(ievent).duration];
            % extract burst
            burst = EEG.data(channels(ichan),EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);
            burst1 = signal1(EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);
            burst2 = signal2(EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);
            % calculata power and convert to dB
            p = pow2db(bandpower(burst));
            p1 = pow2db(bandpower(burst1));
            p2 = pow2db(bandpower(burst2));
            powerall = [powerall,p];
            powerlo = [powerlo,p1];
            powerhi = [powerhi,p2];
        end
    end
    
    %% Plot Option 1: plot power of slow Delta-wave and fast wave against positions, All channels in one figure.        
    hold on
    h = legend('show','location','best');
    set(h,'FontSize',10); 
    plot(position./250,powerlo,'o','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerLo'));
    hold on;
    plot(position./250,powerhi,'*','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerHi'));
    hold on;
    xlabel('position (s)')
    ylabel('power (dB)')
    
     %% Plot Option 2: plot power of slow Delta-wave and fast wave against time positions, Each channel in separeate figures.        
%     figure, hold on
%     h = legend('show','location','best');
%     set(h,'FontSize',10); 
%     plot(position./250,powerlo,'o','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerLo'));
%     hold on;
%     plot(position./250,powerhi,'*','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerHi'));
%     hold on;
%     xlabel('position (s)')
%     ylabel('power (dB)')
%
    %% Plot Option 3: plot power of origianl burst against time positions, All channels in one figure.        
%     hold on
%     h = legend('show','location','best');
%     set(h,'FontSize',10); 
%     plot(position./250,powerall,'o','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerAll'));
%     hold on;
%     xlabel('position (s)')
%     ylabel('power (dB)')
%
     %% Plot Option 4: plot power of delta wave against time positions, All channels in one figure.        
%     hold on
%     h = legend('show','location','best');
%     set(h,'FontSize',10); 
%     plot(position./250,powerlo,'o','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerLo'));
%     hold on;
%     xlabel('position (s)')
%     ylabel('power (dB)')
%   
    %% Plot Option 5: plot power of fast wave against time positions, All channels in one figure.        
%     hold on
%     h = legend('show','location','best');
%     set(h,'FontSize',10); 
%     plot(position./250,powerhi,'*','DisplayName', strcat(EEG.chanlocs(channels(ichan)).labels, '-powerHi'));
%     hold on;
%     xlabel('position (s)')
%     ylabel('power (dB)')
%
    %% Plot Option 6: plot duration of bursts against time positions, All channels in one figure.        
%     hold on
%     h = legend('show','location','best');
%     set(h,'FontSize',10); 
%     plot(position./250,duration,'*','DisplayName',EEG.chanlocs(channels(ichan)).labels);
%     hold on;
%     xlabel('position (s)')
%     ylabel('duration (s)')
%
end

    

        