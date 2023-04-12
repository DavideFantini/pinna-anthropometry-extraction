function [model] = load_asm_model(cfg)
% This function load the ASM model from the folder
%
% INPUT
%   Required:
%   - cfg: configuration structure
%
% OUTPUT
%   - model: loaded ASM model


    if cfg.verbose >= 1
        disp('Loading ASM model...');
    end

    % GRAY MODEL
    % Load gray model 1
    load([cfg.asm.models_folder 'gray_model_01.mat'], 'gray_model_01');
    load([cfg.asm.models_folder, 'gray_model_01_covmatrix.mat'], ...
        'gray_model_01_covmatrix');
    
    gray_model_01.covMatrix = gray_model_01_covmatrix;

    % Load gray model 2
    load([cfg.asm.models_folder 'gray_model_02.mat'], 'gray_model_02');

    % Load gray model 3
    load([cfg.asm.models_folder 'gray_model_03.mat'], 'gray_model_03');
    
    model.gray_model = [gray_model_01, gray_model_02, gray_model_03];

    % SHAPE MODEL
    load([cfg.asm.models_folder 'shape_model.mat'], 'shape_model');

    model.shape_model = shape_model;


    model.n_landmarks = numel(gray_model_01_covmatrix);

end