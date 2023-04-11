function [landmarks] = fit_landmarks(cfg,pinna_imgs, options)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    arguments
        cfg
        pinna_imgs (:,:,:) {mustBeNumeric}
        options.evolutions (1,2) {mustBeNumeric} = cfg.asm.evolutions
        options.search_sizes (1,2) {mustBeNumeric} = cfg.asm.search_sizes
        options.dist_metric {mustBeMember(...
            options.dist_metric, ['pca', 'maha']) } = cfg.asm.dist_metric
        options.n_pcs (1,1) {mustBeNumeric} = cfg.asm.n_pcs
        options.m (1,1) {mustBeNumeric} = cfg.asm.m
        options.visualize_fitting (1,1) = cfg.asm.visualize_fitting
    end


    % Number of pinna images
    n_pinna_imgs = size(pinna_imgs, 1);

%     % IMAGES PRE-PROCESSING
%     if cfg.landmarks.w_step ~= 0
% 
%         % Perform step edge magnitude on range images
%         step_edge_magnitude = stepEdgeMagnitude(pinna_imgs);
%         
%         % Mix the original images with the step edge magnitude version
%         pinna_imgs = (1-cfg.landmarks.w_step) .* pinna_imgs +...
%             (cfg.landmarks.w_step .* step_edge_magnitude);
%     end

    % LOAD ASM MODEL
    load(cfg.asm.models_path, 'model');

    % FIT ASM
    landmarks = zeros(n_pinna_imgs, model.n_landmarks, 2);

    for n = 1:n_pinna_imgs
        disp(['Fitting image ' num2str(n) '/' num2str(n_pinna_imgs) ' ...']);

        pinna_img = squeeze(pinna_imgs(n,:,:));

        % Get the x and y coordinates of the landmarks with ASM
        landmarks(n,:,:) = ASM(pinna_img, ...
            model.shape_model, model.gray_model,...
            'evolutions', options.evolutions,...
            'search_sizes', options.search_sizes, ...
            'dist_metric', options.dist_metric, ...
            'n_pcs', options.n_pcs, ...
            'm', options.m, ...
            'pinna_parts_idx', cfg.landmarks.pinna_parts_idx, ...
            'visualize', options.visualize_fitting);


%         % Get the z coordinate of fitted landmarks from the range images
%         landmarks(n,:,3) = get_image_z(pinna_imgs(:,:,n), ...
%             landmarks(:,1,n), landmarks(:,2,n));

    end

    % Bound the landmarks within the image size if these bounds were
    % exceeded by ASM
    landmarks = max(landmarks, 0);
    landmarks(:,:,1) = min(landmarks(:,:,1), size(pinna_imgs, 3));
    landmarks(:,:,2) = min(landmarks(:,:,2), size(pinna_imgs, 2));

end