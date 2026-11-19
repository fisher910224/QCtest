function [tau_c,tau_w,tau_m,tau_max,Uw] = shearstress(Waveheight,Tm02,Waterdepth,new,density,diameter,phi_d,Ubar)
%{
Calculate Shear-stress By Waveheight, Time period and Water depth
By Wilson 2018 EarthSystemSD & Soulsby and Clarke 2005
Writed by Ting-yu Dai

================================= Input ===================================
      Waveheight, Tm02：count by function huang_waveheight (m,s)
      Waterdepth：Sum of Hs after huang_waveheight counting (m)
      new：Kinematic viscosity of seawater (m^2*s^-1)
      density：Seawater density (kg/m^3)
      diameter：Median grain diameter of sediment (m)
      phi_d：Angle between waves and current (degree)
      Ubar：Depth-averaged current speed (m/s)

================================= Output ==================================
      tau_c：Current-alone bed shear-strees (N/m^2)
      tau_w：Wave-alone bed shear-stress amplitude (N/m^2)
      tau_m：Mean wave-plus-current bed shear-stress (N/m^2)
      tau_max：Maximum value of shear-stress  (N/m^2)
      tau_rms：Root-mean-square wave-plus-current bed shear-stress (N/m^2)

---------------------------------------------------------------------------
WORKED EXAMPLE (SMOOTH BED/LAMINAR FLOW)：
Waterdepth = 0.1;
density = 1000;
new = 10^-6;
diameter = 0;
Uw = 0.2;
Tm02 = 10;
Ubar = 0.06;
phi_d = 0;

---------------------------------------------------------------------------
WORKED EXAMPLE (SMOOTH BED/TURBULENT FLOW)：
Waterdepth = 0.4;
density = 1000;
new = 10^-6;
diameter = 0;
Uw = 0.4;
Tm02 = 2;
Ubar = 0.3;
phi_d = 75;

---------------------------------------------------------------------------
WORKED EXAMPLE (ROUGH/TURBULENT FLOW)：
Waterdepth = 5;
density = 1000;
new = 10^-6;
diameter = 0.001;
Uw = 0.7;
Tm02 = 8;
Ubar = 0.5;
phi_d = 90;


---------------------------------------------------------------------------
Waterdepth = 16;
Waveheight = 3;
Tm02 = 6;
Ubar = 0.1393;
new = 10^-6; % kinematic viscosity of seawater
density = 1026; % seawater density 
diameter = 0.03; % median grain diameter of sediment at Howan, 1 mm.
phi_d = 90; % angle between waves and current. At Howan, mostly 90 or 270 degrees.

---------------------------------------------------------------------------
Waterdepth = waterdepth;
Waveheight = Hs;
Tm02 = Tm02;
Ubar = Ubarm;

%}


% Calculate basic parameters
Rec=(Ubar.*Waterdepth)/new;  %current Reynolds number
diameter = max(diameter, 1e-7);
% Tn=sqrt(Waterdepth./9.8); %natural scaling period

% Wave orbital velocity amplitude at seabed
% tpw=(Tn./Tm02);
% Apw=(6500+(0.56+15.54*tpw).^6).^(1/6);
% Uw=0.25*(Waveheight./(Tn.*(1+Apw.*tpw.^2).^3)); 
% [Uw] = SOULSBY_AND_SMALLMANMETHOD(Waveheight,Tm02, Waterdepth);
[Uw,~] = Soulsby_Smallman_Irregular(Waveheight, Tm02, Waterdepth);

A=(Uw.*Tm02)/(2*pi); %wave semi-orbital excursion
Re_w=((Uw.*A)/new); %wave Reynolds number

% Bed roughtness length, z0
z0 = diameter/12;

% Current drag coefficient for smooth flow
CDs = 0.0001615*exp(6*Rec.^-0.08);

% Current drag coefficient for rough flow
CDr = (0.4./(log(Waterdepth./z0)-1)).^2;

% Wave friction factor for smooth flow
fws = 0.0521*Re_w.^-0.187;

% Wave friction factor for rough flow
fwr = 1.39*(A./z0).^-0.52;

Rec_cr = 2000+(5.92*10^5*Re_w).^0.35;
Rew_cr = 1.5*10^5;

