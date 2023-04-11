function [anthropometry,landmarks,img_features] = get_pinna_features(cfg,pinna_imgs,NameValueArgs)
% Function to get the pinna features (anthropometry, landmarks and image
% features) from range images.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) from which extract the features
%                 [# pinna images X height resolution X width resolution]
%
%   Optional:
%   - landmarks: optional pinna landmarks x, y coordinates used to
%                extract the features. If not specified the landmarks are
%                automatically fitted using ASM.
%                If landmarks is a 2D array, then the 1st dimension
%                represents the number of pinnae, while the 2nd dimension
%                represent the landmarks x, y coordinates in the form
%                {x1, y1, x2, y2, ..., xK, yK } where K is the total number
%                of landmarks.
%                [# pinnae X # landmarks * 2]
%                If landmarks is a 3D array, then the 1st dimension
%                represents the number of pinnae, the 2nd dimension 
%                represents the number of landmarks, while the 3rd
%                dimension is the x, y coordinates
%                [# pinnae X # landmarks X 2]
%   - xy_scale: scale factor of the x and y coordinates. The measurements
%               made in x and y coordinates are multiplied by this factor
%               to convert them from pixel units to the unit of measurement 
%               of your interest (e.g. cm). If xy_scale is provided you
%               must provide z_scale, too.
%   - z_scale: scale factor of the z coordinate. The measurements made in z
%              coordinate are multiplied by this factor to convert them
%              from pixel units to the unit of measurement of your interest
%              (e.g. cm). If xy_scale is provided you must provide z_scale,
%              too.
%
%
% OUTPUT
%


    % ============================ ARGUMENTS ============================ %
    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        NameValueArgs.landmarks {mustBeNumeric} = []
        NameValueArgs.xy_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.z_scale {mustBeScalarOrEmpty} = 1
    end

    landmarks = NameValueArgs.landmarks;
    xy_scale = NameValueArgs.xy_scale;
    z_scale = NameValueArgs.z_scale;

    % ======================== LANDMARKS FITTING ======================== %
    % If landmarks are not provided in input, then ASM is used to get them
    if isempty(landmarks)
        landmarks = fit_landmarks(cfg, pinna_imgs);

    end

    % If landmarks is a 2D array then convert it to 3D
    if ismatrix(landmarks)
        landmarks = landmarks_reshape(cfg, landmarks, '2Dto3D');

    end

    if size(pinna_imgs, 1) ~= size(landmarks, 1)
        error(["Found " num2str(size(pinna_imgs, 1)) " and " ...
            num2str(size(landmarks, 1)) ...
            " landmarks. For each pinna image one set of landmarks musti be provided."]);
    end

%     % If the z coordinate is missing, then get it from the range images
%     if size(landmarks, 3) == 2
%         landmarks(:,:,3) = get_image_z(pinna_imgs, ...
%             landmarks(:,:,1), landmarks(:,:,2));
% 
%     end
    
    % Get the info needed to compute area metrics 
    reg_info = get_regions_info(cfg, pinna_imgs, landmarks);

    % ==================== ANTHROPOMETRY EXTRACTION ===================== %
    % Compute measurements
    anthropometry = measure_pinna_anthropometry( ...
        cfg, pinna_imgs, landmarks, reg_info,...
        'xy_scale', xy_scale, 'z_scale', z_scale);
    
    
    % =================== IMAGE FEATURES EXTRACTION ===================== %
    % Extract image features
    img_features = extract_img_features(cfg, pinna_imgs, area_coord_est);
    
    % Remove columns with all zeros
    if ~strcmp(cfg.img.features.to_extract, 'raw')
        features_to_keep = ~all(img_feat_man==0, 1) & ~all(img_feat_est==0, 1);
        img_feat_man = img_feat_man(:, features_to_keep);
        img_feat_est = img_feat_est(:, features_to_keep);
    end

end