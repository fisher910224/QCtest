function [ss,k,L]= pres2ss_for_wl(pressure, sr, h, hab)
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



