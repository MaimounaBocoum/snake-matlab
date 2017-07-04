%% Algo de r�troprojetction filtr�e
% clear
% load('PressureScan_OP_vis15mm_50V_6MhZ-2017-05-03_17-18.mat')
function [] = RetroProj_cleaned(theta,Proj,SamplingRate)


Proj(1:75,:) = 0;

thetar          = pi*theta/180;
xsonde          = linspace(0,192*0.2,193);
yt              = (0:size(Proj,1)-1)*1540/(SamplingRate)*1000;


FFTt            = fftshift(fft(Proj),1);
f               = linspace(-SamplingRate/(2*1540),SamplingRate/(2*1540),length(yt));
[x,y]           = meshgrid(xsonde,yt);

BPt    =  1.5; %MHz
BP     =  BPt*1e6/1540; %m-1

imgfilt=zeros(length(yt),length(xsonde),length(theta));
FFTtfilt=FFTt;
% LP=ones(1,length(yt));
% LP=abs(sinc(f/(2*BP)));
LP=cos(pi*f/(2*BP));
LP(abs(f)>BP)=0;

for i=1:size(FFTt,2)
    FFTtfilt(:,i) = abs(f)'.*FFTt(:,i).*LP';
end
 
Projfilt=abs(ifft(ifftshift(FFTtfilt,1)));

for i=1:length(theta)
        t = x.*sin(thetar(i)) + y.*cos(thetar(i))...
        -0.5*(1+sign(thetar(i)))*abs(xsonde(end).*tan(thetar(i)))...
        + 0*abs(xsonde(end).*tan(max(theta)*pi/180));
    
    
    projContrib = interp1(yt',Projfilt(:,i),t(:)...
        +abs(xsonde(end).*tan(max(theta)*pi/180)),'linear');
    projContrib(isnan(projContrib))=0;%Projfilt(end,i);
    imgfilt(:,:,i) = reshape(projContrib,length(yt),length(xsonde));
        figure(1)
        imagesc(xsonde,yt,imgfilt(:,:,i))
    drawnow
end

 IMG = sum(imgfilt(:,:,:),3)/size(imgfilt,3);
 figure
 imagesc(IMG)
 title('JB reconstuction script')
end
