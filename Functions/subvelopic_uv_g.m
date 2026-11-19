function subvelopic_uv_g(daym,ubotm,vbotm,scale2)

%scale2=28;
day_i=4;
y=daym*0;
%quiver(daym*scale2,y,ubotm,vbotm,0,'.','k');axis equal;
quiver(daym*scale2,y,ubotm,vbotm,0,'.','color',[0 0 0]/255);axis equal;
axis([floor(min(daym))*scale2 ceil(max(daym))*scale2 min(vbotm) max(vbotm)])
for ii=-10:1:20
line([0 ceil(max(daym))],[20*ii 20*ii],'color','k','LineWidth',0.1)
end
set(gca,'xtick',[min(daym)*scale2:scale2*day_i:max(daym)*scale2])
set(gca,'xticklabel',{datestr(floor(min(daym)),6),datestr(floor(min(daym))+4,6),datestr(floor(min(daym))+8,6),datestr(floor(min(daym))+12,6),datestr(floor(min(daym))+16,6),datestr(floor(min(daym))+20,6),datestr(floor(min(daym))+24,6),datestr(floor(min(daym))+28,6),datestr(floor(min(daym))+32,6),datestr(floor(min(daym))+36,6),datestr(floor(min(daym))+40,6)},'fontsize',12); 
ylabel('speed (cm/s)');


