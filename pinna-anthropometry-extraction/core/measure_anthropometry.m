function [anthropometry, characteristic_points] = measure_anthropometry(cfg,pinna_imgs,landmarks,cavity_info,NameValueArgs)
% This function performs the propor extraction of the anthropometric
% measurements given the pinna landmarks and images.
%
% INPUT
%   Required
%   - cfg: configuration structure
%   - pinna_imgs: images of the pinnae
%   - landmarks: x and y coordinates of the landmarks of the pinnae
%                [# pinnae X # landmarks X 2]
%   - cavity_info: structure of the pinna cavities info
%
%   Optional:
%   - xy_scale: [default=1] scale factor of the x and y coordinates. The 
%               measurements made in x and y coordinates are multiplied by 
%               this factor to convert them from pixel units to the unit of  
%               measurement of your interest (e.g. cm).
%   - z_scale: [default=1] scale factor of the z coordinate. The
%              measurements made in z coordinate are multiplied by this 
%              factor to convert them from pixel units to the unit of 
%              measurement of your interest (e.g. cm).
%
%
% OUTPUT
%   - anthropometry: table with the measured anthropometry. The columns
%                    represent the anthropometric parameters, while the
%                    rows represent the pinnae
%                    [# pinna images X # anthropometry]


    % ============================ ARGUMENTS ============================ %
    arguments
        cfg {isstruct}
        pinna_imgs (:,:,:) {mustBeNumeric}
        landmarks (:,:,:) {mustBeNumeric}
        cavity_info {isstruct}
        NameValueArgs.xy_scale {mustBeScalarOrEmpty} = 1
        NameValueArgs.z_scale {mustBeScalarOrEmpty} = 1
    end

    xy_scale = NameValueArgs.xy_scale;
    z_scale = NameValueArgs.z_scale;

    if cfg.verbose >= 1
        disp('MEASURE ANTHROPOMETRY');
    end

    % ========================== INITIALIZATION ========================= %
    % Number of metrics
    n_metrics= numel(cfg.anthropometry.metrics_name);
    % Number of ear images
    n_pinna_imgs = size(pinna_imgs,1);

    % Initialize the measurements martrix
    anthropometry = zeros(n_pinna_imgs,n_metrics);

    % Initialize characteristic points
    characteristic_points.tragus.x = zeros(n_pinna_imgs, 1);
    characteristic_points.tragus.y = zeros(n_pinna_imgs, 1);
    characteristic_points.tragus.z = zeros(n_pinna_imgs, 1);
    characteristic_points.helix = characteristic_points.tragus;
    
    % ======================= COMPUTE MEASURMENTS ======================= %
    for n = 1:n_pinna_imgs
        if cfg.verbose >= 2
            disp(['Measuring anthropometry for image ' num2str(n) '/' ...
                num2str(n_pinna_imgs) ' ...']);
        end

        % Get n-th pinna image
        pinna_img = squeeze(pinna_imgs(n,:,:));

        % Get n-th landmarks
        landmark = squeeze(landmarks(n,:,:));

        % Estimate tragus and helix positions
        [tragus_pos, helix_pos] = get_pinna_characteristic_points(cfg, ...
            pinna_img, landmark);
        characteristic_points.tragus.x(n) = tragus_pos.x;
        characteristic_points.tragus.y(n) = tragus_pos.y;
        characteristic_points.tragus.z(n) = tragus_pos.z;
        characteristic_points.helix.x(n) = helix_pos.x;
        characteristic_points.helix.y(n) = helix_pos.y;
        characteristic_points.helix.z(n) = helix_pos.z;

        % Get the actual values of the measurement landmarks
        measurement_landmarks_values = get_measurement_landmarks_values( ...
            cfg, landmark, ...
            cfg.anthropometry.measurement_landmarks_pairs, tragus_pos, ...
            cavity_info(n));

        for m=1:n_metrics

            % ======================================> d6
            if strcmp(cfg.anthropometry.metrics_name{m},'d6')
                anthropometry(n,m) = measure_d6(landmark, xy_scale);

            % ======================================> d5
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d5')
                anthropometry(n,m) = measure_d5(landmark, xy_scale);

            % ======================================> d8
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d8')       
                anthropometry(n,m) = measure_d8(pinna_img, ...
                    landmark, tragus_pos, measurement_landmarks_values, ...
                    xy_scale, z_scale);

            % ======================================> d9
            elseif strcmp(cfg.anthropometry.metrics_name{m},'d9')
                anthropometry(n,m) = measure_d9(pinna_img, ...
                    tragus_pos, xy_scale, z_scale);

            % ======================================> d11, d12, d13
            elseif ismember(cfg.anthropometry.metrics_name{m}, {'d11', 'd12', 'd13'})
                anthropometry(n,m) = measure_centroid_distance( ...
                    cavity_info(n), tragus_pos, ...
                    cfg.anthropometry.metrics_name{m}, xy_scale);
                
            % =======================================> distance metrics
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'd')
                anthropometry(n,m) = measure_distance( ...
                    measurement_landmarks_values, ...
                    cfg.anthropometry.metrics_name{m}, xy_scale);

            % ======================================> t1
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t1')
                anthropometry(n,m) = measure_t1(landmark);

            % ======================================> t2
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t2')
                anthropometry(n,m) = measure_t2(tragus_pos, helix_pos, ...
                    xy_scale, z_scale);
                
            % ======================================> t3
            elseif strcmp(cfg.anthropometry.metrics_name{m},'t3')
                anthropometry(n,m) = measure_t3(cfg, pinna_img, ...
                    landmark, tragus_pos, xy_scale, z_scale);

            % ===========================================> angle metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'r')
                anthropometry(n,m) = measure_angle( ...
                    measurement_landmarks_values, ...
                    cfg.anthropometry.metrics_name{m});
          
            % ===========================================> area metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'a')
                anthropometry(n,m) = measure_area(cavity_info(n), ...
                    cfg.anthropometry.metrics_name{m}, xy_scale);

            % ===========================================> volume metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'v')
                anthropometry(n,m) = measure_volume(cavity_info(n), ...
                    cfg.anthropometry.metrics_name{m}, xy_scale, z_scale);

            % ===========================================> depth metric
            elseif startsWith(cfg.anthropometry.metrics_name{m}, 'h')
                anthropometry(n,m) = measure_depth(cavity_info(n), ...
                    cfg.anthropometry.metrics_name{m}, z_scale);
                
            end
        end
    end


    % ======================== UNIT OF MEASUREMENT ====================== %
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

    % Percentage of the landmarks' range used to outline a square section
    % to find the tragus
    tragus_section_margin_perc_y = 0.15;
    tragus_section_margin_perc_x = 0.1;

    % The position of a specific landmark is used as initial estimated of
    % the tragus position. Then, the tragus position is estimated in a area
    % around the initial position.
    init_tragus_pos.x = round(landmarks( ...
        cfg.anthropometry.tragus_landmarks_idx,1));
    init_tragus_pos.y = round(landmarks( ...
        cfg.anthropometry.tragus_landmarks_idx,2));

    tragus_section_margin_y = round((max(landmarks(:,2), [], 'all') - ...
        min(landmarks(:,2), [], 'all')) * tragus_section_margin_perc_y);
    tragus_section_margin_x = round((max(landmarks(:,1), [], 'all') - ...
        min(landmarks(:,1), [], 'all')) * tragus_section_margin_perc_x);
    
    x_p = 0.6;
    y_p = 0.4;
    tragus_section = pinna_img(init_tragus_pos.y - round(tragus_section_margin_y*y_p): ...
        init_tragus_pos.y + round(tragus_section_margin_y*(1-y_p)), ...
        init_tragus_pos.x - round(tragus_section_margin_x*x_p): ...
        init_tragus_pos.x + round(tragus_section_margin_x*(1-x_p)));

    % Estimate the tragus position as the max point in z coordinate
    [~, tragus_pos]=max(tragus_section, [], 'all', 'linear');
    % Get the x y coordinates from linear index
    [tragus_pos_y, tragus_pos_x] = ind2sub(size(tragus_section), tragus_pos);

    % Get the tragus position related to the original image
    tragus_pos = struct;
    tragus_pos.x = init_tragus_pos.x - round(tragus_section_margin_x*x_p) + tragus_pos_x - 1;
    tragus_pos.y = init_tragus_pos.y - round(tragus_section_margin_y*y_p) + tragus_pos_y;

    % Get the horizontal section in corrispondence of the y tragus position
    ear_section_1 = pinna_img(tragus_pos.y, :);

    % Get the tragus z value
    tragus_pos.z = ear_section_1(tragus_pos.x);

    % Get helix positions
    [helix_pos.z, helix_pos.x] = max(ear_section_1);

    helix_pos.y = tragus_pos.y;

