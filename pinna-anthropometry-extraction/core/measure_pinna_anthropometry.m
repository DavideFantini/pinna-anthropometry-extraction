function [anthropometry, anthropometry_units] = measure_pinna_anthropometry(cfg,pinna_imgs,landmarks,reg_info,NameValueArgs)
% This function performs the propor extraction of the anthropometric
% measurements given the pinna landmarks and images
% INPUT
%   - cfg: configuration structure
%   - pinna_imgs: images of the pinnae
%   - landmarks: x and y coordinates of the landmarks of the pinnae
%                [# pinnae X # landmarks X 2]
%   - xy_scale: [default=1] scale factor of the x and y coordinates. The 
%               measurements made in x and y coordinates are multiplied by 
%               this factor to convert them from pixel units to the unit of  
%               measurement of your interest (e.g. cm).
%   - z_scale: [default=1] scale factor of the z coordinate. The
%              measurements made in z coordinate are multiplied by this 
%              factor to convert them from pixel units to the unit of 
%              measurement of your interest (e.g. cm).
%
% OUTPUT
%   - anthropometry: table with the anthropometric measurements


    % ============================ ARGUMENTS ============================ %
    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        landmarks (:,:,:) {mustBeNumeric}
        reg_info {isstruct}
        NameValueArgs.xy_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.z_scale {mustBeScalarOrEmpty} = 1
    end

    xy_scale = NameValueArgs.xy_scale;
    z_scale = NameValueArgs.z_scale;

    % ========================== INITIALIZATION ========================= %
    % Number of metrics
    n_metrics= numel(cfg.anthropometry.metrics_name);
    % Number of ear images
    n_pinnae = size(pinna_imgs,1);

    % Initialize the measurements martrix
    measurements_pxl = zeros(n_pinnae,n_metrics);

    
    % ======================= COMPUTE MEASURMENTS ======================= %
    for n=1:n_pinnae
        % Get n-th pinna image
        pinna_img = squeeze(pinna_imgs(n,:,:));

        % Get n-th landmarks
        landmark = squeeze(landmarks(n,:,:));

        % Estimate tragus and helix positions
        [tragus_pos, helix_pos] = get_pinna_characteristic_points(cfg, ...
            pinna_img, landmark);

        % Get the actual values of the measurement landmarks
        measurement_landmarks_values = get_measurement_landmarks_values( ...
            cfg, landmark, ...
            cfg.anthropometry.measurement_landmarks_pairs, tragus_pos, ...
            reg_info(n));

        for m=1:n_metrics

            % ======================================> d6
            if strcmp(cfg.anthropometry.metrics_name{m},'d6')
                measurements_pxl(n,m) = measure_d6(landmark);

            % ======================================> d5
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d5')
                measurements_pxl(n,m) = measure_d5(landmark);

            % ======================================> d8
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d8')       
                measurements_pxl(n,m) = measure_d8(pinna_img, ...
                    landmark, tragus_pos, measurement_landmarks_values, ...
                    xy_scale, z_scale);

            % ======================================> d9
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d9')
                measurements_pxl(n,m) = measure_d9(pinna_img, ...
                    tragus_pos, helix_pos, xy_scale, z_scale);

            % ======================================> d11, d12, d13
            elseif ismember(cfg.anthropometry.metrics_name{m}, {'d11', 'd12', 'd13'})
                measurements_pxl(n,m) = measure_distance_region( ...
                    reg_info(n), tragus_pos, ...
                    cfg.anthropometry.metrics_name{m});
                
            % =======================================> distance metrics
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'd')
                measurements_pxl(n,m) = measure_distance( ...
                    measurement_landmarks_values, ...
                    cfg.anthropometry.metrics_name{m});

            % ======================================> t1
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t1')
                measurements_pxl(n,m) = measure_t1(landmark);

            % ======================================> t2
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t2')
                measurements_pxl(n,m) = measure_t2(tragus_pos, helix_pos, ...
                    xy_scale, z_scale);
                
            % ======================================> t3
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t3')
                measurements_pxl(n,m) = measure_t3(cfg, pinna_img, ...
                    landmark, tragus_pos, xy_scale, z_scale);

            % ===========================================> angle metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'r')
                measurements_pxl(n,m) = measure_angle( ...
                    measurement_landmarks_values, ...
                    cfg.anthropometry.metrics_name{m});
          
            % ===========================================> area metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'a')
                measurements_pxl(n,m) = measure_area(reg_info(n), ...
                    cfg.anthropometry.metrics_name{m});

            % ===========================================> volume metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'v')
                measurements_pxl(n,m) = measure_volume(reg_info(n), ...
                    cfg.anthropometry.metrics_name{m}, xy_scale, z_scale);

            % ===========================================> depth metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'h')
                measurements_pxl(n,m) = measure_depth(reg_info(n), ...
                    cfg.anthropometry.metrics_name{m});
                
            end
        end
    end


    % ========================= SCALE CONVERSION ======================== %
    anthropometry = measurements_pxl;

    if xy_scale ~= 1
        % Convert in the desired scale
        metrics_to_scale_xy = cellfun(@(x) ...
            (startsWith(x, 'd') && x(2) ~= '8'  && x(2) ~= '9') || ...
            (startsWith(x, 'a')), cfg.anthropometry.metrics_name);

        anthropometry(:,metrics_to_scale_xy) = measurements_pxl(:, ...
            metrics_to_scale_xy) .* xy_scale;

    end

    if z_scale ~= 1
        metrics_to_scale_z = cellfun(@(x) startsWith(x, 'h'), ...
            cfg.anthropometry.metrics_name);
    
        anthropometry(:,metrics_to_scale_z) = measurements_pxl(:, ...
            metrics_to_scale_z) .* z_scale;
    end

    anthropometry = array2table(anthropometry, ...
        'VariableNames', cfg.anthropometry.metrics_name);


    % Set unit of measurements
    anthropometry_units = strings(size(anthropometry, 2), 1);

    dist_unit = cellfun(@(x) (startsWith(x, 'd')) || (startsWith(x, 'h')), ...
            cfg.anthropometry.metrics_name);
    area_unit = cellfun(@(x) startsWith(x, 'a'), ...
            cfg.anthropometry.metrics_name);
    volume_unit = cellfun(@(x) startsWith(x, 'v'), ...
            cfg.anthropometry.metrics_name);
    
    if (xy_scale ~= 1) || (z_scale ~= 1)
        anthropometry_units(dist_unit) = 'custom';
        anthropometry_units(area_unit) = 'custom^2';
        anthropometry_units(volume_unit) = 'custom^3';
    else
        anthropometry_units(dist_unit) = 'pixel';
        anthropometry_units(area_unit) = 'pixel^2';
        anthropometry_units(volume_unit) = 'pixel^3';
    end
    
    angle_unit = cellfun(@(x) (startsWith(x, 't')) || (startsWith(x, 'r')), ...
        cfg.anthropometry.metrics_name);
    anthropometry_units(angle_unit) = '°';

    anthropometry.Properties.VariableUnits = anthropometry_units;

