function [percentHsT,percentHsTp] = Vanalyis_wave(Hs,T,Tp,filename1,filename2,filepath)

Waveheight=0:10:200;   Trange=2:1:20;
percentHsT = zeros(13, 17);

% ============= Hs X T ==============
for i=1:1:16
    for j=1:1:12
        g=find(Hs>=Waveheight(i) & Hs<Waveheight(i+1) & T>=Trange(j) & T<Trange(j+1));
        percentHsT(j,i)=100*length(g)/max(size(Hs));     %bivariate statistics
    end
end

for j = 1:12
    ig = find(Hs >= Waveheight(i+1) & T>=Trange(j) & T<Trange(j+1));
    percentHsT(j,i) = percentHsT(j,i)+100*length(ig)/max(size(Hs));
end

for n=1:1:16
    percentHsT(13,n)=sum(percentHsT(:,n));
end

for n=1:1:13
    percentHsT(n,17)=sum(percentHsT(n,:));
end

cd(filepath)
fid3=fopen(filename1,'w');
fprintf(fid3,'%s\n',filename1);
for n=1:1:13
    fprintf(fid3,'%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f \n',percentHsT(n,:));
end

[a,~]=max(Hs);
maxHs = a;  maxT = max(T);meanwaveheight = nanmean(Hs); meanTm02 = nanmean(T);
std_Hs = std(Hs); std_Tm02 = std(T);

fprintf(fid3,'Total mean of Wave height = %8.2f cm		Total mean of Tm02 = %8.2f s\n',meanwaveheight,meanTm02);
% fprintf(fid3,'Total mean of Tm02 = %8.2f s\n',meanTm02);
fprintf(fid3,'Maximum Hs = %8.2f cm   			Maximum Tm02 = %8.2f s\n',maxHs,maxT);
fprintf(fid3,'Standard deviation of Hs = %8.2f cm		Standard deviation of Tm02 = %8.2f s\n',std_Hs,std_Tm02);
% fprintf(fid3,'Standard deviation of Tm02 = %8.2f s\n',std_Tm02);

fclose(fid3);

% ============= Hs X Tp ==============
x = 0;
percentHsTp = zeros(13, 17);
% Tp_N has values >1200, we need to deal with it
for i = 1:length(Tp)
    if Tp(i,1)<20
        Tp(i,1) = Tp(i,1);
    elseif Tp(i,1)>20
        Tp(i,1) = nan;
        x = x+1;
    end
end
for i=1:1:16
    for j=1:1:12
        g=find(Hs>=Waveheight(i) & Hs<Waveheight(i+1) & Tp>=Trange(j) & Tp<Trange(j+1));
        percentHsTp(j,i)=100*length(g)/(max(size(Tp))-x);     %bivariate statistics
    end
end

for j = 1:12
    ig = find(Hs >= Waveheight(i+1) & Tp>=Trange(j) & Tp<Trange(j+1));
    percentHsTp(j,i) = percentHsTp(j,i)+100*length(ig)/(max(size(Tp))-x);
end


for n=1:1:16
percentHsTp(13,n)=sum(percentHsTp(:,n));
end

for n=1:1:13
percentHsTp(n,17)=sum(percentHsTp(n,:));
end

cd(filepath)
fid3=fopen(filename2,'w');
fprintf(fid3,'%s\n',filename2);
for n=1:1:13
fprintf(fid3,'%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f \n',percentHsTp(n,:));
end

[a,b]=max(Hs);
maxHs=a;  maxTp=max(Tp);meanwaveheight=mean(Hs);meanTp=nanmean(Tp);
std_Hs=std(Hs);std_Tp=nanstd(Tp);

fprintf(fid3,'Total mean of Wave height = %8.2f cm		Total mean of Tp = %8.2f s\n',meanwaveheight,meanTp);
% fprintf(fid3,'Total mean of Tp = %8.2f s\n',meanTp);
fprintf(fid3,'Maximum Hs = %8.2f cm   			Maximum Tp = %8.2f s\n',maxHs,maxTp);
fprintf(fid3,'Standard deviation of Hs = %8.2f cm		Standard deviation of Tp = %8.2f s\n',std_Hs,std_Tp);
% fprintf(fid3,'Standard deviation of Tp = %8.2f s\n',std_Tp);

f = fclose(fid3);

% clear min;
