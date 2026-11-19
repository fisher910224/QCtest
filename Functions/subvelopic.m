function subvelopic(daym,dp_m)
day_i=4;
plot(daym,dp_m,'-','linewidth',2,'color','k');grid on;hold on
ylim([min(dp_m) max(dp_m)]);hold on
axis([floor(min(daym)) ceil(max(daym)) min(dp_m) max(dp_m)])
set(gca,'xtick',[floor(min(daym)):day_i:ceil(max(daym))])
set(gca,'xticklabel',{datestr(floor(min(daym)),6),datestr(floor(min(daym))+4,6),datestr(floor(min(daym))+8,6),datestr(floor(min(daym))+12,6),datestr(floor(min(daym))+16,6),datestr(floor(min(daym))+20,6),datestr(floor(min(daym))+24,6),datestr(floor(min(daym))+28,6),datestr(floor(min(daym))+32,6)}); 
