function [img_features] = extract_img_features(cfg, pinna_imgs, reg_info)
% This function extract the features from pinna images cavities.
%
% INPUT
%   Required:
%   - cfg: configuration structure
%   - pinna_imgs: pinna range image(s) from which the features are
%                 extracted
%                 [# pinna images X height resolution X width resolution]
%   - reg_info: structure of the pinna regions info
%
% OUTPUT
%   - img_features: extracted image features
%                   [# pinna images X # image features]


    arguments
        cfg
        pinna_imgs (:,:,:) {mustBeNumeric}
        reg_info {isstruct}
    end

    if cfg.verbose >= 1
        disp('IMAGE FEATURES EXTRACTION');
    end

    n_pinna_imgs = size(pinna_imgs, 1);
    n_areas = numel(reg_info.area_range);

    for n = 1:n_pinna_imgs
        if cfg.verbose >= 2
            disp(['Extracting features from image ' num2str(n) '/' ...
                num2str(n_pinna_imgs) ' ...']);
        end

        f_idx_start = 1;

        for a = 1:n_areas
            
            % Get area
            area_img = squeeze(pinna_imgs(n, ...
                floor(reg_info.area_range{a}.y_range(n,1)):ceil(reg_info.area_range{a}.y_range(n,2)), ...
                floor(reg_info.area_range{a}.x_range(n,1)):ceil(reg_info.area_range{a}.x_range(n,2))));

            % Apply Gabor filter
            gabor_array = gabor(cfg.img_features.gabor.wavelength, ...
                cfg.img_features.gabor.orientation);
            gabor_mag = imgaborfilt(area_img, gabor_array);

            img_for_feat = cat(3, area_img, gabor_mag);

            n_img = size(img_for_feat, 3);

            % Iterate over images for feature extraction
            for im = 1:n_img

                % Features extraction LBP

                f = extractLBPFeatures(img_for_feat(:,:,im), ...
                    'Upright', cfg.img_features.lbp.upright, ...
                    'NumNeighbors', cfg.img_features.lbp.n_neighbors, ...
                    'Radius', floor(min(cfg.img_features.lbp.radius, min(size(img_for_feat, 1), size(img_for_feat, 2))/2-1)), ...
                    'Normalization', cfg.img_features.lbp.norm)';

                if ~exist('features', 'var')
                    single_feat_len = size(f, 1);
                    img_features = zeros(n_pinna_imgs, single_feat_len * n_img * n_areas);
            
                end

                img_features(n, f_idx_start:f_idx_start+size(f,1)-1) = f;

                f_idx_start = f_idx_start + size(f,1);

            end
            

        end

    end


end