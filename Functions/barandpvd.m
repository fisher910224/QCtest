function barandpvd(ubotm,vbotm,uvbotm,dirbotm,dp_m,daym,loca) 

xbotm=cumsum(ubotm)*3600/100000;   
ybotm=cumsum(vbotm)*3600/100000;

figure
plot(xbotm,ybotm,'k','linewidth',3), axis equal, grid on;

if loca==1;title('PVD,North station');
elseif loca==2;title('PVD,South station');
elseif loca==3;title('PVD');
end;

xlabel('East-West (km)'),     Ylabel('North-South (km)')
text(xbotm(1),ybotm(1),'              start');text(xbotm(length(xbotm)),ybotm(length(ybotm)),'   end');

velrange=-2.5:5:107.5;    angrange=0:22.5:337.5;
for i=1:max(size(dirbotm))

    if(dirbotm(i)>=348.75 & dirbotm(i)<=360);
        dirbotm(i)=dirbotm(i)-360;
    end
end

[n5,x5]=hist(uvbotm,velrange);   [n6,x6]=hist(dirbotm,angrange);
saveas(gcf,'PVD','png');close;
%==========================================================================


figure
subplot(2,1,1)
bar(x5,n5/length(uvbotm)*100,1,'k');
xlabel('speed (cm/s)');ylabel('percent (%)');xlim([0 60]);
if loca==1;title('North station');
elseif loca==2;title('South station');
elseif loca==3;title('bar');
end;

subplot(2,1,2)
bar(x6,n6/length(dirbotm)*100,1,'k');xlim([-10 360]);set(gca,'xtick',[0:90:360]);
xlabel('direction (deg)');ylabel('percent (%)');

saveas(gcf,'speedanddirectionbar','png');close;
%==========================================================================

init_theta=[1 1 1 1 1 1 1 1 1];


data=[(daym*24-mean(daym))' ubotm'];
theta=fminsearch('fun_e1',init_theta,[],data);
u_bot_s=theta;
data=[(daym*24-mean(daym))' vbotm'];
theta=fminsearch('fun_e1',init_theta,[],data);
v_bot_s=theta;

for x=1:27

  k1ubs(x)=u_bot_s(2)*cos(2*pi*x/23.93-u_bot_s(3));
  k1vbs(x)=v_bot_s(2)*cos(2*pi*x/23.93-v_bot_s(3));
  o1ubs(x)=u_bot_s(4)*cos(2*pi*x/25.82-u_bot_s(5));
  o1vbs(x)=v_bot_s(4)*cos(2*pi*x/25.82-v_bot_s(5));
  m2ubs(x)=u_bot_s(6)*cos(2*pi*x/12.42-u_bot_s(7));
  m2vbs(x)=v_bot_s(6)*cos(2*pi*x/12.42-v_bot_s(7));
  s2ubs(x)=u_bot_s(8)*cos(2*pi*x/12.00-u_bot_s(9));
  s2vbs(x)=v_bot_s(8)*cos(2*pi*x/12.00-v_bot_s(9));
end

figure(13)
%subplot(1,2,2)
plot(k1ubs,k1vbs,o1ubs+10,o1vbs,m2ubs+20,m2vbs,s2ubs+30,s2vbs,'linewidth',2,'color','k');axis equal;grid on;
text(0,5,'K1');text(10,5,'O1');text(20,5,'M2');text(30,5,'S2');
text(62,-40,'Bottom');xlabel('speed(cm/s)');ylabel('speed(cm/s)');
axis([-10 35 -15 15]);
if loca==1;title('tidal ellipse, North station');
elseif loca==2;title('tidal ellipse, South station');
elseif loca==3;title('tidal ellipse');
end;
saveas(gcf,'ellipse','png');close;
%==========================================================================


ubotz=ubotm+sqrt(-1)*vbotm;
t_tide(ubotz);

t_tide(dp_m);

%=========================================================================


% 計算各潮型之週期、最大最小流速、流向
ttide = t_tide(ubotz);%利用流速計算k1 01 m2 s2 ( major=5.458  minor=0.777  inc=68.03以k1為例) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(11111);
dep = [0 10 20 30];
% x=[0 30 60 90];
x=[0 10 20 30];

% ellipse(6.206,1.503,80.76/180*pi,x(1),dep(1),'r');axis equal; hold on; % K1 
% ellipse(4.472,-0.059,109.39/180*pi,x(2),dep(1),'b');axis equal; hold on; % O1 
% ellipse(4.283,-0.894,115.79/180*pi,x(3),dep(1),'g');axis equal; hold on; % M2 
% ellipse(2.198,-0.575,111.56/180*pi,x(4),dep(1),'k');axis equal; hold on;grid on% S2 ;grid on;

ellipse(ttide.tidecon(3,1),ttide.tidecon(3,3),ttide.tidecon(3,5)/180*pi,x(1),dep(1),'k');axis equal; hold on; % K1 
ellipse(ttide.tidecon(2,1),ttide.tidecon(2,3),ttide.tidecon(2,5)/180*pi,x(2),dep(1),'k');axis equal; hold on; % O1 
ellipse(ttide.tidecon(4,1),ttide.tidecon(4,3),ttide.tidecon(4,5)/180*pi,x(3),dep(1),'k');axis equal; hold on; % M2 
ellipse(ttide.tidecon(5,1),ttide.tidecon(5,3),ttide.tidecon(5,5)/180*pi,x(4),dep(1),'k');axis equal; hold on;grid on% S2 ;grid on;

text(0,5,'K1');text(10,5,'O1');text(20,5,'M2');text(30,5,'S2');
xlabel('speed(cm/s)');ylabel('speed(cm/s)');
axis([-10 35 -15 15]);
if loca==1;title('tidal ellipse, North station');
elseif loca==2;title('tidal ellipse, South station');
elseif loca==3;title('tidal ellipse');
end;
saveas(gcf,'ellipse_tide','png');close;

% print('-dpng','-r500',['S2站潮流橢圓圖']);
