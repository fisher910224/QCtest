function [T,Hs]=huang_waveheight(data,sr,nfft)
% -------------------------------------------------------------------------------------------
    % This program is wrote by Yu which renew the Huang's
    % If you guys would like to see the old program please search before 104後灣第二季
% -------------------------------------------------------------------------------------------
            % ===================================
            % INPUT：
            % DATA：YOUR OBSERVED DATA
            % SR：SAMPLING FREQUENCY
            % NFFT：NORMAL DISTRIBUTION INTERVAL
            % ===================================
            % OUTPUT：
            % T：PERIOD OF YOUR DATA
            % HS：WAVE HEIGHT OF YOUR DATA
% -------------------------------------------------------------------------------------------

win=hann(nfft); % [常態分布]頻率通常用1024或1200做切割，差不多是20分鐘(1024s≒17min)左右一個Burst
rho=1025; % density (kg/m^3)
g=9.81; % gravity acceleration (kg*m/s^2)


% S770 資料排列方式為 *1   *2   *3   *4...
%                    *101 *102 *103 *104....
temp=data(:,3:end);% 純資料部分
% 資料排列方法======================
% ex. 31 32 33
%     34 35 36
% final. 1 31    
%        2 32
%        3 33
%        1 34
%        2 35
%        3 36
[a,b]=size(temp);
% tc=[];
% for i=1:a
%     tc=[tc;[1:b]'];
% end
tc = repmat((1:1:b), 1, a)';
pres=reshape(temp',numel(temp),1);

% [直轉橫排]reshape(fig,the shape,clo.)
% [nimel(fig)]資料筆數
% ==================================
ig=find(tc == 1);
%ig(length(ig)+1)=length(tc);
Hs = NaN(length(ig), 1);
T = NaN(length(ig), 1);

for kk=1:length(ig)
     zs=-nanmean(pres(ig(kk):ig(kk)+b-1));       % zs is the vertical position of the pressure sensor        
     h=(-zs+30)/100.;                               % h is the water depth; 30 means how many distance senser ABOVE bottom
     press=detrend(pres(ig(kk):ig(kk)+b-1));     % Remove a linear trend from a vector, usually for FFT processing.
     [ss]=pres2ss(press, sr, h, 0.3); 
     [psd_eta2,freq]=pwelch(ss,win,nfft/2,nfft,sr); % psd_eta2 = E{1/2*a^2}
     % psd(1)=0;psd=psd';
     df=freq(2)-freq(1);             
     % psd_eta2(freq>0.8)=NaN;                      % only conisder0-0.8 Hz
     % ----------
     S0=nansum(psd_eta2)*df;                        % 書中的m0 page.57
     S2=nansum((freq.^2).*psd_eta2)*df;             % 書中的m2 page.57
     T(kk,1)=sqrt(S0/S2);                             % 書中的Tm02 page.61
     Hs(kk,1)=4*sqrt(S0);                             % 4*sigma (sigma^2 = m0)
end
    
