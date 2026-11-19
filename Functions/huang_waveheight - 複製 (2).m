function [T Hs]=huang_waveheight(data,sr,nfft)
% sr=4;                          % 
% nfft=1024;
win=hann(nfft);
rho=1025;
g=9.81;

[aa b]=size(data);
a=[1:b-2]';
A=[];
for i=1:aa
    aa=data(i,3:b)';
    aaa=[a aa];
    A=[A;aaa];
end

tc=A(:,1);
pres=A(:,2);
%X=[A H];
% fpath='G:\曾老師資料\huang\';
% outdir='G:\曾老師資料\huang\';
% f=dir([fpath 'F*.txt']);
% tc=[];pres=[];fa=[];
% 
% for xx=1:length(f); 
%     eval(['load ',f(xx).name]);
%     Nam=f(xx).name(1:end-4);
%     eval(['tc0=',Nam,'(:,1)']);
%     eval(['pres0=',Nam,'(:,2)']);
% %     eval(['f0=',Nam,'(:,7)']);
%     tc=[tc;tc0];
%     pres=[pres;pres0];
% %     fa=[fa;f0];
% end
ig=find(tc == 1);
ig(length(ig)+1)=length(tc); %;讓ig創出第553項 不用加1?
pres=pres';
tc=tc';
%fa=fa';
%tc=[];pres=[];
% for ii=1:length(ig)-1
%     tcc=ii
%     pr=mean(press(ig(ii):ig(ii+1)));
%     tc=[tc tcc];
%     pres=[pres pr];
% end    
%Hs_nor=fa;%Hs=[];
for kk=1:length(ig)-1
%         tc=0;
%         pres=[];
%         for i=1:10000
%         data1 = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', [18 1]) ;
%         if (data1(2)-tc(end))<0
%             break
%         end
%         tc = [tc data1(2)];
%         pres=[pres data1(15)];
%         clear data1;
%         end
        %tc(1)=[];
        %------------------------
        %nc=length(pres(ig(kk):ig(kk+1)));
        %if nc >4*32*60
            zs=-nanmean(pres(ig(kk):ig(kk+1)));              % zs is the vertical position of the pressure sensor        
            %h=(-zs+0.3);                      % h is the water depth
            h=(-zs+30)./100;                      % h is the water depth
            press=detrend(pres(ig(kk):ig(kk+1)));
            [ss]=pres2ss(press, sr, h, 0.3); 
             %[ss]=pres2ss(press, 1/sr, h, 0.1); 
            [psd_eta2,freq]=pwelch(ss,win,nfft/2,nfft,sr);psd(1)=0;psd=psd';
            df=freq(2)-freq(1);             
            %psd_eta2(freq>0.8)=NaN;         % only conisder0-0.8 Hz
            %----------
            
            S0=nansum(psd_eta2)*df; %書中的m0 page.57
            S2=nansum((freq.^2).*psd_eta2)*df; %書中的m2 page.57
            T(kk)=sqrt(S0/S2);%page.61
            Hs(kk)=4*sqrt(nansum(psd_eta2)*df); 
%             Hs=[Hs Hss];
        %end
        %disp(kk)
end
% %save Hs
% hh=[[1:1:1082]' Hs' T'];
% save -ascii 201307hh.txt hh;
% %hh=load ('201301h.txt');
% clear all;close all
% h1=load ('201307h.txt');
% h2=load ('201307hh.txt');
% figure(1)
% %xx=1:1:length(wh);
% subplot(2,1,1)
% h3=plot(1:1082,h1(:,2),'LineWidth',2,'color',[0,0,1]);hold on
% h4=plot(1:1082,h2(:,2),'LineWidth',2,'color','r');hold on
% ylim([0 300]);
% xlabel('')
% ylabel('H 1/3(cm)')
% 
% subplot(2,1,2)
% plot(1:1082,h1(:,3),'LineWidth',2,'color',[0,0,1]);hold on
% plot(1:1082,h2(:,3),'LineWidth',2,'color','r');hold on
% ylim([0 15]);
% ylabel('T (sec)')
% xlabel('time series')
% legend([h3 h4],'1/3','spectrum')
% saveas(gcf,'波高比較_201307','png');close;



% figure(111);
%    
% subplot(3,1,1);
% plot(1:1081,Hs(1:1081),'LineWidth',2,'color',[0,0,1]);hold on
% subplot(3,1,2);
% plot(1:1081,T(1:1081),'LineWidth',2,'color',[0,0,1])
% 
% ylim([0 60])
% xlabel('time-scale (every 20mins)','fontsize',16);
% ylabel('Wave height (m)','fontsize',16);
% 
% a=1:1:1277;
% A=[a' Hs' T'];
% save -ascii 201301h.txt A;


















