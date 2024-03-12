function [] = plot_landmarks_on_images(pinna_img, lnd, ax, cmap)
% Function that plot multiple images with their landamrks on them.
% - img: array of images (y_res X x_res X n_img)
% - lnd: array of landmarks (n_landmarks X n_coordinates X n_img).
%        Assumption: 1st coordiante x, 2nd coordinate y, 3rd coordinate z
%        (optional)

    arguments
        pinna_img
        lnd
        ax = []
        cmap = 'gray'
    end


    pinna_img = pinna_img - 0.01;

    % Number of landmarks coordinates
    n_coord = size(lnd, 2);

    if isempty(ax)
        figure('WindowState','maximize');
        ax = gca;
    end

    % 2D landmarks
    if n_coord == 2

        imagesc(ax, pinna_img);
        colormap(cmap); axis image; axis xy;
        hold on;

        scatter(ax, lnd(:, 1), lnd(:, 2), 25, 'wo', 'filled', ...
            'MarkerEdgeColor','k', 'LineWidth', 0.1);


    % 3D landmarks
    elseif n_coord == 3
        % Plot range image
        surf(pinna_img,'EdgeColor','none');
        axis tight;

        % Set the color map
        colormap(cmap);

        % Display the color bar
        colorbar;

        % Set axis labels
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        
        % Set the view of the figure
        view(2);

        % Set data aspect ratio
        h = get(ax,'DataAspectRatio');
        set(ax,'DataAspectRatio',[1 1 1/max(h(1:2))])

        hold on;

        scatter3(lnd(:, 1), lnd(:, 2) , lnd(:, 3), 25, ...
            'wo', 'filled', 'MarkerEdgeColor','k', 'LineWidth', 0.1);

    end


end