for ii = 1:length(Ubar)
    if (Ubar(ii,1) == 0) && (Uw(ii,1) == 0) % No flow
        tau_m(ii,1) = 0;
        tau_max(ii,1) = 0;
        tau_c(ii,1) = 0;
        tau_w(ii,1) = 0;

    elseif (Ubar(ii,1) > 0) && (Uw(ii,1) == 0) % Current-only flow
        if (Rec(ii,1) <= 2000) % laminar
            tau_m(ii,1) = 3*density*new*Ubar(ii,1)/Waterdepth(ii,1);
            tau_max(ii,1) = 3*density*new*Ubar(ii,1)/Waterdepth(ii,1);
            tau_c(ii,1) = tau_m(ii,1);
            tau_w(ii,1) = 0;
        elseif (Rec(ii,1) > 2000) % turbulent
            tau_mr = density*CDr(ii,1)*Ubar(ii,1).^2;
            tau_ms = density*CDs(ii,1)*Ubar(ii,1).^2;
            tau_wr = 0.5*density*fwr(ii,1)*Uw(ii,1).^2;
            tau_ws = 0.5*density*fws(ii,1)*Uw(ii,1).^2;
            tau_m(ii,1) = max(tau_mr,tau_ms);
            tau_max(ii,1) = max(tau_mr,tau_ms);
            tau_c(ii,1) = tau_m(ii,1);
            tau_w(ii,1) = 0;
        end


    elseif (Ubar(ii,1) == 0) && (Uw(ii,1) > 0) % Wave-only flow
        if (Re_w(ii,1) <= 1.5*10^5) % laminar
            tau_m(ii,1) = 0;
            tau_max(ii,1) = density*Re_w(ii,1).^(-0.5)*Uw(ii,1).^2;
            tau_c(ii,1) = tau_m(ii,1);
            tau_w(ii,1) = density*Re_w(ii,1).^(-0.5)*Uw(ii,1).^2;
        elseif (Re_w(ii,1) > 1.5*10^5) % turbulent
            tau_wr = 0.5*density*fwr(ii,1)*Uw(ii,1).^2;
            tau_ws = 0.5*density*fws(ii,1)*Uw(ii,1).^2;
            tau_m(ii,1) = 0;
            tau_max(ii,1) = max(tau_wr,tau_ws);
            tau_c(ii,1) = tau_m(ii,1);
            tau_w(ii,1) = max(tau_wr,tau_ws);
        end

    elseif (Ubar(ii,1) > 0) && (Uw(ii,1) > 0) % Combined wave and current flow
        if (Rec(ii,1) <= Rec_cr(ii,1)) && (Re_w(ii,1) <= Rew_cr) % = laminar flow
            tau_m(ii,1) = 3*(Ubar(ii,1)*density*new)/Waterdepth(ii,1);
            tau_c(ii,1) = tau_m(ii,1);
            tau_w(ii,1) = density*(Re_w(ii,1).^(-0.5))*(Uw(ii,1).^2);
            tau_max(ii,1) = (((tau_m(ii,1)+tau_w(ii,1).*abs(cosd(phi_d)))^2+(tau_w(ii,1)*abs(sind(phi_d)))^2))^0.5;
        elseif (Rec(ii,1) > Rec_cr(ii,1)) || (Re_w(ii,1) > Rew_cr) % turbulent
            Ar = 0.24;
            T1_r = max(Ar*(fwr(ii,1)/2).^(0.5)*A(ii,1)/z0, 12);
            T2_r = Waterdepth(ii,1)./(T1_r*z0);
            T3_r = (CDr(ii,1).^2+(fwr(ii,1)/2).^2.*(Uw(ii,1)./Ubar(ii,1)).^4).^0.25;
            A1_r = T3_r.*(log(T2_r)-1)./(2*log(T1_r));
            A2_r = 0.4*T3_r./log(T1_r);
            CDm_r = ((A1_r.^2+A2_r).^0.5-A1_r).^2;
            CDmax_r = ((CDm_r+T3_r.*Uw(ii,1)./Ubar(ii,1).*(fwr(ii,1)/2).^0.5.*abs(cosd(phi_d))).^2+(T3_r.*Uw(ii,1)./Ubar(ii,1).*(fwr(ii,1)/2).^0.5.*abs(sind(phi_d))).^2).^0.5;
            tau_mr = density*CDm_r*Ubar(ii,1).^2;
            tau_maxr = density*CDmax_r*Ubar(ii,1).^2;

            As = 0.24;
            T1_s = 9*As*Re_w(ii,1).*(fws(ii,1)./2).^(0.5)*(CDs(ii,1).^2*(Ubar(ii,1)./Uw(ii,1)).^4+(fws(ii,1)/2)^2)^(0.25);
            T2_s = (Rec(ii,1)/Re_w(ii,1))*(Uw(ii,1)/Ubar(ii,1))*(1/As)*(2/fws(ii,1)).^0.5;
            T3_s = (CDs(ii,1).^2+(fws(ii,1)/2)^2*(Uw(ii,1)/Ubar(ii,1)).^4)^0.25;
            A1_s = T3_s.*(log(T2_s)-1)./(2*log(T1_s));
            A2_s = 0.4*T3_s./log(T1_s);
            CDm_s = ((A1_s.^2+A2_s).^0.5-A1_s).^2;
            CDmax_s = ((CDm_s+T3_s.*Uw(ii,1)./Ubar(ii,1).*(fws(ii,1)/2).^0.5.*abs(cosd(phi_d))).^2+(T3_s.*Uw(ii,1)./Ubar(ii,1).*(fws(ii,1)/2).^0.5.*abs(sind(phi_d))).^2).^0.5;
            tau_ms = density*CDm_s*Ubar(ii,1).^2;
            tau_maxs = density*CDmax_s*Ubar(ii,1).^2;
            
            tau_m(ii,1) = max(tau_mr,tau_ms);
            tau_max(ii,1) = max(tau_maxr,tau_maxs);
            if diameter == 0
                tau_c(ii,1) = density*CDs(ii,1).*Ubar(ii,1).^2;
                tau_w(ii,1) = 0.5*density*fws(ii,1).*Uw(ii,1).^2;
            elseif diameter > 0
                tau_c(ii,1) = density*CDr(ii,1).*Ubar(ii,1).^2;
                tau_w(ii,1) = 0.5*density*fwr(ii,1).*Uw(ii,1).^2;
            end
        end
    end
end
