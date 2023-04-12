function [pinna_imgs] = pinna_images_preprocessing(cfg, pinna_imgs, right_pinna)
%This function pre-process the pinna images for the features extraction
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) to pre-process
%                 [# pinna images X height resolution X width resolution]
% OUTPUT
%   - pinna_imgs: pre-processed pinna range image(s)
%                 [# pinna images X height resolution X width resolution]


    n_pinna_img = size(pinna_imgs, 1);

    % =========================== IMAGE RESIZE ========================== %
    % Resize image to get a similar size to the ones of the original images
    % used to train the ASM model
    height = size(pinna_imgs, 2);
    width = size(pinna_imgs, 3);
    scale_height = cfg.img_height / height;
    scale_width = cfg.img_width / width;
    pinna_imgs = permute(imresize(shiftdim(pinna_imgs,1), ...
        mean([scale_height, scale_width])), [3,1,2]);


    % =========================== RIGHT PINNAE ========================== %
    % Flip right pinnae
    for n = 1:n_pinna_img
        if right_pinna(n)
            pinna_imgs(n,:,:) = flip(pinna_imgs(n,:,:), 3);
        end
    end

end