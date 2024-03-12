function [anthropometry,landmarks,info] = get_pinna_anthropometry(cfg,pinna_imgs,landmarks,NameValueArgs)
% Function to get the pinna features (anthropometry, landmarks and image
% features) from range images.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) from which extract the features
%                 [# pinna images X height resolution X width resolution]
%   - landmarks: pinna landmarks x, y coordinates used to
%                extract the features.
%                If landmarks is a 2D array, then the 1st dimension
%                represents the number of pinnae, while the 2nd dimension
%                represent the landmarks x, y coordinates in the form
%                {x1, y1, x2, y2, ..., xK, yK } where K=205 is the total 
%                number of landmarks.
%                [# pinnae X # landmarks * 2]
%                If landmarks is a 3D array, then the 1st dimension
%                represents the number of pinnae, the 2nd dimension 
%                represents the number of landmarks, while the 3rd
%                dimension is the x, y coordinates
%                [# pinnae X # landmarks X 2]
%
%   Optional:
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
%
% OUTPUT
%   - anthropometry: table with the measured anthropometry. The columns
%                    represent the anthropometric parameters, while the
%                    rows represent the pinnae
%                    [# pinna images X # anthropometry]
%   - landmarks: fitted landmarks with x,y and z coordinates
%                [# pinna images X # landmarks X 3 coordinates]
%   - info: struct including information on pinna components


    % ============================ ARGUMENTS ============================ %
    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        landmarks {mustBeNumeric} = []
        NameValueArgs.xy_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.z_scale {mustBeScalarOrEmpty} = 1
    end

    % landmarks = NameValueArgs.landmarks;
    xy_scale = NameValueArgs.xy_scale;
    z_scale = NameValueArgs.z_scale;


    % ======================== LANDMARKS FITTING ======================== %
    % If landmarks is a 2D array then convert it to 3D
    if ismatrix(landmarks)
        landmarks = landmarks_reshape(cfg, landmarks, '2Dto3D');

    end

    % Check the correctness of landmarks
    if size(pinna_imgs, 1) ~= size(landmarks, 1)
        error(["Found " num2str(size(pinna_imgs, 1)) " and " ...
            num2str(size(landmarks, 1)) ...
            " landmarks. For each pinna image one set of landmarks must be provided."]);
    end

    % Get the info needed to compute area metrics 
    cavity_info = get_cavity_info(cfg, pinna_imgs, landmarks);

    info.cavity_info = cavity_info;

    
    % ==================== ANTHROPOMETRY EXTRACTION ===================== %
    % Compute measurements
    [anthropometry, characteristic_points] = measure_anthropometry( ...
        cfg, pinna_imgs, landmarks, cavity_info,...
        'xy_scale', xy_scale, 'z_scale', z_scale);

    info.characteristic_points = characteristic_points;
    
    % Get z coordinate of landmarks
    landmarks(:,:,3) = get_image_z(pinna_imgs, ...
        landmarks(:,:,1), landmarks(:,:,2));
end