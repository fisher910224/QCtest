function Vanalyis_forQM(ubot,vbot,uvbot,dirbot,filename,filepath)

% uvbot = Cur(:,7)*100;
% dirbot = Dir(:,7);


g=find(dirbot>=348.75 & dirbot<=360);
dirbot(g)=dirbot(g)-360;
vel=0:10:120;   ang=-11.25:22.5:348.75;
percentbot = [9 16];

for i=1:1:8
    for j=1:1:16
        g=find(uvbot>=vel(i) & uvbot<vel(i+1) & dirbot>=ang(j) & dirbot<ang(j+1));
        percentbot(i,j)=100*length(g)/max(size(uvbot));     %bivariate statistics
    end
end

for n=1:1:16
percentbot(9,n)=sum(percentbot(:,n));
end

for n=1:1:9
percentbot(n,17)=sum(percentbot(n,:));
end

cd(filepath)
fid3=fopen(filename,'w');
fprintf(fid3,'%s\n',filename)
for n=1:1:17
    fprintf(fid3,'%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',percentbot(:,n));
end

[a b]=max(uvbot);
maxspeedbot=a;  itsdirectionbot=dirbot(b);meanspeedbot=mean(uvbot);meandirectionbot=mean(dirbot);
mean_ubot=mean(ubot);mean_vbot=mean(vbot);std_ubot=std(ubot);std_vbot=std(vbot);

fprintf(fid3,'Total mean of speed = %8.2f cm/s\n',meanspeedbot);
fprintf(fid3,'Total mean of direction = %8.2f degree\n',meandirectionbot);
fprintf(fid3,'Mean U = %8.2f cm/s   Mean V = %8.2f cm/s\n',mean_ubot,mean_vbot);
fprintf(fid3,'Maximum speed = %8.2f cm/s    Its direction = %8.2f degree\n',maxspeedbot,itsdirectionbot);
fprintf(fid3,'Standard deviation of U = %8.2f cm/s\n',std_ubot);
fprintf(fid3,'Standard deviation of V = %8.2f cm/s\n',std_vbot);

fclose(fid3);


clear min;
