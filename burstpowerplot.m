% burstpowerplot - Calculate burst power and plot against time position.
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
%   Annotated 'Lo' for variables related to slow waves components, 'Hi' for variables
%   related to fast waves components and 'burst' for regions with both
%   waves exists
%
%   There are six plot options, only choose 1 at a time to avoid errors.
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
    signalLo = eegfiltfft(EEG.data(channels(ichan),:),EEG.srate,0.5,2);
    signalHi = eegfiltfft(EEG.data(channels(ichan),:),EEG.srate,8,22);

    for(ievent = 1:length(EEG.event))
        % check whether the burst belongs to current channel
        burstname = strcat(EEG.chanlocs(channels(ichan)).labels, '_burst');
        if EEG.event(ievent).type == burstname
            position = [position, EEG.event(ievent).latency];
            duration = [duration, EEG.event(ievent).duration];
            % extract burst and its slow wave component and fast wave
            % component
            burst = EEG.data(channels(ichan),EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);  
            burstLo = signalLo(EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);
            burstHi = signalHi(EEG.event(ievent).latency:EEG.event(ievent).latency+EEG.event(ievent).duration);
            % calculate power and convert to dB
            p = pow2db(bandpower(burst)); % power of orginal burst
            pLo = pow2db(bandpower(burstLo)); % power of slow wave component
            pHi = pow2db(bandpower(burstHi)); % power of fast wave component
            % save the value of power in an array
            powerall = [powerall,p];
            powerlo = [powerlo,pLo];
            powerhi = [powerhi,pHi];
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
   