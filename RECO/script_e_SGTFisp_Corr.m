%% script e_SGTFisp
%% read bruker data
s_out=e_SGTFisp();

%% Parameters for SG filtering
SGNPoints = 4;
NavCh = 4;

% gaussian filter for Nav
sigma =10;
sizef = 15;
NavThreshold = 1/20;

% Respiratory window
RespWindowPos = 30; % number of points removed after peak
RespWindowNeg = 30; % number of points removed before peak
%% Processing of self-gating navigator signal
if(length(size(s_out.Nav))==2)
    y=abs(sum(double(Nav(1:SGNPoints,:)),1)); % When only 1 channel
else
    y=abs(sum(double(s_out.Nav(1:SGNPoints,:,NavCh)),1)); %Number of points used for SG signal
end
y=1./y;

% Filtre gaussien appliquée aux données
x = linspace(-sizef / 2-1, sizef / 2, sizef);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

yfilt = conv (y, gaussFilter,'same');

T = s_out.bruk.method.PVM_RepetitionTime/1000;                     % Sample time
Fs = 1/T;                    % Sampling frequency
L = length(y);                     % Length of signal
t = (0:L-1)*T;                % Time vector


idxECG=peakfinder(yfilt/max(yfilt),NavThreshold);

figure;plot(t,y);hold on;
plot(t,yfilt,'r');
plot(t(idxECG),yfilt(idxECG),'or');
title('Signal');
xlabel('time (seconds)');

%% Suppression 1er pick
idxECG(1)=[];
%idxECG(1)=[];
idxECG(end)=[];

%% Remove motion corrupted lines
idxLinePos=idxECG+RespWindowPos;
idxLineNeg=idxECG-RespWindowNeg;

idxWindow=[];
for i=1:length(idxLineNeg)
    idxWindow=[idxWindow idxLineNeg(i):idxLinePos(i)];
end


idxLine=[idxLineNeg idxLinePos];
idxLine(idxLine < 1)=[];

figure;hax=axes;
plot(t,y);hold on;
plot(t,yfilt,'r');
plot(t(idxECG),yfilt(idxECG),'or');
title('Signal');
xlabel('time (seconds)');

line([t(idxLine)' t(idxLine)'],get(hax,'YLim'),'Color',[0 1 1])

%%
kdata2=reshape(s_out.kdata,s_out.bruk.method.PVM_Matrix(1),[],s_out.bruk.method.PVM_EncNReceivers);

for i=1:length(idxWindow)
    kdata2(:,idxWindow(i),:)=nan;
end

kdata2=reshape(kdata2,size(s_out.kdata));

mask=kdata2;
mask(~isnan(mask))=1;
mask(isnan(mask))=0;
mask=sum(mask,4);

sum(mask(:)==0)/length(mask(:))*100     % Percentage of lines with 0
mask(mask==0)=1;


kdata3=kdata2;
kdata3(isnan(kdata3))=0;
kdata3=sum(kdata3,4)./mask;



imCor=fftshift(ifft(ifft(ifft(fftshift(kdata3),[],1),[],2),[],3));
imCor4=sqrt(sum(abs(imCor).^2,5)); % edit the name accordingly

%% SOS if multiples acquisition with offsets are performed 

imCorTot=sqrt(imCor1.^2+imCor2.^2+imCor3.^2+imCor4.^2);
imagine(imCorTot);

