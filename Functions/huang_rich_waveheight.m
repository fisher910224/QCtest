function [wh wt]=huang_rich_waveheight(data,srate,ndata)
temp=data(:,3:end);% 純資料部分
[a,b]=size(temp);
tc=[];
for i=1:a
    tc=[tc;[1:b]'];
end
pres=reshape(temp',numel(temp),1);
% ==================================
ig=find(tc == 1);
%ig(length(ig)+1)=length(tc);

for kk=1:length(ig)
     zs=-nanmean(pres(ig(kk):ig(kk)+1200-1));  % zs is the vertical position of the pressure sensor        
     h=(-zs+30)/100.;                           % h is the water depth
     press=detrend(pres(ig(kk):ig(kk)+1200-1));% Remove a linear trend from a vector, usually for FFT processing.
     [ss]=pres2ss(press, srate, h, 0.3); 
     gage2=ss-mean(ss);
     [wt(kk),wh(kk)]=zeroup(srate,gage2);
end




