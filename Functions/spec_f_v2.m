function [ S, cph, ci_u, ci_l, ff, dof ]=spec_f_v2( D, dt, option);
% This is a modified version of Fourier Spectra computation made in 2015.
% The goal is to make it complete and provide information that is needed
% for future writing or whatever
% Input: D: "Scalar" data, in NX1 format. Or in vector form (column vector), using complex
%            D = u + i*v, u and v should be in column vectors
% 
%         dt: Sampling frequency, You need to convert it in hour. For example, if sampling interval is 30 mins,
%             you need to put dt as 0.5 (because 30 mins is 0.5 hour) 
%        option: if 0 then compute raw spectra ( no confidence interval is given and no smoothing).
%                  if 1 is given, then Hanning window will be applied.
%%  update 2017-05-19, use lower DOF and do less smoothing...
%                  Default using 4 segments to do spectrum averaging. 
%                  so DOF = 8
%                  
%                   
% Output: S: Spectral variance in unit of (Data unit)^2/cph
%             If complex input is gigen, then rotary spectra is computed. 
%             S.CW: clockwise component spectra
%             S.CCW: counterclockwise spectra
%          cph: frequency, unit in cycle per hour
%         ci_u: upper level of 95% confidence interval (if you don't like
%         it, you need to modify the code, and change the value "p"
%         ci_l: lower lever of 95% confidence interval
%         ff: fendemental frequency, unit in cycle per hour. This will be
%         used for plotting bandwidth or say, resolution on the figure.
%         dof: degree of freedom. If option is 0, then dof is 2.
%         Ying-Chih Fang Sep-29-2015 @University of Alaska Fairbanks 16:23 AKDT 


D1 = detrend(D,'constant'); % detrend the time series
N = length(D);

%% padding time series with enough zeros, this can reduce noise but won't increase resolution 
%% because of nyquist frequency. Inspired from Torrence and Compo's wavelet package (see their wavelet.m) 
base2 = fix( log(N) / log(2) + 0.4999); % search power of two which is nearest to N
D1 = [ D1; zeros(2^(base2 + 1) - N, 1) ]; % concatenate two "column" vector
length(D1);
N1 = length(D1);

G=abs(fft(D1)).^2;
%ff= 2*pi / N1;% fundemental frequency.Note, this is wrong ! Fundemental
%means the smallest frequency. Which is controled by the length of data. We
%just need to use reciprocal of the length of the data. 

ff= 1 / (N1*dt);% fundemental frequency. Using radian, we say "cycle per hour..."
% this part is important. You need to miltiply dt, because this influences
% the total length of the data and therefore influences the fundemental
% frequency. If you are dealing with non-hourly data instead of using 1 /N1, the spectra will be
% shifted because the fundemental frequency is changed..

%nyq = 2*pi / (2*dt); % Nyquist frequency
nyq = 1 / (2*dt); % Nyquist frequency

f=ff*(1:N1/2);
cph=f';

if option == 0; % compute raw spectra
    if isreal(D) == 1;
S = 2*G(1:N1/2)./N1;
    elseif isreal(D) == 0;
        S.CCW = 2*G(2: N1/2+1)./N1;
        S.CW = 2*G(N1/2+1: end)./N1;
    end
    
dof = 2
ci_u = [];
ci_l = [];

elseif option == 1
seg = 4; % split into 4 segments
%seg = 8; % split into 8 segments, change in 2021-11-08
dof = 2*seg; 

M = round(N1 / seg);  % window length
%
D1s = reshape(D1, M, seg); % create segmented data

%%%% 
S_avg=[];
Sccw_avg=[];
Scw_avg=[];
% scaling factor when using Hanning window, see Data Analysis methods in
% physical oceanography, ver. 2, p 454
sf = (8/3)*(N1 / (0.5*M) );
for i = 1: size(D1s, 2);
    if isreal(D1s) == 1 % for scalar
    Ys = fft(hanning(M).*D1s(:,i));
    Gs = abs(Ys.^2);
    Ss = 2*Gs(2:M/2+1)./M;
    Ss = Ss*sf; % scaling it back when using window...
    S_avg = cat(2, S_avg, Ss);
    
    elseif isreal(D1s) == 0; % for complex data (e.g., u + iv)
    Ys = fft(hanning(M).*D1s(:,i));
    Gs = abs(Ys.^2);
    Sccw = 2*Gs(2:M/2+1)./M;
    Gs = flipdim(Gs, 1); % remember to swap it.now make the negative frequency goes to the front
    Scw = 2*Gs(2: M/2+1)./M;
    Sccw = Sccw*sf; % scaling it back when using window...
    Scw   = Scw*sf; % scaling it back when using window...
    Sccw_avg = cat(2, Sccw_avg, Sccw);
    Scw_avg = cat(2, Scw_avg, Scw);
    end
            
end

%% Doing averaging spectra
if isreal(D1s) == 1 % for scalar
Sm = mean(S_avg, 2) ; %Average all of the segmented spectra

elseif isreal(D1s) == 0; % for complex data (e.g., u + iv)
    Sm.CCW = mean(Sccw_avg, 2) ; %Average all of the segmented spectra
    Sm.CW = mean(Scw_avg, 2) ; %Average all of the segmented spectra
end

%%

% compute confidence interval based on Chi-square distribution. See p. 454,
% using 95% confidence level
ci_l = ( (dof/chi2inv( 1 - 0.05 / 2 , dof))); %lower bound
ci_u = ( (dof/chi2inv( 0.05 / 2, dof ))); %upper bound

S = Sm;
%ff= 2*pi / M;% fundemental frequency. Note, this is wrong.
ff= 1 / (M* dt);% fundemental frequency 
%nyq = 2*pi / (2*dt); % Nyquist frequency
nyq = 1 / (2*dt); % Nyquist frequency
f=ff * (1:M/2);
cph = f';


end