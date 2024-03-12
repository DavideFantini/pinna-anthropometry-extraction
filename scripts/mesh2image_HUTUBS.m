%-------------------------------------------------------------------------%
%   SCRIPT TO CONVERT THE HUTUBS 3D HEAD MESHES INTO PINNA RANGE IMAGES   %
%-------------------------------------------------------------------------%

% Set your path to the HUTUBS 3D head meshes
path = '.\HUTUBS\3D head meshes\';

% Add the needed folders to the Path
addpath(genpath('../pinna-anthropometry-extraction/'));

% Get configuration struct
cfg = get_cfg();

[file_list, n_files] = file_retrieve(path, 'ply');

ear_pit_position=[75, 60];

y_range=0.08;
ratio=y_range/cfg.img_height;

x_range=ratio*cfg.img_width;

x_lim=[0,(ear_pit_position(2)/cfg.img_width)*x_range];
x_lim(1)=x_lim(2)-x_range;
y_lim=[-(ear_pit_position(1)/cfg.img_height)*y_range, 0];
y_lim(2)=y_lim(1)+y_range;

x_lim_rot=[-x_lim(2),-x_lim(1)];

subjects_idx=zeros(n_files,1);

range_img_l=zeros(cfg.img_height,cfg.img_width,n_files);
range_img_r=zeros(cfg.img_height,cfg.img_width,n_files);

% Rotation matrices
rot_ang1=-pi/2;
rot_mat1=[1 0 0; 0 cos(rot_ang1) -sin(rot_ang1) ; 0 sin(rot_ang1) cos(rot_ang1)];

rot_ang2=pi;
rot_mat2=[cos(rot_ang2) -sin(rot_ang2) 0; sin(rot_ang2) cos(rot_ang2) 0; 0 0 1];

for n=1:n_files

    subjects_idx(n)=str2num(file_list(n).name(3:4));

    disp(['Converting mesh ' num2str(n) ' of ' num2str(n_files)]);
    ptCloud = pcread([file_list(n).folder '\' file_list(n).name]);
    
    pts=ptCloud.Location;

    pts=pts( pts(:,1)>x_lim(1) & pts(:,1)<x_lim(2) & pts(:,3)>y_lim(1) & pts(:,3)<y_lim(2),:);

    pts_l=pts(pts(:,2)>0,:);
    pts_r=pts(pts(:,2)<0,:);

%         plot_scatter3(pts);
%         hold on;
%         scatter3([0],[-0.1],[0],30,'Marker','o');
%         view(0,0);
%         hold off; 

    pts_l=pts_l*rot_mat1*rot_mat2;
    pts_r=pts_r*rot_mat1*rot_mat2;
    pts_r(:,3)=abs(pts_r(:,3));

    range_img_l(:,:,n)=pointCloud2image(pts_l,cfg.img_width,cfg.img_height,x_lim_rot,y_lim);
    range_img_r(:,:,n)=pointCloud2image(pts_r,cfg.img_width,cfg.img_height,x_lim_rot,y_lim);

end

ear_img=cat(3,range_img_l,range_img_r);



function [img] = pointCloud2image(pts,x_res,y_res,x_lim,y_lim)

    X=linspace(x_lim(1),x_lim(2),x_res);
    Y=linspace(y_lim(1),y_lim(2),y_res);

    pts_kept=zeros(size(pts,1),1);

    % Remove overlappinng points
    for y=1:numel(Y)-1
        for x=1:numel(X)-1
            idxs=pts(:,1)>X(x) & pts(:,1)<X(x+1) &...
                                    pts(:,2)>Y(y) & pts(:,2)<Y(y+1);

            [~,idx]=max(pts(idxs,3));
            idxs=find(idxs);
            idx=idxs(idx);
            pts_kept(idx)=1;

        end
    end

    pts=pts(pts_kept==1,:);

    % INTERPOLATION
    pts = double(pts);

    % Create a scattered data interpolant object
    F=scatteredInterpolant(pts(:,1),pts(:,2),pts(:,3),'natural','none');
    
    % Create a mesh grid
    [qx,qy] = meshgrid(linspace(x_lim(1),x_lim(2),x_res),linspace(y_lim(1),y_lim(2),y_res));
    
    % Evaluate the scattered interpolant on the mesh grid
    img = F(qx,qy);

    img=imclose(img,ones(3,3));

    % Replace NaNs with 0
    img(isnan(img))=0;

%     figure;
%     imagesc(img);colormap(jet); axis xy; axis equal;
 
end
