% Add the needed folders to the Path
addpath(genpath('../pinna-anthropometry-extraction/'));

% Get configuration struct
cfg = get_cfg();

% Load pinna range image
path_pinna_img = '../pinna_img_demo.mat';
load(path_pinna_img, 'pinna_img');


% Set estimated xy and z scales to cm conversion for the demo pinna image
% Set to 1 to get the measurements in pixels
xy_scale = 0.05;
z_scale = 114.285714285714;

% Extract pinna features
[anthropometry,landmarks,img_features] = get_pinna_features(cfg, ...
    pinna_img, 'xy_scale', xy_scale, 'z_scale', z_scale);

% Visualize results
plot_results(cfg, pinna_img, anthropometry, landmarks);
