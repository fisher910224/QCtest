function [Uw,Urms] = Soulsby_Smallman_Irregular(Hs, Tz, h)
%{
===========================================================================
    PARAMETERS：
        Tz：ZERO-CROSSING UP PERIOD (s)

        Hs：SIGNIFICANT WAVE HEIGHT (m)

        h：WATER DEPTH (m)
---------------------------------------------------------------------------
    OUTPUT：
        Uw：WAVE ORBITAL VELOCITY

        Urms：ROOT-MEAN-SQUARE WAVE ORBITAL VELOCITY
===========================================================================
Hs = randi([20 100],10,1)/100;
Tz = randi([50 80],10,1)/10;
h = randi([1600 1800],10,1)/100;

%}
% g = 9.81;
% Urms = [];
% Uw = [];
% for ii = 1:length(Hs)
%     Tn = sqrt(h(ii)/g);
%     t = Tn/Tz(ii);
%     A = (6500+(0.56+15.54*t)^6)^(1/6);
%     Urms(ii,1) = (0.25*Hs(ii))./((1+A*t^2).^3*Tn);
%     Uw(ii,1) = Urms(ii,1).*sqrt(2);
% end

g = 9.81;

% 1. Natural scaling period
Tn = sqrt(h ./ g);

% 2. Dimensionless period
t = Tn ./ Tz;

% 3. Calculate coefficient A (from Soulsby 1997, Eq. 41)
A = (6500 + (0.56 + 15.54 .* t).^6).^(1/6);

% 4. Calculate Urms (Soulsby 1997, Eq. 42)
% NOTE: The exponent is 1.5, not 3.
Urms = (0.25 .* Hs) ./ (Tn .* (1 + A .* t.^2).^1.5);

% 5. Convert to Peak Velocity (Amplitude)
% For irregular waves, the amplitude Uw is often taken as sqrt(2)*Urms
Uw = Urms .* sqrt(2);
