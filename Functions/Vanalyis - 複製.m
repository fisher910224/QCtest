function Vanalyis(ubot,vbot,uvbot,dirbot,day)

num=max(uvbot); 
g=find(dirbot>=348.75 & dirbot<=360);
dirbot(g)=dirbot(g)-360;
vel=0:10:120;   ang=-11.25:22.5:348.75;


for i=1:1:6
    for j=1:1:16
        g=find(uvbot>=vel(i) & uvbot<vel(i+1) & dirbot>=ang(j) & dirbot<ang(j+1));
        percentbot(i,j)=100*length(g)/max(size(uvbot));     %bivariate statistics
    end
end

for n=1:1:16
percentbot(7,n)=sum(percentbot(:,n));
end

for n=1:1:7
percentbot(n,17)=sum(percentbot(n,:));
end


fid3=fopen('bot6.out','w');

for n=1:1:17
fprintf(fid3,'%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',percentbot(:,n));
end


ubotm=houravg(ubot,num,6);  
vbotm=houravg(vbot,num,6); 
uvbotm=sqrt(ubotm.^2+vbotm.^2); 
dirbotm=findflowdirection(ubotm,vbotm);
daym=houravg(day,num,6);



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
