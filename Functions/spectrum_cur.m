function spectrum_cur(velocity_u,velocity_v,diagramtitle,date)
Fs = 1440/10; % Data Number
nfft = length(velocity_u); % Data length
window = hamming(512); % Spectrum sampling interval
overlap = 512/2; % Repeat sample length

[P_u, Fu] = pwelch(velocity_u*10,window,overlap,nfft,Fs); % 單位要用mm帶入
[P_v, Fv] = pwelch(velocity_v*10,window,overlap,nfft,Fs);

% Counting Main Tide
K1 = find(Fu <= (24/23.93446961));
M2 = find(Fu <= (24/12.42060120));
O1 = find(Fu <= (24/25.81934169));
S2 = find(Fu <= (25/12));

K1a=[Fu(K1(end)) Fu(K1(end))]; % Horizontal position
% K1b=[Fu(K1(end)) Fu(K1(end))+10^5]; % Vertical position
M2a=[Fu(M2(end)) Fu(M2(end))];
% M2b=[Fu(M2(end)) Fu(M2(end))+10^5];
O1a=[Fu(O1(end)) Fu(O1(end))];
% O1b=[Fu(O1(end)) Fu(O1(end))+10^5];
S2a=[Fu(S2(end)) Fu(S2(end))];
% S2b=[Fu(S2(end)) Fu(S2(end))+10^5];

figure('OuterPosition',get(0,'ScreenSize'))
% Spectrum
loglog(Fu,P_u,'b','LineWidth',2); hold on;
loglog(Fv,P_v,'r','LineWidth',2); hold on;

% Main tide
% loglog(K1a,K1b,'k','Linewidth',1);hold on
% loglog(M2a,M2b,'k','Linewidth',1);hold on
% loglog(O1a,O1b,'k','Linewidth',1);hold on
% loglog(S2a,S2b,'k','Linewidth',1);hold on
xline(K1a, 'k', 'LineWidth',1.2);hold on
xline(O1a, 'k', 'LineWidth',1.2);hold on
xline(M2a, 'k', 'LineWidth',1.2);hold on
xline(S2a, 'k', 'LineWidth',1.2);hold on


axis([10^-2 10^2 10^0 10^5]);
set(gca,'FontSize',25);
set(gca,'linewidth',3);

% Mark the  tide
text(O1a(1)-0.2,2*10^4,'O1','FontSize',20,'FontWeight','demi','FontName','標楷體','Color','k');
text(K1a(1),2*10^4,' K1','FontSize',20,'FontWeight','demi','FontName','標楷體','Color','k');
text(M2a(1)-0.4,2.5*10^4,'M2','FontSize',20,'FontWeight','demi','FontName','標楷體','Color','k');hold on;
text(S2a(1),2.5*10^4,'S2','FontSize',20,'FontWeight','demi','FontName','標楷體','Color','k');
hold off;

ylabel('Variance Spectrum [(mm/s)^2/c.p.d]','fontsize',18);
xlabel('Frequency (c.p.d)','fontsize',18);
title(diagramtitle,date,'fontsize',24);

% Confidence Interval
[P,F,Pc] = pwelch(detrend(velocity_u),window,overlap,nfft,Fs,'psd','ConfidenceLevel',0.95,'onesided');
P = P*Fs/2; Pc = Pc*Fs/2;
P_uplim = P+Pc(:,2);
P_lowlim = P-Pc(:,1);
P_idx = F>0 & P>0 & P_uplim>0 & P_lowlim>0;

[Pv,Fv,Pcv] = pwelch(detrend(velocity_v),window,overlap,nfft,Fs,'psd','ConfidenceLevel',0.95,'onesided');
Pv = Pv*Fs/2; Pcv = Pcv*Fs/2;
Pv_uplim = Pv+Pcv(:,2);
Pv_lowlim = Pv-Pcv(:,1);
Pv_idx = Fv>0 & Pv>0 & Pv_uplim>0 & Pv_lowlim>0;

pth = patch([F(P_idx)' fliplr(F(P_idx)')],[P_lowlim(P_idx)' fliplr(P_uplim(P_idx)')],[0 0 1]);
set(pth,'edgecolor','none','FaceAlpha', 0.1);
pthv = patch([Fv(Pv_idx)' fliplr(Fv(Pv_idx)')],[Pv_lowlim(Pv_idx)' fliplr(Pv_uplim(Pv_idx)')],[1 0 0]);
set(pthv,'edgecolor','none','FaceAlpha', 0.1);
legend('u','v','','','','','','');

end