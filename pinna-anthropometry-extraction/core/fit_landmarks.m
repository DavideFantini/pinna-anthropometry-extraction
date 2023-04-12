function [landmarks] = fit_landmarks(cfg, pinna_imgs, options)
% This function automatically the pinna landmarks using ASM algorithm.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) on which fit the landmarks
%                 [# pinna images X height resolution X width resolution]
%   Optional:
%   - options: ASM options
%       -> evolutions: number of ASM iterations. It can be a scalar or a
%                      vector of 2 elements representing the starting and 
%                      the ending number of ASM iterations for the 3 image
%                      resolutions evaluated by ASM.
%       -> search_sizes: search length (in pixels). It can be a scalar or a
%                        vector of 2 elements representing the starting and 
%                        the ending search sizes for the 3 image
%                        resolutions evaluated by ASM.
%       -> dist_metric: distance metric used for measuring accuracy of
%                       shifted profiles. It can be 'pca' or 'maha'
%                       (Mahalanobis).
%       -> n_pcs: number of principal components considered
%       -> m: normal contour, limit to +- m*sqrt(eigenvalue)
%       -> visualiza_fitting: whether to visualize the fitting plot
%
% OUTPUT
%   - landmarks: fitted landmarks
%                [# pinna images X # landmarks X 2 coordinates]


    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        options.evolutions (1,2) {mustBeNumeric} = cfg.asm.evolutions
        options.search_sizes (1,2) {mustBeNumeric} = cfg.asm.search_sizes
        options.dist_metric {mustBeMember(...
            options.dist_metric, ['pca', 'maha']) } = cfg.asm.dist_metric
        options.n_pcs (1,1) {mustBeNumeric} = cfg.asm.n_pcs
        options.m (1,1) {mustBeNumeric} = cfg.asm.m
        options.visualize_fitting (1,1) = cfg.asm.visualize_fitting
    end

    if cfg.verbose >= 1
        disp('ASM LANDAMARKS FITTING');
    end

    % Number of pinna images
    n_pinna_imgs = size(pinna_imgs, 1);

    % LOAD ASM MODEL
    model = load_asm_model(cfg);

    % FIT ASM
    landmarks = zeros(n_pinna_imgs, model.n_landmarks, 2);

    for n = 1:n_pinna_imgs
        if cfg.verbose >= 2
            disp(['Fitting image ' num2str(n) '/' ...
                num2str(n_pinna_imgs) ' ...']);
        end

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

    end

    % Bound the landmarks within the image size if these bounds were
    % exceeded by ASM
    landmarks = max(landmarks, 0);
    landmarks(:,:,1) = min(landmarks(:,:,1), size(pinna_imgs, 3));
    landmarks(:,:,2) = min(landmarks(:,:,2), size(pinna_imgs, 2));

end