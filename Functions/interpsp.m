function [ffnw,fpnw] = interpsp(ff,fp,n,tail)
%tail加尾段的程式仍在撰寫中
% if  strcmp(tail,'tail')
%     [epeak,pkind] = max(fp);
%     esc = epeak*ff(pkind)^5;  %energy scale
%     
% end
[ff, I, ~] = unique(ff);
fp = fp(I);

csabsdfp = cumsum(abs(diff(fp)));
% csy = csabsdfp(csabsdfp>0);
% csy1 = linspace(csy(1),csy(end),n);

csy = csabsdfp(csabsdfp > 0);
ff_valid = ff(csabsdfp > 0);

% 避免 csy 重複造成 interp1 出錯
[csy_unique, ia] = unique(csy);
ff_valid = ff_valid(ia);

csy1 = linspace(csy_unique(1), csy_unique(end), n);
ff1 = interp1(csy_unique, ff_valid, csy1);

% ff1 = interp1(csy,ff(csabsdfp>0),csy1);
ffnw = unique(sort([ff,ff1]));
fpnw = interp1(ff,fp,ffnw);

