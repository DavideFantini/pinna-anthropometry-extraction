function [features] = extract_img_features(cfg, img, area_coord)
% Extract features from pinna images cavities


    n_ears = size(img,3);
    n_areas = numel(area_coord);

    for n = 1:n_ears

        f_idx_start = 1;

        for a = 1:n_areas
            
            % Get area
            area_img = img(floor(area_coord{a}.y_range(n,1)):ceil(area_coord{a}.y_range(n,2)), ...
                floor(area_coord{a}.x_range(n,1)):ceil(area_coord{a}.x_range(n,2)), ...
                n);

            % Apply Gabor filter
            if ~isempty(cfg.img.features.gabor.wavelength)
                gabor_array = gabor(cfg.img.features.gabor.wavelength, ...
                    cfg.img.features.gabor.orientation);
                gabor_mag = imgaborfilt(area_img, gabor_array);

                img_for_feat = cat(3, area_img, gabor_mag);

            else
                img_for_feat = area_img;
            end

            n_img = size(img_for_feat, 3);

            % Iterate over images for feature extraction
            for im = 1:n_img

                % Features extraction
                % LBP
                switch cfg.img.features.to_extract
                    case 'raw'
                        f = reshape(img_for_feat(:,:,im), ...
                            [size(img_for_feat, 1) * size(img_for_feat, 2), 1]);

                        if ~exist('features', 'var')
                            single_feat_len1 = size(f, 1);
                            single_feat_len2 = numel(floor(area_coord{2}.y_range(n,1)):ceil(area_coord{2}.y_range(n,2))) * ...
                                numel(floor(area_coord{2}.x_range(n,1)):ceil(area_coord{2}.x_range(n,2)));
                            single_feat_len3 = numel(floor(area_coord{3}.y_range(n,1)):ceil(area_coord{3}.y_range(n,2))) * ...
                                numel(floor(area_coord{3}.x_range(n,1)):ceil(area_coord{3}.x_range(n,2)));
                            features = zeros(n_ears, (single_feat_len1 + single_feat_len2 + single_feat_len3)* n_img);
                    
                        end

                    case 'lbp'
                        f = extractLBPFeatures(img_for_feat(:,:,im), ...
                            'Upright', cfg.img.features.lbp.upright, ...
                            'NumNeighbors', cfg.img.features.lbp.n_neighbors, ...
                            'Radius', floor(min(cfg.img.features.lbp.radius, min(size(img_for_feat, 1), size(img_for_feat, 2))/2-1)), ...
                            'Normalization', cfg.img.features.lbp.norm)';

                        if ~exist('features', 'var')
                            single_feat_len = size(f, 1);
                            features = zeros(n_ears, single_feat_len * n_img * n_areas);
                    
                        end

                    case 'hog'
                        f = extractHOGFeatures(img_for_feat(:,:,im));
                end

                features(n, f_idx_start:f_idx_start+size(f,1)-1) = f;

                f_idx_start = f_idx_start + size(f,1);

            end
            

        end

    end


end