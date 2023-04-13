function [cavity_info] = get_cavity_info(cfg, pinna_imgs, landmarks)
% This function returns the info needed to measure the area metrics
%
% INPUT
%   - cfg: configuration structure
%   - pinna_imgs: images of the pinnae
%   - landmarks: x and y coordinates of the landmarks of the pinnae
%                [# pinnae X # landmarks X 2]
%
%
% OUTPUT
%   - cavity_info: structure of the pinna cavities info


    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        landmarks (:,:,:) {mustBeNumeric}
    end

    if cfg.verbose >= 1
        disp("Obtaining regions' info...");
    end

    % Suppress polyshape warning
    warning('off', 'MATLAB:polyshape:repairedBySimplify');

    % Number of pinna images
    n_pinnae = size(pinna_imgs,1);

    % Initialize area landmarks cell array (3 area)
    n_areas = 3;

    cavity_info(n_pinnae) = struct();

    for n = 1:n_pinnae

        % Get n-th pinna image
        pinna_img = squeeze(pinna_imgs(n,:,:));

        % Get n-th landmarks
        landmark = squeeze(landmarks(n,:,:));

        area_lnd = cell(n_areas,1);
        cavity_info(n).area_shape = cell(n_areas,1);
        cavity_info(n).volume_lnd = cell(n_areas,1);
        cavity_info(n).area_centroid = cell(n_areas,1);
    
        % Initialize area coordinates
        a = struct;
        a.x_range = zeros(1, 2);
        a.y_range = zeros(1, 2);
        cavity_info(n).area_range = {a, a, a};
    
        % Get the concha landmarks
        concha_lnd = landmark(cfg.landmarks.pinna_parts_idx{2}, :);
    
        % GET RIGHT FOSSA TRAINGULARIS
        % Get the right landmarks of the fossa triangularis
        fossa_triang_lnd_right = landmark( ...
            cfg.landmarks.pinna_parts_idx{3},:);
    
        % Get the bottom landmark
        fossa_triang_bottom_coord = fossa_triang_lnd_right(end, :);
    
        % GET BOTTOM FOSSA TRAINGULARIS
        % Get the concha landmarks at the left of the bottom fossa
        % triangularis landmark
        concha_fossa_triang_mask = concha_lnd(:,1) < ...
            fossa_triang_bottom_coord(1);
    
        % Get the index of the starting index of the concha/fossa
        % triangularis landamarks
        concha_start_fossa_triang_idx = find(concha_fossa_triang_mask == 0, ...
            1, 'last') + 1;
    
        % Get the bottom landmarks of the fossa triangularis
        fossa_triang_lnd_bottom = concha_lnd( ...
            concha_start_fossa_triang_idx:end, :);
    
        % GET LEFT FOSSA TRAINGULARIS
        % Get the internal helix landmarks
        helix_lnd = landmark(cfg.landmarks.pinna_parts_idx{4}, :);
        
        % Get the inner helix landmarks between the max and min of
        % the fossa triangularis in y coordinate
        helix_fossa_triang_mask = helix_lnd(:,2) > ...
            fossa_triang_lnd_bottom(end, 2) & ...
            helix_lnd(:,2) < fossa_triang_lnd_right(1, 2);
    
        % Get the starting index of the helix/fossa
        % triangularis landamarks
        helix_concha_inters_idx = find( ...
            helix_fossa_triang_mask, 1);
    
    
        % AREA 1 - CAVUM
        % Get the concha landmarks at the right of the first concha
        % landmark in x coordinate
        concha_right_mask = concha_lnd(:,1) > concha_lnd(1,1);
    
        % Get the masked concha landmarks
        concha_lnd_masked = concha_lnd;
        concha_lnd_masked(~concha_right_mask,:) = NaN;
    
        % Get the index of the landmark with the minimum distince
        % with the first concha landmark in y coordinate
        [~, concha_stop_idx] = min(abs(concha_lnd_masked(:, 2) - ...
            concha_lnd(1,2)), [], 'omitnan');
    
        % Compute area
        area_lnd{1} = concha_lnd(1:concha_stop_idx,:);
        cavity_info(n).area_shape{1} = polyshape(area_lnd{1});
    
        cavity_info(n).area_range{1}.x_range = [min(area_lnd{1}(:,1)), ...
            max(area_lnd{1}(:,1))];
        cavity_info(n).area_range{1}.y_range = [min(area_lnd{1}(:,2)), ...
            max(area_lnd{1}(:,2))];

        % Get centroid
        [cx, cy] = centroid(cavity_info(n).area_shape{1});
        cavity_info(n).area_centroid{1} = [cx, cy];
    
    
        % AREA 2 - CYMBA
        % Get the concha landmarks at the right of the first helix
        % landmark in x coordinate
        concha_top_mask = concha_lnd(:,2) > helix_lnd(1,2);
    
        % Find the first concha landmark upon helix starting from
        % the end
        concha_start_idx = find(concha_top_mask==0, 1, 'last')+1;
    
        a2_landmarks = [concha_lnd(concha_start_idx:end,:); ...
            flip(helix_lnd(1:helix_concha_inters_idx,:))];
    
         % Compute area
        area_lnd{2} = a2_landmarks;
        cavity_info(n).area_shape{2} = polyshape(area_lnd{2});
    
        cavity_info(n).area_range{2}.x_range = [min(area_lnd{2}(:,1)), ...
            max(area_lnd{2}(:,1))];
        cavity_info(n).area_range{2}.y_range = [min(area_lnd{2}(:,2)), ...
            max(area_lnd{2}(:,2))];
    
        % Get centroid
        [cx, cy] = centroid(cavity_info(n).area_shape{2});
        cavity_info(n).area_centroid{2} = [cx, cy];
    
        % AREA 3 - FOSSA TRIANGULARIS
        % Get the stop index of the helix/fossa
        % triangularis landamarks
        helix_stop_fossa_triang_idx = find( ...
            helix_fossa_triang_mask( ...
            helix_concha_inters_idx:end) == 0, ...
            1) + helix_concha_inters_idx - 2;
    
        % Get the bottom landmarks of the fossa triangularis
        fossa_triang_lnd_left = helix_lnd( ...
            helix_concha_inters_idx:helix_stop_fossa_triang_idx, :);
    
        % GET AREA
        % Concatenate fossa traingularis landmarks
        fossa_triang_lnd = [fossa_triang_lnd_right;
            fossa_triang_lnd_bottom; fossa_triang_lnd_left];
    
        % Compute area
        area_lnd{3} = fossa_triang_lnd;
        cavity_info(n).area_shape{3} = polyshape(area_lnd{3});
    
        cavity_info(n).area_range{3}.x_range = [min(area_lnd{3}(:,1)), 
            max(area_lnd{3}(:,1))];
        cavity_info(n).area_range{3}.y_range = [min(area_lnd{3}(:,2)), 
            max(area_lnd{3}(:,2))];
    
        % Get centroid
        [cx, cy] = centroid(cavity_info(n).area_shape{3});
        cavity_info(n).area_centroid{3} = [cx, cy];

    
        % VOLUMES
        for a_idx = 1:n_areas
    %         a_idx = str2double(cfg.anthro.metrics_name{m}(2:end));
            lnd_2d_edge = area_lnd{a_idx};
        
            % Ranges of the area
            max_values = floor(max(lnd_2d_edge, [], 1));
            min_values = ceil(min(lnd_2d_edge, [], 1));
        
            % Get the point inside the area
            [x,y] = meshgrid(min_values(1):max_values(1), ...
                min_values(2):max_values(2));
            x = x(:);
            y = y(:);
            in_area_pt = [x, y];
            in_area_pt = in_area_pt(isinterior(cavity_info(n).area_shape{a_idx}, ...
                in_area_pt(:,1), in_area_pt(:,2)), :);
        
            % Add all the point together
            lnd = [lnd_2d_edge; in_area_pt];
        
            % Get 3D landmarks
            lnd(:,3) = get_image_z(pinna_img, lnd(:,1)', lnd(:,2)');
            
            cavity_info(n).volume_lnd{a_idx} = lnd;
    
        end
    end
end