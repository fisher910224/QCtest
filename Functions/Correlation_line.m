function Correlation_line(ax,X,Y,x_txtLocation,y_txtLocation)
h = lsline(ax);
% slope = polyfit(log(X),log(Y),1);
slope = polyfit(X,Y,1);
% y = X.^slope(1).*exp(slope(2));
% h = plot(X,y,'linewidth',3,'linestyle',':','color',[0.8 0.8 0.8]);
txt_d = ['y=',num2str(slope(1)),'x+(',num2str(slope(2)),')'];
set(h,'linewidth',3,'linestyle','--')
leg = legend(txt_d);
leg.FontSize = 10;

% [R,P] = corrcoef(log(X),log(Y));
[R,P] = corrcoef(X,Y);
R2 = R(1,2)*R(2,1); 
txt_R = {['R^2=',num2str(R2)]};
text(x_txtLocation,y_txtLocation,txt_R,"FontSize",18)




