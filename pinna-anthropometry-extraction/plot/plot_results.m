function [] = plot_results(cfg, pinna_imgs, anthropometry, landmarks, reg_info)
% This function plot the features extracted from the pinna images.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) from which the features are
%                 extracted
%                 [# pinna images X height resolution X width resolution]
%   - anthropometry: table with the measured anthropometry. The columns
%                    represent the anthropometric parameters, while the
%                    rows represent the pinnae
%                    [# pinna images X # anthropometry]
%   - landmarks: fitted landmarks with x,y and z coordinates
%                [# pinna images X # landmarks X 3 coordinates]
%   - reg_info: structure of the pinna regions info

    n_pinna_imgs = size(pinna_imgs, 1);

    for n = 1:n_pinna_imgs
        pinna_img = squeeze(pinna_imgs(n, :, :));
        landmark = squeeze(landmarks(n, :, :));

        fig = figure('WindowState','maximized');
        ax = gca;
    
        plot_landmarks_on_images(cfg, pinna_img, landmark, ax);

        hold on;

        % Plot measurement landmarks
        meas_lnd_idx = unique(cell2mat(struct2cell( ...
            cfg.anthropometry.measurement_landmarks_pairs)));
        scatter3(landmark(meas_lnd_idx,1), landmark(meas_lnd_idx,2), ...
            landmark(meas_lnd_idx,3), ...
            'ro', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);

    end
end