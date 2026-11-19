function [Uw] = SOULSBY_AND_SMALLMANMETHOD(H, T, waterdepth)
%{
===========================================================================
        SOULSBY AND SMALLMANMETHOD
            BY 《SIMPLIFIED CALCULATION OF WAVE ORBITAL VELOCITY-PAGE 10.
            2.5》
        WROTE BY TING-YU DAI
---------------------------------------------------------------------------
        INPUT：

            H：WAVE HEIGHT (m)

            T：PERIOD OF WAVE (s)

            WATERDEPTH：WATERDEPTH (m)

---------------------------------------------------------------------------
        CALCULATING PARAMETERS：

            OMEGA：RADIAN FREQUENCY (Hz)

            K：WAVENUMBER (2*pi/wavelength) (m^-1)

            G：GRAVITY ACCELERATION (m*s^-2)

            TN：NATURAL SCALING PERIOD (s)

            FM_SQRT：DIMENSIONLESS TRANSFER FUNCTION

            X, Y：DIMENSIONLESS VARIABLES

---------------------------------------------------------------------------
        OUTPUT：

            UW：WAVE ORBITAL VELOCITY (m*s^-1)

===========================================================================
ex.
T = Ts;
H = Hs/100;
waterdepth = 16/100;

%}

g = 9.81;
Tn = sqrt(waterdepth./g);
Uw = [];

for i = 1:length(H)
    % DISPERSION RELATION
    [k,lambda] = dpr_nt(T(i),waterdepth(i));
    omega = sqrt(g*k*tanh(k*waterdepth(i)));
    
    % DIMENSIONLESS VARIABLES
    x = omega^2*waterdepth(i)./g;

    if (0 <= x) && (x < 1)
        Fm_sqrt = (1-0.67*x+0.11*x^2)^0.5;
    elseif (1 <= x) && (x < 3.2)
        Fm_sqrt = 1.72*x^0.5*exp(-0.95298*x);
    elseif x >= 3.2
        Fm_sqrt = 2*x^0.5*exp(-x);
    end
    
    % CALCULATING WAVE ORBITAL VELOCITY
    Uw(i,1) = 2*H(i).*Tn(i).*Fm_sqrt./4;
end












