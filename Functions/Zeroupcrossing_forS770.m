function [Ts,Tp,Hs,Hz,Tz] = Zeroupcrossing_forS770(wave,hab,sr)
%{
WROTE BY TING-YU DAI
===========================================================================
        ZERO-UP CROSSING FUNCTION_FOR S770 (PRESSURE-WAVEHEIGHT SENSOR)
            WROTE BY TING-YU DAI
---------------------------------------------------------------------------
        INPUT：
            WAVE：ABSERVED PRESSURE DATA (m or cm)
            HAB：HEIGHT ABOVE BOTTOM (M)
            SR：SAMPLING-FREQUENCY
---------------------------------------------------------------------------
        OUTPUT：
            TS：SIGNIFICANT TIME-PERIOD (T(1/3))
            TP：PEAK-WAVEHEIGHT TIME-PERIOD
            HS：SIGNIFICANT WAVEHEIGHT (H(1/3))
            HZ：ZERO-UP CROSSING WAVEHEIGHT
            TZ：ZERO-UP CROSSING TIME-PERIOD
---------------------------------------------------------------------------

EX.
cd(SINO)
wave = load("2015_09_wave.txt");
hab = 0.3;
sr = 4;

===========================================================================
%}
% RESHAPE TEH WAVE DATA
data = wave(:,3:end);
pres=reshape(data',numel(data),1);

% PICK EVERY BURST 
[a,b]=size(data);
tc=[];
for i=1:a
    tc=[tc;[1:b]'];
end
ig=find(tc == 1);

% MAKE A MATRIX PUT DATA IN
Hs = [];
Ts = [];
Tp = [];
Hz = [];
Tz = [];

% CALCULATE VARIOUS ELEMENTS 
for kk=1:length(ig)
    zs=-nanmean(pres(ig(kk):ig(kk)+1200-1));                    % zs is the vertical position of the pressure sensor        
    h=(-zs)/100.+hab;                                           % h is the water depth; 30 means how many distance senser ABOVE bottom
    press=detrend(pres(ig(kk):ig(kk)+1200-1),'linear');         % Remove a linear trend from a vector, usually for FFT processing.
    [ss]=pres2ss(press, sr, h, hab);                            % Counting Dynamic pressure
    cross = [];
    for ii = 2:length(ss)
        if ss(ii-1) < 0 && ss(ii) >= 0
            cross = [cross; ii];
        end
    end
    height = [];
    for jj = 2:length(cross)
        height(jj-1,1) = max(ss(cross(jj-1):cross(jj)))-min(ss(cross(jj-1):cross(jj),1));
    end
    [height,I] = sort(height,'descend');                        % Arrange data from max to min
    Hs(kk,1) = mean(height(1:floor(length(height)/3)));         % Significant waveheight (H(1/3))
    Hz(kk,1) = mean(height);                                    % All data mean
    period = [];
    for ti = 2:length(cross)
        period(ti-1,1) = (cross(ti)-cross(ti-1))/sr;            % Period/sampling frequency = Time
    end
    period = period(I);
    Ts(kk,1) = mean(period(1:floor(length(period)/3)));
    Tz(kk,1) = mean(period);
    Tp(kk,1) = period(1);                                       % Max-Waveheight's Time-period
end





















