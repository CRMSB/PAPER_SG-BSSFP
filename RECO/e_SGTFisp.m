% imOut=e_SGTFisp(s)
%
% Author:   Aurélien TROTIER  (a.trotier@gmail.com)
% Date:     2021-11-25
% Partner: none
% Institute: CRMSB (Bordeaux, FRANCE)
%
% Function description:
%       Extract from the FID the image, bruker parameters, k-space and self-gated navitor
%       signal
%
% Input:
%      s_in.
%           BRUKER_PATH ('string') : path to 
%
% Output: 
%       s_out.
%
% Algorithm & bibliography:
%        Ribot EJ, Duriez TJ, Trotier AJ, Thiaudiere E, Franconi J-M, Miraux S.
%        Self-gated bSSFP sequences to detect iron-labeled cancer cells and/or 
%        metastases in vivo in mouse liver at 7 Tesla. 
%        Journal of Magnetic Resonance Imaging 2015;41:1413?1421 doi: 10.1002/jmri.24688.
%
% See also :
%
% TO DO :
%   

function s_out=e_SGTFisp(s_in)

if nargin < 1
    s_in.BRUKER_PATH = uigetdir('*.*','Open rawdata bruker directory');
end



%read params in bruker directory selected
bruk = read_bru_experiment(s_in.BRUKER_PATH);

%%
sx=bruk.method.PVM_EncMatrix(1);
sr = bruk.acqp.ACQ_size(1)/2;
sy = bruk.acqp.ACQ_size(2);

if size(bruk.acqp.ACQ_size) < 3
    sz=1;
else
    sz=bruk.acqp.ACQ_size(3);
end

Nc=bruk.method.PVM_EncNReceivers;

rawData = bruk.fid;
% Remove 0 from data
sizeR2=128*ceil(sr*Nc/128);
rawData=reshape(rawData,sizeR2,[]);
rawData=rawData(1:Nc*sr,:);

rawDataTmp=cell(Nc,1);
for i=1:Nc
    rawDataTmp{i}=double(rawData((i-1)*sr+1:i*sr,:));
end

kdata=zeros(sx,sy,sz,bruk.acqp.NR);

for i=1:Nc
   Nav(:,:,i)=double(rawDataTmp{i}(1:end-sx,:));
   kdata(:,:,:,:,i)=double(reshape(rawDataTmp{i}(end-sx+1:end,:),sx,sy,sz,bruk.acqp.NR));
end

im=fftshift(ifft(ifft(ifft(fftshift(kdata),[],1),[],2),[],3));

im=sqrt(sum(abs(im).^2,5));

%store results
s_out.im = im;
s_out.bruk = bruk;
s_out.kdata = kdata;
s_out.Nav = Nav;
end
