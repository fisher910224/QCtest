function [percentHsT,percentHsDir] = Vanalyis_wave_QM(Hs,T,Dir,dday,filename,filepath)

Waveheight=[0:.2:.8,1:.5:3];
Trange=0:1:10;
percentHsT = zeros(10, 10);

% ============= Hs X T ==============
for i=2:1:10
    for j=4:1:10
        g=find(Hs>=Waveheight(i-1) & Hs<Waveheight(i) & T>=Trange(j) & T<Trange(j+1));
        percentHsT(j-2,i-1)=length(g);     %bivariate statistics
    end
end

for j = 4:1:10
    g=find(Hs>=3 & T>=Trange(j) & T<Trange(j+1));
    percentHsT(j-2,9)=percentHsT(j-2,9)+length(g);     %bivariate statistics
end

for i=2:1:10
    gg = find(Hs>=Waveheight(i-1) & Hs<Waveheight(i) & T<3);
    percentHsT(1,:)=length(gg);     %bivariate statistics
end

percentHsT = 100*percentHsT/length(Hs);

for n=1:10
    percentHsT(10,n)=sum(percentHsT(:,n));
end

for n=1:10
    percentHsT(n,10)=sum(percentHsT(n,:));
end

percentHsT = round(percentHsT, 1);

% ============= Hs X Dir =============
g=find(Dir>=348.75 & Dir<=360);
Dir(g)=Dir(g)-360;
ang=-11.25:22.5:348.75;
percentHsDir = zeros(17, 10);

for i=2:1:10
    for j=1:1:16
        g=find(Hs>=Waveheight(i-1) & Hs<Waveheight(i) & Dir>=ang(j) & Dir<ang(j+1));
        percentHsDir(j,i-1)=length(g);
        % percentHsDir(j,i-1)=100*length(g)/length(Hs);     %bivariate statistics
    end
end

for j = 1:1:16
    g=find(Hs>=3 & Dir>=ang(j) & Dir<ang(j+1));
    percentHsDir(j,9)=percentHsDir(j,9)+length(g);     %bivariate statistics
end
percentHsDir = 100*percentHsDir/length(Hs);

for n=1:10
    percentHsDir(17,n)=sum(percentHsDir(:,n));
end

for n=1:17
    percentHsDir(n,10)=sum(percentHsDir(n,:));
end

percentHsDir = round(percentHsDir, 1);

cd(filepath)
fid3=fopen(filename,'w');
fprintf(fid3,'%s\n',filename);
fprintf(fid3,'Hs vs. T\n');
for n=1:1:10
    fprintf(fid3,'%8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f \n',percentHsT(n,:));
end
fprintf(fid3,'\n');
fprintf(fid3,'\n');
fprintf(fid3,'Hs vs. Dir\n');
for n=1:1:17
    fprintf(fid3,'%8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f \n',percentHsDir(n,:));
end
fprintf(fid3,'\n');

[maxHs, loc_maxHs]=max(Hs);
maxHs_T = T(loc_maxHs);
g=find(Dir<0);
Dir(g)=Dir(g)+360;
position = [
    'N  ';
    'NNE';
    'NE ';
    'ENE';
    'E  ';
    'ESE';
    'SE ';
    'SSE';
    'S  ';
    'SSW';
    'SW ';
    'WSW';
    'W  ';
    'WNW';
    'NW ';
    'NWW'
    ];
[sortedDirprob, loc_Dir_prob] = sort(percentHsDir(1:16,10),'descend');

meanwaveheight=mean(Hs, 'omitmissing');
meanTm02=mean(T, 'omitmissing');

fprintf(fid3, 'H_{max}(m) %28.2f\n', maxHs);
fprintf(fid3, 'H_{max}對應週期(sec) %18.2f\n', maxHs_T);
fprintf(fid3, 'D_{max}(^{circ})/H_{max}對應波向 %8.2f\n', Dir(loc_maxHs));
fprintf(fid3, '最大值發生時間 %20f%s\n',[], datestr(dday(loc_maxHs), 'yyyy/mm/dd HH:MM'));
fprintf(fid3, 'H_{mean}(m) %27.2f\n', meanwaveheight);
fprintf(fid3, 'T_{mean}(sec) %25.2f\n', meanTm02);
fprintf(fid3, '主要波向 %26f%s(%3.1f%%)、%s(%3.1f%%)\n',[], position(loc_Dir_prob(1),:), sortedDirprob(1), position(loc_Dir_prob(2),:), sortedDirprob(2));

fclose(fid3);

