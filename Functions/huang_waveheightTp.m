function [Tp,T,Hs]=huang_waveheightTp(data,sr,nfft)
% sr=4;                          % 
% nfft=1024;
win=hann(nfft);
% rho=1025;
g=9.81;

[datalength,datawidth]=size(data);
serialnumber = [1:datawidth-2]';
A=[];
for i=1:datalength
    datanumber = data(i,3:datawidth)';
    aaa=[serialnumber datanumber]; % 橫排取直
    A=[A;aaa];
end

tc=A(:,1);
pres=A(:,2);
ig=find(tc == 1);
% ig(length(ig)+1)=length(tc); %;讓ig創出第553項 不用加1?
pres=pres';
tc=tc';
Hs = NaN(length(ig), 1);
T = NaN(length(ig), 1);
Tp = NaN(length(ig), 1);
for kk=1:length(ig)-1
            zs=-mean(pres(ig(kk):ig(kk+1)), 'omitnan');              % zs is the vertical position of the pressure sensor        
            %h=(-zs+0.3);                      % h is the water depth
            h=(-zs+30)./100;                      % h is the water depth
            press=detrend(pres(ig(kk):ig(kk+1)));
            [ss]=pres2ss(press, sr, h, 0.3); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %[ss]=pres2ss(press, 1/sr, h, 0.1); 
            [psd_eta2,freq]=pwelch(ss,win,nfft/2,nfft,sr);psd(1)=0;psd=psd';
            df=freq(2)-freq(1);             
            S0=nansum(psd_eta2)*df; %書中的m0 page.57
            S2=nansum((freq.^2).*psd_eta2)*df; %書中的m2 page.57
            T(kk,1)=sqrt(S0/S2);%page.61
            [~,ib]=max(psd_eta2);
            Tp(kk,1)=1/max(freq(ib));
            Hs(kk,1)=4*sqrt(nansum(psd_eta2)*df); 

end


function [ss]= pres2ss(pressure, sr, h, hab)
%{
===========================================================================
    CALCULATING OBSERVED PRESS TO DYNAMIC PRESSURE
---------------------------------------------------------------------------
            INPUT：
                PRESSURE：YOUR OBSERVED DATA
                
                SR：SAMPLING FREQUENCY
            
                H：WATERDEPTH
            
                HAB：HEIGHT ABOVE BOTTOM

---------------------------------------------------------------------------
            OUTPUT：
            
                SS：DYNAMIC PRESS
===========================================================================
%}
pressure = pressure(:);
N = length(pressure);
pressure_fft = fft(pressure); % 複立葉轉換

% Generate frequency vector
interval=1/sr;
df = 1/(N*interval);            % frequency interval
fn = 1/(2*interval);
fr = 0:df:(N-1)*df;             % frequency range
frc = fr;
for i = (floor(N/2))+1:N
    frc(i) = 2*fn-frc(i);
end
frc = frc(:);

%------------------------------------
[k,L]=dpr_nt(1./frc,h);
k(1)=0;
% k：wave number
% L：wave length

k=k(:);
tf = cosh(k*h)./cosh(k*hab); % tf = 1/Kp, Kp = cosh(khab)./cosh(kh)

%tf(frc > cf) = 0;
tf(tf > 10) = 0;

% Apply TF to Pressure Spectrum
ss_fft = power(tf,1).*pressure_fft;

% Return real values in the time-domain
ss = real(ifft(ss_fft));



