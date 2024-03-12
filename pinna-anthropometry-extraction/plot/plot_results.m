function [] = plot_results(cfg, pinna_imgs, landmarks, info)
% This function plot the features extracted from the pinna images.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) from which the features are
%                 extracted
%                 [# pinna images X height resolution X width resolution]
%   - landmarks: fitted landmarks with x,y and z coordinates
%                [# pinna images X # landmarks X 3 coordinates]
%   - info: structure of the pinna cavities and characteristic points info


    n_pinna_imgs = size(pinna_imgs, 1);

    for n = 1:n_pinna_imgs
        pinna_img = squeeze(pinna_imgs(n, :, :));

        landmark = squeeze(landmarks(n, :, :));
        cav_info = info.cavity_info(1, n);

        fig = figure('WindowState','maximized');
        ax = gca;
    
        plot_landmarks_on_images(pinna_img, landmark(:,1:2), ax, ...
            cfg.plot.heatmap_colormap);

        xlabel('X');
        ylabel('Y');

        title(['Pinna range image: ' num2str(n)]);

        hold on;
        
        % Plot distances
        n_areas = numel(cav_info.area_shape);
        for a = 1:n_areas 
            plot(cav_info.area_shape{a}, 'FaceColor', cfg.plot.cavity_color, ...
                'FaceAlpha', cfg.plot.cavity_alpha, 'EdgeAlpha', cfg.plot.cavity_edge);
            [a_x, a_y] = boundary(cav_info.area_shape{a});

            text_x = max(0, min(landmark(:,1)) - 15);
            text_y = max(0, max(a_y) - 10);

            text(text_x, text_y, ['$C_' num2str(a) '$'], 'Interpreter', 'latex', 'FontSize', cfg.plot.font_size);
            draw_line(fig, [text_x + 5, mean(a_x)], [text_y, text_y], cfg.plot.cavity_color, 'arrow', '', 0.2, false, '-');
        end


        % Plot measurement landmarks
        meas_lnd_idx = unique(cell2mat(struct2cell( ...
            cfg.anthropometry.measurement_landmarks_pairs)));
        meas_lnd_idx = setdiff(meas_lnd_idx, cfg.anthropometry.tragus_landmarks_idx );

        scatter(ax, landmark(:, 1), ...
            landmark(:, 2), ...
            cfg.plot.landmarks_size, 'w', ...
            'o', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.6);

        % Plot landmark per pinna shape part
        for p = 1:numel(cfg.landmarks.pinna_parts_idx)
            scatter(ax, landmark(cfg.landmarks.pinna_parts_idx{p}, 1), ...
                landmark(cfg.landmarks.pinna_parts_idx{p}, 2), ...
                cfg.plot.landmarks_size, cfg.pinna_shape_parts_colors{p}, ...
                'o', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.6, 'MarkerFaceAlpha', cfg.plot.landmarks_alpha);
    
        end

        % Plot measurement landmarks
        scatter(landmark(meas_lnd_idx,1), landmark(meas_lnd_idx,2), cfg.plot.landmarks_size, ...
            'ro', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);

        % Plot tragus
        scatter(info.characteristic_points.tragus.x(n), info.characteristic_points.tragus.y(n), cfg.plot.landmarks_size, ...
            'ro', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);
        text(info.characteristic_points.tragus.x(n)-3, info.characteristic_points.tragus.y(n), ...
            '$\mathbf{t}$', 'Interpreter','latex', 'FontSize',cfg.plot.font_size, 'Color','k');
        % Plot helix
        scatter(info.characteristic_points.helix.x(n), info.characteristic_points.helix.y(n), cfg.plot.landmarks_size, ...
            'ro', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);
        text(info.characteristic_points.helix.x(n), info.characteristic_points.helix.y(n)+2, ...
            '$\mathbf{h}$', 'Interpreter','latex', 'FontSize',cfg.plot.font_size, 'Color','k');


        % Plot anthropometric distances
        metrics_in_fig = fieldnames(cfg.anthropometry.measurement_landmarks_pairs);
        n_metrics_in_fig = numel(metrics_in_fig);
        
        for m = 1:n_metrics_in_fig
    
            m_name = metrics_in_fig{m};
    
            idx = cfg.anthropometry.measurement_landmarks_pairs.(m_name);

            if isempty(idx)
                centroid = cav_info.area_centroid{str2double(m_name(end))};
            
                x = [centroid(1), info.characteristic_points.tragus.x(n)];
                y = [centroid(2), info.characteristic_points.tragus.y(n)];

                scatter(x(1), y(1), 40, 'w', 'o', 'LineWidth', 0.7);

            else

                x = [landmark(idx(2), 1),landmark(idx(1), 1)];
                y = [landmark(idx(2), 2),landmark(idx(1), 2)];
                if idx(1) == cfg.anthropometry.tragus_landmarks_idx
                    x(2) = info.characteristic_points.tragus.x(n);
                    y(2) = info.characteristic_points.tragus.y(n);
                end
            end
            
            metric_number = str2double(m_name(2:end));
            if metric_number <= 7
                col = cfg.plot.arrow_col;
            elseif metric_number >= 11 && metric_number <= 13
                col = cfg.plot.cavity_dist_color;

            elseif metric_number >= 14 && metric_number <= 16
                    col =  cfg.pinna_shape_parts_colors{2};

            elseif metric_number == 17
                    col =  cfg.pinna_shape_parts_colors{4};

            elseif metric_number >= 18
                    col =  cfg.pinna_shape_parts_colors{3};
            end

            draw_line(fig, x, y, col, 'doublearrow', ...
                m_name, cfg.plot.arrow_w, true, '-', 0.7);

            if strcmp(m_name(1), 't')
                m_name(1) = 'θ';
            end
            
            text(mean(x), mean(y), ['$' m_name(1) '_{' m_name(2:end) '}$'], 'Interpreter','latex', 'FontSize',11, 'Color', col);
    
        end

    
        % d5
        x = min(size(pinna_img, 2)-5, max(landmark(:,1)) + 10);
        [max_y, max_y_idx] = max(landmark(:,2));
        [min_y, min_y_idx] = min(landmark(:,2));
        y = [min_y, max_y];
        draw_annotation(fig,[x, x],y,cfg.plot.arrow_col,'doublearrow','d5', cfg.plot.arrow_w, true, '-', 0);
    
        draw_annotation(fig,[x landmark(min_y_idx,1)],[y(1) y(1)],cfg.plot.arrow_col,'line','',0.75,false,'--');
    
        draw_annotation(fig,[x landmark(max_y_idx,1)],[y(2) y(2)],cfg.plot.arrow_col,'line','',0.75,false,'--');
    
        text(x+1, (max(landmark(:,2)) + min(landmark(:,2)))/2, '$d_5$', 'Interpreter','latex','FontSize',cfg.plot.font_size, 'Color',cfg.plot.label_col);
    
    
        % d6
        y = min(5, min(landmark(:,2)) - 10);
        [max_x, max_x_idx] = max(landmark(:,1));
        [min_x, min_x_idx] = min(landmark(:,1));
        x = [min_x, max_x];
        draw_annotation(fig,x,[y,y],cfg.plot.arrow_col,'doublearrow','d6', cfg.plot.arrow_w, true, '-', 0);
    
        draw_annotation(fig,[x(1) x(1)],[y landmark(min_x_idx,2)],cfg.plot.arrow_col,'line','',0.75,false,'--');
    
        draw_annotation(fig,[x(2) x(2)],[y landmark(max_x_idx,2)],cfg.plot.arrow_col,'line','',0.75,false,'--');
    
        text((max(landmark(:,1)) + min(landmark(:,1)))/2, y+2, '$d_6$', 'Interpreter','latex','FontSize',cfg.plot.font_size, 'Color',cfg.plot.label_col);


        % Set font name
        set(ax, 'FontName', cfg.plot.font_name);

    end
    
end