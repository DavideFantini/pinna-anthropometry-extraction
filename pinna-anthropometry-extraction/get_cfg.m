function [cfg] = get_cfg()                             
% This function returns the configuration structure that defines the
% behaviour of the code in the repository.
%
% OUTPUT
%   - cfg: configuration structure


    cfg = struct;
    
    % ============================== GENERAL ============================ %
    cfg.mat_version = '-v7.3';
    % 0: no verbose - 1: minor verbose - 2: complete verbose
    cfg.verbose = 2;


    % Size of the images used to train the ASM model
    cfg.img_width = 140;
    cfg.img_height = 160;
    

    % ============================= LANDMARKS =========================== %
    % Number of landmarks used to train the ASM model
    cfg.landmarks.n_landmarks = 167;
    cfg.landmarks.n_coordinates = 3;
    cfg.landmarks.x_coordinate_idx = 1;
    cfg.landmarks.y_coordinate_idx = 2;
    cfg.landmarks.z_coordinate_idx = 3;

    % Landmarks' indices of the pinna parts
    cfg.landmarks.pinna_parts_idx = {1:47, 48:115, 116:133, 134:167};
    % Names of the pinna parts
    cfg.landmarks.pinna_parts_names = {'Outer Helix', 'Concha', ...
        'Triangular Fossa', 'Inner Helix'};


    % ================================ ASM ============================== %
    cfg.asm.models_folder = 'models/';

    % Number of ASM iterations. It can be a scalar or a vector of 2 
    % elements representing the starting and the ending number of ASM 
    % iterations for the 3 image resolutions evaluated by ASM
    cfg.asm.evolutions = [5 5];
    % Search length (in pixels). It can be a scalar or a vector of 2 
    % elements representing the starting and the ending search sizes for
    % the 3 image resolutions evaluated by ASM
    cfg.asm.search_sizes = [4 2];
    % Distance metric used for measuring accuracy of shifted profiles. It 
    % can be 'pca' or 'maha' (Mahalanobis)
    cfg.asm.dist_metric = 'pca';
    % Number of principal components considered by ASM
    cfg.asm.n_pcs = 10;
    % Normal contour, limit to +- m*sqrt(eigenvalue)
    cfg.asm.m = 0.005;

    % Whether to visualize the fitting plot
    cfg.asm.visualize_fitting = true;


    % =========================== ANTHROPOMETRY ========================= %
    % Pair of landamrks indices used to measure the specified anthropometry
    cfg.anthropometry.measurement_landmarks_pairs = struct;
    cfg.anthropometry.measurement_landmarks_pairs.d1 = [56 75];
    cfg.anthropometry.measurement_landmarks_pairs.d2 = [56 106];
    cfg.anthropometry.measurement_landmarks_pairs.d3 = [67 92];
    cfg.anthropometry.measurement_landmarks_pairs.d4 = [106 167];
    cfg.anthropometry.measurement_landmarks_pairs.d7 = [70 78];
    cfg.anthropometry.measurement_landmarks_pairs.d11 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d12 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d13 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d14 = [67 86];
    cfg.anthropometry.measurement_landmarks_pairs.d15 = [67 99];
    cfg.anthropometry.measurement_landmarks_pairs.d16 = [67 106];
    cfg.anthropometry.measurement_landmarks_pairs.d17 = [115 134];
    cfg.anthropometry.measurement_landmarks_pairs.d18 = [116 133];
    cfg.anthropometry.measurement_landmarks_pairs.d19 = [154 129];
    cfg.anthropometry.measurement_landmarks_pairs.d20 = [154 125];
    cfg.anthropometry.measurement_landmarks_pairs.d21 = [154 121];

    % Landmark's index used as initial estimated position of the tragus
    cfg.anthropometry.tragus_landmarks_idx = 67;

    % Names of the anthropometry
    cfg.anthropometry.metrics_name = {...
        'd1','d2','d3','d4','d5','d6','d7','d8','d9',...
        't1','t2',...
        'd14','d15','d16','d17','d18','d19','d20','d21',...
        'a1','a2','a3',...
        'd11','d12','d13',...
        'v1','v2','v3',...
        'h1','h2','h3',...
        'r1','r2','r3','r4','r7','r11','r12','r13','r14','r15','r16','r17',...
        'r18','r19','r20','r21',...
        't3'};


    % =========================== IMAGE FEATURES ======================== %
    % Wavelength of the Gabor filters
    cfg.img_features.gabor.wavelength = 4;
    % Orientation of the Gabor filters
    cfg.img_features.gabor.orientation = [0 22.5 45 67.5 90];

    % Local Binary Pattern settings
    cfg.img_features.lbp.upright = false;
    cfg.img_features.lbp.n_neighbors = 4;
    cfg.img_features.lbp.radius = 4;
    cfg.img_features.lbp.norm = 'none';

    cfg.img_features.features_to_remove = 73;


    % ============================ RESULTS PLOT ========================= %
    cfg.plot.heatmap_colormap = gray(256);
    cfg.plot.heatmap_colormap = cfg.plot.heatmap_colormap(130:end,:);
    
    cfg.plot.landmarks_size = 25;
    cfg.plot.landmarks_alpha = 0.7;
    cfg.plot.arrow_w = 1;
    cfg.plot.arrow_col = 'k';
    cfg.plot.head_l = 4;
    cfg.plot.head_w = 5;
    cfg.plot.font_size = 14;
    cfg.plot.font_name = 'Consolas';
    cfg.plot.cavity_alpha = 0.25;
    cfg.plot.cavity_color = 'k';
    cfg.plot.cavity_edge = 0.8;
    cfg.plot.label_col = 'w';

    cfg.pinna_shape_parts_colors = {'#0077c7', '#7e2f8e', '#e39362', '#f5ed9d'};

end
