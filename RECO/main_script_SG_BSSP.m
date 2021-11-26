% Script illustrating how to reconstruct Bruker datasets acquired with the
% sequence e_SGTFisp
%
% TO DO : add nifti export



%% We use an object to create the parameter for the reconstruction 

param_in = OBJ_SG_BSSFP_RECO; %Without input it will ask for the brucker dataset folder (where fid is located)
% we can also directly give the path if wanted with :
% cellpath{1}='/data/';
% cellpath{2}='/data/';
% param_in = OBJ_SG_BSSFP_RECO(cellpath);

%% Edit the parameter for the reconstruction

%   OBJ_SG_BSSFP_RECO with properties:
% 
%       BRUKER_PATH: {1×4 cell}
%        showFigure: 1
%         SGNPoints: 4 % points used for processing
%             NavCh: 4 % choose the optimal channel to see respiratory motion (check in the first figure of reco)
%             sigma: 10 % gaussian filter
%             sizef: 15 % gaussian filter
%      NavThreshold: 0.0500 % threshold for pick detection
%     RespWindowPos: 30
%     RespWindowNeg: 30

param_in.NavCh=4;

%% Run the reconstruction

s_out = reco_multi_SG_BSSFP(param_in);

figure;imshow(s_out.imSOS(:,:,end/2));

