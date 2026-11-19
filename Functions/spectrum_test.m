function spectrum_test(velocity_u,velocity_v,vel_u_perhour,vel_v_perhour,station)
% edit by Yu 2015/9/9
% This function is for Howan project.(Only affect the direction of figures)
% This function is used to calculate u,v velocity spectrum respectively.
% The four figure we got can compare the difference between whole and
% hour average data.

u=velocity_u;
v=velocity_v;

Fs = 6/60; 
nfft = length(u); 
window = hamming(128); 
overlap = 64/2;


[P_u, Fu] = psd(u,nfft,Fs,window,overlap);

figure
loglog(Fu,P_u,'k','LineWidth',2);hold on;%grid on;
ig=find(Fu <= (1/(60*24)));
ig2=find(Fu <= (1/(60*12)));
h=loglog(Fu(ig(end)),P_u(ig(end))+10^3,'kv',Fu(ig2(end)),P_u(ig(end))+10^3,'kv');hold on
a=[Fu(ig(end)) Fu(ig(end))];
b=[Fu(ig(end)) Fu(ig(end))+10^5];
a1=[Fu(ig2(end)) Fu(ig2(end))];
b1=[Fu(ig2(end)) Fu(ig2(end))+10^5];

loglog(a,b,'k','Linewidth',1);
loglog(a1,b1,'k','Linewidth',1);
axis([10^-5 10^-1 10^0 10^5]);

set(h(1), 'MarkerFaceColor','k','MarkerSize',8);
text(Fu(ig(end)),P_u(ig(end))+10^4,'D','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
set(h(2), 'MarkerFaceColor','k','MarkerSize',8);
text(Fu(ig2(end)),P_u(ig(end))+10^4,'SD','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
hold off;
ylabel('Variance Spectrum [(cm/s)^2/c.p.10min]','fontsize',14);xlabel('Frequency (c.p.10min)');
title('U, 10 min','fontsize',16)
eval(['saveas(gcf,','''result\',station,'\line_k_U_min''',',''png'')']);close


[P_v, Fv] = psd(v,nfft,Fs,window,overlap);

figure
loglog(Fv,P_v,'k','LineWidth',2);hold on%grid on;
ig=find(Fv <= (1/(60*24)));
ig2=find(Fv <= (1/(60*12)));
h=loglog(Fv(ig(end)),P_v(ig(end))+10^3,'kv',Fv(ig2(end)),P_v(ig(end))+10^3,'kv');
a=[Fv(ig(end)) Fv(ig(end))];
b=[Fv(ig(end)) Fv(ig(end))+10^5];
a1=[Fv(ig2(end)) Fv(ig2(end))];
b1=[Fv(ig2(end)) Fv(ig2(end))+10^5];

loglog(a,b,'k','Linewidth',1);
loglog(a1,b1,'k','Linewidth',1);
axis([10^-5 10^-1 10^0 10^5]);
set(h(1), 'MarkerFaceColor','k','MarkerSize',8);
text(Fv(ig(end)),P_v(ig(end))+10^4,'D','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
set(h(2), 'MarkerFaceColor','k','MarkerSize',8);
text(Fv(ig2(end)),P_v(ig(end))+10^4,'SD','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
hold off;
ylabel('Variance Spectrum [(cm/s)^2/c.p.10min]','fontsize',14);xlabel('Frequency (c.p.10min)');
title('V, 10 min','fontsize',16)
eval(['saveas(gcf,','''result\',station,'\line_k_V_min''',',''png'')']);close

%==========================================================================


U=vel_u_perhour;
V=vel_v_perhour;


fs = 1; 
n_fft = length(U); 
windows = hamming(64); 
overlaps = 32/2;


[P_U, FU] = psd(U,n_fft,fs,windows,overlaps);

figure
loglog(FU,P_U,'k','LineWidth',2);hold on;%grid on;
ig=find(FU <= (1/24));
ig2=find(FU <= (1/12));
h=loglog(FU(ig(end)),P_U(ig(end))+10^3,'kv',FU(ig2(end)),P_U(ig(end))+10^3,'kv');
a=[FU(ig(end)) FU(ig(end))];
b=[FU(ig(end)) FU(ig(end))+10^5];
a1=[FU(ig2(end)) FU(ig2(end))];
b1=[FU(ig2(end)) FU(ig2(end))+10^5];
loglog(a,b,'k','Linewidth',1);
loglog(a1,b1,'k','Linewidth',1);
axis([10^-3 10^0 10^-1 10^5]);
set(h(1), 'MarkerFaceColor','k','MarkerSize',8);
text(FU(ig(end)),P_U(ig(end))+10^4,'D','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
set(h(2), 'MarkerFaceColor','k','MarkerSize',8);
text(FU(ig2(end)),P_U(ig(end))+10^4,'SD','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
hold off;
ylabel('Variance Spectrum [(cm/s)^2/c.p.h]','fontsize',14);xlabel('Frequency (c.p.h)');
title('U','fontsize',16),
eval(['saveas(gcf,','''result\',station,'\_line_k_U_h''',',''png'')']);close


[P_V, FV] = psd(V,n_fft,fs,windows,overlaps);

figure
loglog(FV,P_V,'k','LineWidth',2);hold on%grid on;
ig=find(FV <= (1/24));
ig2=find(FV <= (1/12));
h=loglog(FV(ig(end)),P_V(ig(end))+10^3,'kv',FV(ig2(end)),P_V(ig(end))+10^3,'kv');
a=[FV(ig(end)) FV(ig(end))];
b=[FV(ig(end)) FV(ig(end))+10^5];
a1=[FV(ig2(end)) FV(ig2(end))];
b1=[FV(ig2(end)) FV(ig2(end))+10^5];

loglog(a,b,'k','Linewidth',1);
loglog(a1,b1,'k','Linewidth',1);
axis([10^-3 10^0 10^-1 10^5]);
set(h(1), 'MarkerFaceColor','k','MarkerSize',8);
text(FV(ig(end)),P_V(ig(end))+10^4,'D','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
set(h(2), 'MarkerFaceColor','k','MarkerSize',8);
text(FV(ig2(end)),P_V(ig(end))+10^4,'SD','FontSize',12,'FontWeight','demi','FontName','標楷體','Color','k');
hold off;
ylabel('Variance Spectrum [(cm/s)^2/c.p.h]','fontsize',14);xlabel('Frequency (c.p.h)');
title('V','fontsize',16),
eval(['saveas(gcf,','''result\',station,'\_line_k_V_h''',',''png'')']);close