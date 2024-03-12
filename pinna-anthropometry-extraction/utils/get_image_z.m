function [z] = get_image_z(imgs, x, y)
% Given a set of x and y coordinates pairs, return the corresponding z
% values in the range image.
% 
% INPUT
%   - imgs: range images [# pinnae X height resolution X width resolution]
%           If a 2D matrix is received, then it is considered as a single
%           image.
%   - x: x coordinates [# pinnae X # points]
%   - y: y coordinates [# pinnae X # points]
%
% OUTPUT
%   - z: z coordinates [# pinnae X # points]

    if ismatrix(imgs)
        imgs = permute(imgs, [3 1 2]);
    end

    % Number of images
    n_img = size(imgs, 1);
    % Number of points
    n_points = size(x, 2);

    % Initialize z array
    z = zeros(n_img, n_points);

    for n = 1:n_img
        img = squeeze(imgs(n,:,:));
        lin_idx = sub2ind(size(img), max(min(round(y(n,:)), size(img, 1) - 1), 1), ...
            max(min(round(x(n,:)), size(img, 2) - 1), 1));
        z(n,:) = img(lin_idx);
    end

end