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
    cfg.landmarks.n_landmarks = 205;
    cfg.landmarks.n_coordinates = 3;
    cfg.landmarks.x_coordinate_idx = 1;
    cfg.landmarks.y_coordinate_idx = 2;
    cfg.landmarks.z_coordinate_idx = 3;

    % Landmarks' indices of the pinna parts
    cfg.landmarks.pinna_parts_idx = {1:49, 50:117, 118:135, 136:205};
    % Names of the pinna parts
    cfg.landmarks.pinna_parts_names = {'Outer Helix', 'Concha', ...
        'Triangular Fossa', 'Inner Helix'};


    % =========================== ANTHROPOMETRY ========================= %
    % Pair of landamrks indices used to measure the specified anthropometry
    cfg.anthropometry.measurement_landmarks_pairs = struct;
    cfg.anthropometry.measurement_landmarks_pairs.d1 = [58 77];
    cfg.anthropometry.measurement_landmarks_pairs.d2 = [58 108];
    cfg.anthropometry.measurement_landmarks_pairs.d3 = [69 94];
    cfg.anthropometry.measurement_landmarks_pairs.d4 = [108 169];
    cfg.anthropometry.measurement_landmarks_pairs.d7 = [72 80];
    cfg.anthropometry.measurement_landmarks_pairs.d11 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d12 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d13 = [];
    cfg.anthropometry.measurement_landmarks_pairs.d14 = [69 88];
    cfg.anthropometry.measurement_landmarks_pairs.d15 = [69 101];
    cfg.anthropometry.measurement_landmarks_pairs.d16 = [69 108];
    cfg.anthropometry.measurement_landmarks_pairs.d17 = [117 136];
    cfg.anthropometry.measurement_landmarks_pairs.d18 = [118 135];
    cfg.anthropometry.measurement_landmarks_pairs.d19 = [156 131];
    cfg.anthropometry.measurement_landmarks_pairs.d20 = [156 127];
    cfg.anthropometry.measurement_landmarks_pairs.d21 = [156 123];


    % Landmark's index used as initial estimated position of the tragus
    cfg.anthropometry.tragus_landmarks_idx = 69;

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
    cfg.plot.label_col = 'k';

    cfg.pinna_shape_parts_colors = {[0, 0.4688, 0.7773],...
        [0.5569, 0.2549, 0.6196], [0.8588, 0.5451, 0.3529],...
        [0.8510, 0.8039, 0.2706]};

    cfg.plot.cavity_dist_color = [0.5608, 0.7608, 0.8118];

end
