function [hs,Tp,Tm02,Tm01,hsw,Tpsw,Tm02sw,Tm01sw,hws,Tpws,Tm02ws,Tm01ws]=mpars1d(ff,fp,fs)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ---+ + + ++
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ---+ + + ++
% Purpose:
% Calculating the mean parameters of swell and wind sea system of frequency
% spectrum
%
% Method:
%
% Parameters :
%   ff      Scale  Frequencies axis of frequency spectrum.
%   fp      Scale  Sectrum density of frequency spectrum.
%   fs      Scale  Seperation frequency of swell and wind sea.
%   hs      Scale  Significant wave height.
%   hsw     Scale  Significant wave height of swell.
%   hws     Sclae  Significant wave height of wind sea.
%   tm      Scale  Mean period.
%   mfsw    Scale  Mean frequency of swell.
%   mfws    Sclae  Mean frequency of wind sea.
%
% 05/25/2012, h.s. chen & c.l. hsu
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ---+ + + ++
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ---+ + + ++
ff = ff(:)';
fp = fp(:)';
nffsw = length(find(ff<fs));
[~,ind]=max(fp);
tp=1/ff(ind);
[hs,Tp,Tm02,Tm01]=cpfs(ff,fp);
if nffsw < 2
    hsw=0;
    Tpsw=1/fs;
    Tm02sw=Tpsw;
    Tm01sw=Tpsw;
    [hws,Tpws,Tm02ws,Tm01ws]=cpfs(ff,fp);
else
    [ff,fp] = interpsp(ff,fp,1000);
    [~,fsind] = min(abs(ff-fs));
    ffsw = ff(1:fsind);
    ffws = ff(fsind+1:end);
    fpsw = interp1(ff,fp,ffsw);
    fpws = interp1(ff,fp,ffws);
    [hsw,Tpsw,Tm02sw,Tm01sw]=cpfs(ff(1:fsind),fp(1:fsind));
    [hws,Tpws,Tm02ws,Tm01ws]=cpfs(ff(fsind+1:end),fp(fsind+1:end));
end
end

function [hs,Tp,Tm02,Tm01]=cpfs(x,y)
% Purpose:
% Calculating the parameters of frequency spectrum
% Parameters :
%   x    : Frequencies axis of frequency spectrum
%   y   : Scale  Sectrum density of frequency spectrum
%   hs   : Scale  Significant wave height
%   Tp   : Scale  wave period of peak period
%   Tm02 : Scale  Mean period of 2nd moment.
%   Tm01 : Scale  Mean period of 1st moment.
f=x(:).';
sp=y(:).';
m0 = trapz(f,sp);
m1 = trapz(f,f.*sp);
m2 = trapz(f,f.^2.*sp);
hs = 4*sqrt(m0);
[~,ind]=max(sp);
fp=f(ind);
Tp=1/fp;
Tm02=sqrt(m0/m2);
Tm01=m0/m1;
end




