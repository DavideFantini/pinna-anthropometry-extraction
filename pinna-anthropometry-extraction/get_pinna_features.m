function [anthropometry,landmarks,img_features,info] = get_pinna_features(cfg,pinna_imgs,NameValueArgs)
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
%              (e.g. cm). If z_scale is provided you must provide xy_scale,
%              too.
%   - right_pinna: whether in the provided images are represented right
%                  pinnae. It is a boolean array with one element for each 
%                  pinna. For the true elements, the corresponding pinna 
%                  image will be mirrored.
%                  [# pinnae]
%
% OUTPUT
%   - anthropometry: table with the measured anthropometry. The columns
%                    represent the anthropometric parameters, while the
%                    rows represent the pinnae
%                    [# pinna images X # anthropometry]
%   - landmarks: fitted landmarks with x,y and z coordinates
%                [# pinna images X # landmarks X 3 coordinates]
%   - img_features: extracted image features
%                   [# pinna images X # image features]


    % ============================ ARGUMENTS ============================ %
    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        NameValueArgs.landmarks_xy {mustBeNumeric} = []
        NameValueArgs.xy_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.z_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.right_pinna {mustBeVector} = false(size(pinna_imgs,1),1)
    end

    landmarks_xy = NameValueArgs.landmarks_xy;
    xy_scale = NameValueArgs.xy_scale;
    z_scale = NameValueArgs.z_scale;
    right_pinna = NameValueArgs.right_pinna;


    % ======================= IMAGE PRE-PROCESSING ====================== %
    % Pre-process pinna images
    pinna_imgs = pinna_images_preprocessing(cfg, pinna_imgs, right_pinna);


    % ======================== LANDMARKS FITTING ======================== %
    % If landmarks are not provided in input, then ASM is used to get them
    if isempty(landmarks_xy)
        landmarks_xy = fit_landmarks(cfg, pinna_imgs);

    end

    % If landmarks is a 2D array then convert it to 3D
    if ismatrix(landmarks_xy)
        landmarks_xy = landmarks_reshape(cfg, landmarks_xy, '2Dto3D');

    end

    % Check the correctness of landmarks
    if size(pinna_imgs, 1) ~= size(landmarks_xy, 1)
        error(["Found " num2str(size(pinna_imgs, 1)) " and " ...
            num2str(size(landmarks_xy, 1)) ...
            " landmarks. For each pinna image one set of landmarks must be provided."]);
    end

    % Get z coordinate of landmarks
    landmarks = landmarks_xy;
    landmarks(:,:,3) = get_image_z(pinna_imgs, ...
        landmarks_xy(:,:,1), landmarks_xy(:,:,2));

    % Get the info needed to compute area metrics 
    cavity_info = get_cavity_info(cfg, pinna_imgs, landmarks_xy);

    info.cavity_info = cavity_info;

    
    % ==================== ANTHROPOMETRY EXTRACTION ===================== %
    % Compute measurements
    [anthropometry, characteristic_points] = measure_anthropometry( ...
        cfg, pinna_imgs, landmarks_xy, cavity_info,...
        'xy_scale', xy_scale, 'z_scale', z_scale);

    info.characteristic_points = characteristic_points;
    
    
    % =================== IMAGE FEATURES EXTRACTION ===================== %
    % Extract image features
    img_features = extract_img_features(cfg, pinna_imgs, cavity_info);
    
end