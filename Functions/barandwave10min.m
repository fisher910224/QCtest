function barandpvd10min(ubot,vbot,uvbot,dirbot,loca) 

xbotm=cumsum(ubot)*3600/100000/6;   
ybotm=cumsum(vbot)*3600/100000/6;
uvbotm=uvbot;
dirbotm=dirbot;

figure
plot(xbotm,ybotm,'k','linewidth',3), axis equal, grid on;
%title('PVD,South station, 10 min')
%title('PVD,North station, 10 min')
if loca==1;title('PVD,North station, 10 min');
elseif loca==2;title('PVD,South station, 10 min');
elseif loca==3;title('PVD, 10 min');
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

saveas(gcf,'PVD10min','png');close;
%==========================================================================


figure
subplot(2,1,1)
bar(x5,n5/length(uvbotm)*100,1,'k');
xlabel('speed (cm/s)');ylabel('percent (%)');xlim([0 60]);
%title('South station, 10 min')
if loca==1;title('North station, 10 min');
elseif loca==2;title('South station, 10 min');
elseif loca==3;title('10 min');
end;

subplot(2,1,2)
bar(x6,n6/length(dirbotm)*100,1,'k');xlim([-10 360]);set(gca,'xtick',[0:90:360]);
xlabel('direction (deg)');ylabel('percent (%)');

saveas(gcf,'speedanddirectionbar10min','png');close;
%==========================================================================