end



function [measurement_landmarks_values] = get_measurement_landmarks_values( ...
    cfg, landmarks, measurement_landmarks_pairs, tragus_pos, reg_info)
% This function get the actual values of the measurement landmarks for each
% each shape
% INPUT
% - landmarks: landmarks [# landmarks X # coordinates]
% - measurement_landmarks_pairs: indices of the measurement landmark pairs
%                                [struct with fields named as the metric
%                                and containing the array of 2 landmarks
%                                indices]
% OUTPUT
% - measurement_landmarks_values: values of the measurement landmarks for
%                                 each metric

    % Get metrics name
    metrics = fieldnames(measurement_landmarks_pairs);

    % Number of metric from which extract the values
    n_metrics = length(metrics);


    % Number of coordinates to consider
    n_coord = size(landmarks, 2);

    % Initialize struct
    measurement_landmarks_values = struct;

    % 2 points are used to measure the distance
    n_points_measurement = 2;

    % Iterate over the metrics
    for m = 1:n_metrics
        % Initialize the array for metric m
        measurement_landmarks_values.(metrics{m}) = zeros( ...
            n_points_measurement,n_coord);

        if ismember(metrics{m}, {'d11', 'd12', 'd13'})
            a_idx = str2double(metrics{m}(3:end));
            
            measurement_landmarks_values.(metrics{m})(1,:) = [ ...
                                tragus_pos.x, tragus_pos.y];
            measurement_landmarks_values.(metrics{m})(2,:) = ...
                reg_info.area_centroid{a_idx};

        else
            for p = 1:n_points_measurement
    
                meas_lnd_idx = measurement_landmarks_pairs.(metrics{m})(p);
    
                % Get the values for the p-th measurement landmark of m
                % If the index is the tragus index, then use the estimated
                % tragus position
                if meas_lnd_idx == cfg.anthropometry.tragus_landmarks_idx
                    measurement_landmarks_values.(metrics{m})(p,:) = [ ...
                        tragus_pos.x, tragus_pos.y];
                else
                    measurement_landmarks_values.(metrics{m})(p,:) = squeeze( ...
                            landmarks(meas_lnd_idx, :));
                end
    
            end
        end
    end

end


function [tragus_pos, helix_pos] = get_pinna_characteristic_points(cfg, ...
    pinna_img, landmarks)
% This function return the estimated tragus and helix positions

    arguments
        cfg {isstruct}
        pinna_img (:,:) {mustBeNumeric}
        landmarks (:,:) {mustBeNumeric}
    end

    % Percentage of the x landmarks' range used to outline a square section
    % to find the tragus
    ear_section_margin_perc = 0.15;

    % The position of a specific landmark is used as initial estimated of
    % the tragus position. Then, the tragus position is estimated.
    init_tragus_pos.x = round(landmarks( ...
        cfg.anthropometry.tragus_landmarks_idx,1));
    init_tragus_pos.y = round(landmarks( ...
        cfg.anthropometry.tragus_landmarks_idx,2));


    % Get the horizontal section of the range images along the y
    % coordinate of the initial tragus position
    landmarks_xrange = (max(landmarks(:,2), [], 'all') - ...
        min(landmarks(:,2), [], 'all'));
    ear_section_margin = round(landmarks_xrange * ear_section_margin_perc);
    ear_section = pinna_img(init_tragus_pos.y - ear_section_margin: ...
        init_tragus_pos.y + ear_section_margin,:);

    % Get the prominence values of the ear section aroung the initial
    % tragus position
    area_around_tragus = ear_section(:, ...
        init_tragus_pos.x - ear_section_margin:init_tragus_pos.x + ...
        ear_section_margin);
    [~,prominence] = islocalmax(area_around_tragus, 2);

    % Select the tragus point as the maximum value in the area around the
    % tragus with added the scaled prominence and a 2D gaussian to
    % discourage the farthest points
    porminence_scaled = (prominence ./ max(prominence,[],'all').* ...
        max(area_around_tragus,[],'all').*0.05);
    area_around_tragus_prom = porminence_scaled + area_around_tragus;
    area_g = gaussian2D([size(prominence, 1)/2, size(prominence, 2)/2], ...
        size(prominence,1)*10,size(prominence,1),size(prominence,2));
    area_around_tragus_prom = area_around_tragus_prom .* area_g;
    [~, tragus_pos] = max(area_around_tragus_prom, [], 'all','linear');

    % Get the x y coordinates from linear index
    [tragus_pos_y, tragus_pos_x] = ind2sub(size(ear_section(:, ...
        1:init_tragus_pos.x)), tragus_pos);

    % Get the tragus position related to the original image
    tragus_pos = struct;
    tragus_pos.y = init_tragus_pos.y - ear_section_margin + tragus_pos_y;
    tragus_pos.x = init_tragus_pos.x - ear_section_margin + tragus_pos_x;


    % Get the horizontal section in corrispondence of the y tragus position
    ear_section_1 = pinna_img(tragus_pos.y,:);

    % Get the tragus z value
    tragus_pos.z = ear_section_1(tragus_pos.x);

    % Get helix positions
    [helix_pos.z, helix_pos.x] = max(ear_section_1);

    helix_pos.y = tragus_pos.y;

end



function [d] = measure_distance(measurement_landmarks_values, metric_name)
    p1 = measurement_landmarks_values.(metric_name)(1,:);
    p2 = measurement_landmarks_values.(metric_name)(2,:);

    % Measure the distance
    d = pdist2(p1, p2);
    
end


function [d5] = measure_d5(landmark_xy)

    d5 = max(landmark_xy(:,2)) - min(landmark_xy(:,2));

end


function [d6] = measure_d6(landmark_xy)

    d6 = max(landmark_xy(:,1)) - min(landmark_xy(:,1));

end


function [d8] = measure_d8(pinna_img, landmark_xy, tragus_pos, ...
    measurement_landmarks_values, xy_scale, z_scale)
                
    % Extract rectaungular region with the tragus and the intertragal notch
    % as vertices
    mrg = round((max(landmark_xy(:,1)) - min(landmark_xy(:,1)) ) * 0.025);
    d1_end_y = min(round(measurement_landmarks_values.d1(2,2)), ...
        tragus_pos.y - 1);
    d1_end_x = round(measurement_landmarks_values.d1(2,1));
    if d1_end_x < tragus_pos.x
        start_x = d1_end_x-mrg;
        end_x = tragus_pos.x+mrg;

    else
        start_x = tragus_pos.x - mrg;
        end_x = d1_end_x + mrg;

    end
    section = pinna_img(d1_end_y-mrg:tragus_pos.y+mrg, start_x:end_x);
    
    % Find the most prominent minima
    [~,section_prominence]=islocalmin(section,1);
    [~, d8_meas_point] = max(section_prominence, [], 'all', 'linear');

    [d8_meas_point_yrow, d8_meas_point_xcol] = ind2sub(size(section), ...
        d8_meas_point);
    
    d8_meas_point_yrow = d1_end_y - mrg + d8_meas_point_yrow;
    d8_meas_point_xcol = start_x + d8_meas_point_xcol;
    
    
    d8 = pdist2([tragus_pos.y*xy_scale, tragus_pos.x*xy_scale, ...
        tragus_pos.z * z_scale], ...
        [d8_meas_point_yrow*xy_scale, d8_meas_point_xcol*xy_scale, ...
        z_scale*(pinna_img(d8_meas_point_yrow,d8_meas_point_xcol))]);
end


function [d9] = measure_d9(pinna_img, tragus_pos, helix_pos, xy_scale, z_scale)
    % Get ear y section in tragus y position
    ear_section_1 = pinna_img(tragus_pos.y, :);

    % Compute differences ith adjacent points
    ear_section_1_d1 = diff(ear_section_1,1);

    % Find the 1st minima next to the tragus y position
    [~,prom_min_pos] = islocalmin(ear_section_1_d1( ...
        tragus_pos.x:min(helix_pos.x-1,size(ear_section_1_d1,2))));
    min_pos = find(prom_min_pos, 1);
    min_pos = min_pos + tragus_pos.x;
    d9_meas_point = find(ear_section_1_d1(min_pos+1:min(helix_pos.x, ...
        size(ear_section_1_d1,2))) > ...
        prctile((ear_section_1_d1(ear_section_1_d1>0)),25),1) + min_pos;


    d9 = pdist2([tragus_pos.x * xy_scale, ...
        tragus_pos.x * z_scale],...
        [d9_meas_point * xy_scale, z_scale * ear_section_1(d9_meas_point)]);
end


function [t1] = measure_t1(landmark_xy)

    % Compute the PCA of the landmarks for n
    landmarks_coeff = pca(landmark_xy);

    angle = atan2(landmarks_coeff(2,:), landmarks_coeff(1,:));

    t1 = rad2deg(-angle(2));

end


function [t2] = measure_t2(tragus_pos, helix_pos, xy_scale, z_scale)

    t2 = angle_between_points( ...
        [tragus_pos.x * xy_scale, tragus_pos.z * z_scale], ...
        [helix_pos.x * xy_scale, helix_pos.z * z_scale], 'deg');

end


function [t3] = measure_t3(cfg, pinna_img, landmarks, tragus_pos, ...
    xy_scale, z_scale)
    % Get top landmark coordinates
    lnd_i = landmarks(cfg.landmarks.pinna_parts_idx{4}, :);
    lnd_o = landmarks(cfg.landmarks.pinna_parts_idx{1}, :);
    
    [top_y_i, top_y_idx_i] = max(lnd_i(:,2));
    top_x_i = lnd_i(top_y_idx_i,1);
    [top_y_o, top_y_idx_o] = max(lnd_o(:,2));
    top_x_o = lnd_o(top_y_idx_o,1);

    top_land_x = mean([top_x_i, top_x_o]);
    top_land_y = mean([top_y_i, top_y_o]);
    top_land_z = get_image_z(pinna_img, top_land_x, top_land_y);

    t3 = angle_between_points([tragus_pos.y * xy_scale, tragus_pos.z  * z_scale], ...
        [top_land_y * xy_scale, top_land_z * z_scale], 'deg');
end


function [r] = measure_angle(measurement_landmarks_values, metric_name)

    d_metric = strrep(metric_name, 'r', 'd');

    p1 = measurement_landmarks_values.(d_metric)(1,:);
    p2 = measurement_landmarks_values.(d_metric)(2,:);

    % Measure the distance
    r = angle_between_points(p1, p2, 'deg');
    
end

function [d_r] = measure_distance_region(reg_info, tragus_pos, metric_name)

    a_idx = str2double(metric_name(3:end));
    a_shape = reg_info.area_shape{a_idx};

    % Get centroid
    [c_x, c_y] = centroid(a_shape);

    p1 = [tragus_pos.x, tragus_pos.y];
    p2 = [c_x, c_y];

    % Compute distance between tragus and centroid
    d_r = pdist2(p1, p2);

end

function [a] = measure_area(reg_info, metric_name)

    a = area(reg_info.area_shape{str2double(metric_name(2:end))});

end


function [v] = measure_volume(reg_info, metric_name, xy_scale, z_scale)

    lnd = reg_info.volume_lnd{str2double(metric_name(2:end))};

    lnd(:,1:2) = lnd(:,1:2) * xy_scale;
    lnd(:,3) = lnd(:,3) * z_scale;

    [~, v] = convhull(lnd);

end


function [h] = measure_depth(reg_info, metric_name)

    lnd = reg_info.volume_lnd{str2double(metric_name(2:end))};

    % Compute depth
    h = max(lnd(:,3)) - min(lnd(:,3));

end

