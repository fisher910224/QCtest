function subvelopic_uv(daym,ubotm,vbotm,scale2)

scale2=(max([abs(max(vbotm)),abs(min(vbotm))])/8*2)*44/(length(daym)*0.0417);
day_i=4;
y=daym*0;
quiver(daym*scale2,y,ubotm,vbotm,'LineStyle','-','ShowArrowHead','off','Color','k');
axis equal;
axis([floor(min(daym))*scale2,ceil(max(daym))*scale2,min(vbotm),max(vbotm)])
ylim([-abs(floor(min(vbotm))) abs(floor(min(vbotm)))])
set(gca,'xtick',[floor(min(daym))*scale2:scale2*day_i:ceil(max(daym))*scale2])
set(gca,'xticklabel',{datestr(floor(min(daym)),6),datestr(floor(min(daym))+4,6),datestr(floor(min(daym))+8,6),datestr(floor(min(daym))+12,6),datestr(floor(min(daym))+16,6),datestr(floor(min(daym))+20,6),datestr(floor(min(daym))+24,6),datestr(floor(min(daym))+28,6),datestr(floor(min(daym))+32,6)}); 
ylabel('speed (cm/s)');
