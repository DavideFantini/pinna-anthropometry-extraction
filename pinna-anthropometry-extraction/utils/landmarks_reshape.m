function [reshaped_lnd] = landmarks_reshape(cfg, lnd, reshape_type)
% This function provides a set of utils to reshape the landmarks matrices
% - cfg: configuration structure
% - lnd: landmarks to reshape. The 1st dimension is the number of pinnae.
%        The 2nd dimension is the number of landmarks or the number of
%        landmarks multiplied by the number of coordinates if there is no
%        3rd dimension. The 3rd dimension, if present, is the number of
%        coordinates (2 or 3).
% - reshape_type: type of reshape
%   -> remove_z: remove Z coordinate from landmarks. If landmarks are in 
%                2D format, it is assumed that coordinates are interleaved
%                {x1, y1, z1, x2, y2, z2, ... }.
%   -> 2Dto3D: reshape from [# pinnae X # landmarks * # coordinates] to
%              [# pinnae X # landmarks X # coordinates]. Assumption: the
%              input landmarks' coordinates are interleaved {x1, y1, (z1,)
%              x2, y2, (z2,) ...}.
%   -> 3Dto2D: reshape from [# pinnae X # landmarks X # coordinates] to
%              [# pinnae X # landmarks * # coordinates] where the output
%              landmarks' coordinates are interleaved {x1, y1, (z1,) x2,
%              y2, (z2,) ...}.
%   -> interleave2concat: reshape from landmarks' coordinates from the 
%                         interleaved format {x1, y1, (z1,) x2, y2, (z2,)
%                         ...} to the concatenated format {x1, x2, ... ,
%                         y1, y2 (, ... , z1, z2, ...)}.
%                         Assumption: landmarks are in the 2D matrix format
%   -> concat2interleave: reshape from landmarks' coordinates from the 
%                         concatenated format {x1, x2, ... , y1, y2 (, ...
%                         , z1, z2, ...)} to the interleaved format {x1,
%                         y1, (z1,) x2, y2, (z2,) ...}.
%                         Assumption: landmarks are in the 2D matrix format


    % Error messages
    msg_2d_wrong_lnd_dim = ['The 2nd dimension of lnd ('...
        num2str(size(lnd, 2)) ...
        ') is not multiple by 2 or 3 of the defined number of landmarks ('...
        num2str(cfg.landmarks.n_landmarks) ')'];

    msg_3d_ncoord_wrong = ['Number of coordinates (3nd dimension of lnd = '...
                    num2str(size(lnd, 3)) ') is different from 2 and 3'];

    msg_not_2d = [...
        "Landmarks should be in the 2D format for the reshape type '" ...
        reshape_type "'"];

    msg_wrong_format = ['Landmarks must be in the 2D or 3D format. Found ' ...
                    num2str(ndims(lnd)) ' dimensions'];

    switch reshape_type
        case 'remove_z'
            % If landmarks are in 2D format, it is assumed that coordinates
            % are interleaved (x1, y1, z1, x2, y2, z2, ... )
            if ismatrix(lnd)
                reshaped_lnd = lnd;
                reshaped_lnd(:,cfg.landmarks.z_coordinate_idx:cfg.landmarks.n_coordinates:end) = [];

            % If landmarks are in 3D format
            elseif ndims(lnd) == 3
                reshaped_lnd = lnd(:,:, ...
                    [cfg.landmarks.x_coordinate_idx, ...
                    cfg.landmarks.y_coordinate_idx]);

            else
                error(msg_wrong_format);
            end


        case '2Dto3D'
            % If there are x, y and z coordinates
            if size(lnd, 2) == cfg.landmarks.n_landmarks * 3
                reshaped_lnd = cat(3, lnd(:,1:3:end),...
                    lnd(:,2:3:end), lnd(:,3:3:end));
    
            % If there are only x and y coordinates
            elseif size(lnd, 2) == cfg.landmarks.n_landmarks * 2
                    reshaped_lnd = cat(3, lnd(:,1:2:end),...
                    lnd(:,2:2:end));

            else
                error(msg_2d_wrong_lnd_dim);
            end
            

        case '3Dto2D'
            reshaped_lnd = zeros(size(lnd, 1), size(lnd, 2) * size(lnd, 3));

            % If there are x, y and z coordinates
            if size(lnd, 3) == 3
                reshaped_lnd(:, 1:3:end) = lnd(:, :, 1);
                reshaped_lnd(:, 2:3:end) = lnd(:, :, 2);
                reshaped_lnd(:, 3:3:end) = lnd(:, :, 3);

            % If there are only x and y coordinates
            elseif size(lnd, 3) == 2
                reshaped_lnd(:, 1:2:end) = lnd(:, :, 1);
                reshaped_lnd(:, 2:2:end) = lnd(:, :, 2);

            else
                error(msg_3d_ncoord_wrong);
            end


        case 'interleave2concat'
            if ~ismatrix(lnd)
                error(msg_not_2d);
            end

            % If there are x, y and z coordinates
            if size(lnd, 2) == cfg.landmarks.n_landmarks * 3
                reshaped_lnd = [lnd(:,1:3:end), lnd(:,2:3:end), lnd(:,3:3:end)];

            % If there are only x and y coordinates
            elseif size(lnd, 2) == cfg.landmarks.n_landmarks * 2
                reshaped_lnd = [lnd(:,1:2:end), lnd(:,2:2:end)];

            else
                error(msg_2d_wrong_lnd_dim);
            end
            

        case 'concat2interleave'
            if ~ismatrix(lnd)
                error(msg_not_2d);
            end

            reshaped_lnd = zeros(size(lnd));
            % If there are x, y and z coordinates
            if size(lnd, 2) == cfg.landmarks.n_landmarks * 3
                reshaped_lnd(:, 1:3:end) = lnd(:, 1:end/3);
                reshaped_lnd(:, 2:3:end,:) = lnd(:, end/3+1:2*end/3);
                reshaped_lnd(:, 3:3:end,:) = lnd(:, 2*end/3+1:end);

            % If there are only x and y coordinates
            elseif size(lnd, 2) == cfg.landmarks.n_landmarks * 2
                reshaped_lnd(:, 1:2:end) = lnd(:, 1:end/2);
                reshaped_lnd(:, 2:2:end,:) = lnd(:, end/2+1:end);

            else
                error(msg_2d_wrong_lnd_dim);
            end
            
    end

end