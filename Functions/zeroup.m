function [period, height]=zeroup(srate,wh)
% zeroup  Zero-up Cross method

j=1;
index = [];
for i=1:length(wh)-1
     if wh(i)<0 & wh(i+1)>=0
        index(j)=i;
        j=j+1;
    end
end

    period=diff(index)./srate;

for i=1:length(index)-1
        shape=wh(index(i):index(i+1));
        height(i)=max(shape)-min(shape);
end
    [height idx]=sort(height);
    %period=period(idx);
    n=length(height);
    height=mean(height(ceil(n*2/3):n));
    %period=mean(period(ceil(n*2/3):n));
    period=mean(period);
    

  