end



function [d] = measure_distance(measurement_landmarks_values, metric_name, xy_scale)
    p1 = measurement_landmarks_values.(metric_name)(1,:);
    p2 = measurement_landmarks_values.(metric_name)(2,:);

    % Measure the distance
    d = pdist2(p1, p2) .* xy_scale;
    
end


function [d5] = measure_d5(landmark_xy, xy_scale)

    d5 = (max(landmark_xy(:,2)) - min(landmark_xy(:,2))) .* xy_scale;

end


function [d6] = measure_d6(landmark_xy, xy_scale)

    d6 = (max(landmark_xy(:,1)) - min(landmark_xy(:,1))) .* xy_scale;

end


function [d8] = measure_d8(pinna_img, landmark_xy, tragus_pos, ...
    measurement_landmarks_values, xy_scale, z_scale)
                
    % Extract rectaungular region with the tragus and the intertragal notch
    % as vertices
    mrg_perc = 0.025;
    mrg = round((max(landmark_xy(:,1)) - min(landmark_xy(:,1)) ) * mrg_perc);

    % Get d1 inferior measurement point
    d1_y = round(measurement_landmarks_values.d1(2,2));
    d1_x = round(measurement_landmarks_values.d1(2,1));

    % Outline the section around d1 inferior measurement point
    section = pinna_img(d1_y - mrg:d1_y + mrg , d1_x - mrg:d1_x + mrg);
    [~, d8_meas_point] = min(section, [], 'all', 'linear');

    [d8_meas_point_yrow, d8_meas_point_xcol] = ind2sub(size(section), ...
        d8_meas_point);
    
    d8_meas_point_yrow = d1_y - mrg + d8_meas_point_yrow;
    d8_meas_point_xcol = d1_x - mrg + d8_meas_point_xcol;

    % Compute measurement
    d8 = pdist2([tragus_pos.y * xy_scale, tragus_pos.x * xy_scale, ...
        tragus_pos.z * z_scale], ...
        [d8_meas_point_yrow * xy_scale, d8_meas_point_xcol * xy_scale, ...
        z_scale * (pinna_img(d8_meas_point_yrow, d8_meas_point_xcol))]);
