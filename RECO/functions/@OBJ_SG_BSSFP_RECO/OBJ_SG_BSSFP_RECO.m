classdef OBJ_SG_BSSFP_RECO
    %OBJ_SG_BSSFP_RECO class used as input for the function e_SGTFisp
    
    properties
        BRUKER_PATH cell;
        showFigure(1,1) {mustBeMember(showFigure,[0 1])} = 1;
        % Extract self-gated signal
        SGNPoints(1,1) {mustBeInteger, mustBePositive} = 4;
        NavCh(1,1) {mustBeInteger, mustBePositive} = 4;
        
        % gaussian filter for Nav
        sigma(1,1) {mustBeNumeric, mustBeNonnegative} = 10;
        sizef(1,1) {mustBeNumeric, mustBeNonnegative} = 15;
        NavThreshold(1,1) {mustBeNumeric, mustBeNonnegative} = 1/20;
        RespWindowPos(1,1) {mustBeNumeric, mustBeNonnegative} = 30;
        RespWindowNeg(1,1) {mustBeNumeric, mustBeNonnegative} = 30;
        
    end
    methods
        %% constructor
        function obj = OBJ_SG_BSSFP_RECO(path)
            if nargin < 1
                path = uigetfile_n_dir('','Open rawdata bruker directory');
            end
            
            if ischar(path{1})
                obj.BRUKER_PATH = path;
            else
                error("input is not a path to a bruker dataset folder");
            end
            
            %obj.bruk = read_bru_experiment(obj.BRUKER_PATH);
            
        end
        %% methods

    end
end

