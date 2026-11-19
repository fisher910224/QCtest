function Vanalyis(ubot,vbot,uvbot,dirbot,filename,filepath)

%{
ubot = u(:,mid)*100;
vbot = v(:,mid)*100;
uvbot = Cur(:,mid)*100;
dirbot = Dir(:,mid);
filename=[filedate, station,'Lowerlayer_Cur_Dir.txt'];
filepath = f_data

%}
g=find(dirbot>=348.75 & dirbot<=360);
dirbot(g)=dirbot(g)-360;
vel=0:10:200;   ang=-11.25:22.5:348.75;
percentbot = zeros([17 7]);

for ii=1:16
    for jj=1:6
        % g = find(uvbot>=vel(jj) & uvbot<vel(jj+1) & dirbot>=ang(ii) & dirbot<ang(ii+1));
        % % percentbot(ii,jj)=100*length(g)/max(size(uvbot));     %bivariate statistics
        % percentbot(ii,jj) = numel(g);
        if jj == 6
            ig = find(uvbot>=vel(jj+1) & dirbot>=ang(ii) & dirbot<ang(ii+1));
            g = find(uvbot>=vel(jj) & uvbot<vel(jj+1) & dirbot>=ang(ii) & dirbot<ang(ii+1));
            percentbot(ii,jj) = numel(g)+numel(ig);
        else
            g = find(uvbot>=vel(jj) & uvbot<vel(jj+1) & dirbot>=ang(ii) & dirbot<ang(ii+1));
            % percentbot(ii,jj)=100*length(g)/max(size(uvbot));     %bivariate statistics
            percentbot(ii,jj) = numel(g);
        end
    end
end
% sum(sum(percentbot))

percentbot = percentbot/numel(uvbot)*100;

for n=1:16
    percentbot(n,7) = sum(percentbot(n,:));
end

for n=1:7
    percentbot(17,n)=sum(percentbot(:,n));
end

cd(filepath)
fid3=fopen(filename,'w');
fprintf(fid3,'%s\n',filename);
for n=1:1:17
fprintf(fid3,'%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',percentbot(n,:));
end

[a b]=max(uvbot);
maxspeedbot=a;  itsdirectionbot=dirbot(b);meanspeedbot=mean(uvbot, 'omitmissing');meandirectionbot=mean(dirbot, 'omitmissing');
mean_ubot=mean(ubot, 'omitmissing');mean_vbot=mean(vbot, 'omitmissing');std_ubot=std(ubot, 'omitmissing');std_vbot=std(vbot, 'omitmissing');

fprintf(fid3,'Total mean of speed = %8.2f cm/s\n',meanspeedbot);
fprintf(fid3,'Total mean of direction = %8.2f degree\n',meandirectionbot);
fprintf(fid3,'Mean U = %8.2f cm/s   Mean V = %8.2f cm/s\n',mean_ubot,mean_vbot);
fprintf(fid3,'Maximum speed = %8.2f cm/s    Its direction = %8.2f degree\n',maxspeedbot,itsdirectionbot);
fprintf(fid3,'Standard deviation of U = %8.2f cm/s\n',std_ubot);
fprintf(fid3,'Standard deviation of V = %8.2f cm/s\n',std_vbot);

fclose(fid3);


clear min;