end


function [d9] = measure_d9(pinna_img, tragus_pos, xy_scale, z_scale)
    % Get ear y section in tragus y position
    ear_section_1 = pinna_img(tragus_pos.y, :);

    % Outline the section of the concha between the tragus and the helix
    init_margin = 5;
    ear_sect_sup_tragus = ear_section_1 > ear_section_1(tragus_pos.x);
    ear_sect_sup_tragus = ear_sect_sup_tragus(tragus_pos.x:end);
    ear_sect_sup_tragus(1:init_margin) = 0;
    end_concha_idx = find(ear_sect_sup_tragus, 1) + tragus_pos.x - 2;

    concha_section = ear_section_1(tragus_pos.x + init_margin:max(tragus_pos.x+(init_margin*2), end_concha_idx));

    % Compute the different between adjacent elements
    concha_section_diff = diff(concha_section, 1);
    % Find the local max
    [~, prom_concha] = islocalmax(concha_section_diff);
    if all(prom_concha==0)
        d9_meas_point = numel(concha_section) - 1;
    else
        [~, d9_meas_point] = max(prom_concha);
    end
    d9_meas_point = d9_meas_point + tragus_pos.x + init_margin - 2;
    
    d9 = pdist2([tragus_pos.x * xy_scale, ...
        tragus_pos.z * z_scale],...
        [d9_meas_point * xy_scale, z_scale * ear_section_1(d9_meas_point)]);
end


function [t1] = measure_t1(landmark_xy)

    % Find top and bottom landmarks
    [~,top_lnd_idx] = max(landmark_xy(:,2));
    [~,bottom_lnd_idx] = min(landmark_xy(:,2));
    top_lnd = landmark_xy(top_lnd_idx,:);
    bottom_lnd = landmark_xy(bottom_lnd_idx,:);

    % Compute the angle between the top and bottom landmarks
    t1 = 90 - angle_between_points(bottom_lnd, top_lnd, 'deg');

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
    r = 90 - angle_between_points(p1, p2, 'deg');
    
end

function [d_r] = measure_centroid_distance(reg_info, tragus_pos, metric_name, xy_scale)

    a_idx = str2double(metric_name(3:end));
    a_shape = reg_info.area_shape{a_idx};

    % Get centroid
    [c_x, c_y] = centroid(a_shape);

    p1 = [tragus_pos.x, tragus_pos.y];
    p2 = [c_x, c_y];

    % Compute distance between tragus and centroid
    d_r = pdist2(p1, p2) .* xy_scale;

end

function [a] = measure_area(reg_info, metric_name, xy_scale)

    a = area(reg_info.area_shape{str2double(metric_name(2:end))}) * ...
        (xy_scale ^ 2);

end


function [v] = measure_volume(reg_info, metric_name, xy_scale, z_scale)

    lnd = reg_info.volume_lnd{str2double(metric_name(2:end))};

    lnd(:,1:2) = lnd(:,1:2) * xy_scale;
    lnd(:,3) = lnd(:,3) * z_scale;

    [~, v] = convhull(lnd);

end


function [h] = measure_depth(reg_info, metric_name, z_scale)

    lnd = reg_info.volume_lnd{str2double(metric_name(2:end))};

    % Compute depth
    h = (max(lnd(:,3)) - min(lnd(:,3))) * z_scale;

end

