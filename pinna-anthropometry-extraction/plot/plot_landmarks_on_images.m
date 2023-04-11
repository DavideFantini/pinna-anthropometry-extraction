function [] = plot_landmarks_on_images(cfg, img, lnd1, lnd2, ax, plot_meas_land)
% Function that plot multiple images with their landamrks on them.
% - img: array of images (y_res X x_res X n_img)
% - lnd: array of landmarks (n_landmarks X n_coordinates X n_img).
%        Assumption: 1st coordiante x, 2nd coordinate y, 3rd coordinate z
%        (optional)

    arguments
        cfg
        img
        lnd1
        lnd2 = []
        ax = []
        plot_meas_land = true
    end

    img = img - 0.001;

%     if ndims(img) == 2
%         img(end, end, 1) = 0;
%     end

    n_img = size(img, 3);

    if plot_meas_land
        measurement_lnd = lnd1(cfg.landmarks.measurement_landmarks_idx, :, :);
    end

    for n = 1:n_img
        if isempty(ax)
            figure('WindowState','maximize');
            ax = gca;
        end
        % 2D landmarks
        if size(lnd1, 2) == 2

            imagesc(ax, img(:,:,n));
            colormap(cfg.heatmap_colormap); axis image; axis xy;
            hold on;

            scatter(ax, lnd1(:, 1, n), lnd1(:, 2, n), 25, 'wo', 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 0.1);

            if ~isempty(lnd2)
                scatter(ax, lnd2(:, 1, n), lnd2(:, 2, n) , 'wx', 'filled', ...
                    'MarkerEdgeColor','k', 'LineWidth', 0.6);
            end
            if plot_meas_land
                % Plot measurement landmark with a different color
                scatter(measurement_lnd(:, 1, n), measurement_lnd(:, 2, n), ...
                    25, 'ro', 'filled','MarkerEdgeColor','k', 'LineWidth', 0.1);
            end

        % 3D landmarks
        elseif size(lnd1, 2) == 3
            % Plot range image
            surf(img(:,:,n),'EdgeColor','none');
            axis tight;
            % Set the color map
            colormap(cfg.heatmap_colormap);
            % Display the color bar
%             colorbar;
            % Set axis labels
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            
            % Set the view of the figure
            view(2);

            hold on;

            scatter3(lnd1(:, 1, n), lnd1(:, 2, n) , lnd1(:, 3, n), 25, ...
                'wo', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);
            if ~isempty(lnd2)
                scatter3(lnd2(:, 1, n), lnd2(:, 2, n) , lnd1(:, 3, n), ...
                    'wx', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.6);
            end
            
            if plot_meas_land
                % Plot measurement landmark with a different color
                scatter3(measurement_lnd(:, 1, n), measurement_lnd(:, 2, n), ...
                    measurement_lnd(:, 3, n), 'ro', 'filled', ...
                    'MarkerEdgeColor','k', 'LineWidth', 0.1);
            end
        end

    end

    set_plot_style(gcf);

end