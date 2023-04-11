function varargout = plotLandmarks(landmarks,varargin)
% PLOTLANDMARKS plots all of the aligned landmarks from an active shapes model
%
%	INPUT
%       landmarks: The aligned landmarks from multiple images
%                  [2*n_landmarks x n_shapes]
%       OPTIONAL
%           show_lines: 
%           hold:
%
%   See also PLACELANDMARKS, ALIGNSHAPES
%
% John W. Miller
% 14-Mar-2017

% Key-value pair varargin
keys = {'show_lines','hold','color','linewidth','linestyle','point_color','pinna_parts_idx','im'};
default_values = {1,0,'m',1,'-','k',{1:size(landmarks,1)/2},[]};
[show_lines,hold_on,line_color,lw,ls,point_color,pinna_parts_idx,im] = parseKeyValuePairs(varargin,keys,default_values);

% Plot the landmarks for each shape
n_shapes = size(landmarks,2);
if hold_on
    h = gcf;
else
    h = figure('WindowState','maximize');
    imagesc(im); axis xy; axis equal; axis tight; colormap(jet);
end
hold on
try colors = parula(n_shapes);
catch
    colors = hsv(n_shapes);
end
for n_shape = 1:n_shapes
    iShape = [landmarks(1:2:end,n_shape) landmarks(2:2:end,n_shape)];
%     plot(iShape(:,1),iShape(:,2),'o','color', colors(n_shape,:),...
%         'linewidth',2,'markersize',2,'markerfacecolor',colors(n_shape,:))
    plot(iShape(:,1),iShape(:,2),'o','color', point_color,...
        'linewidth',2,'markersize',4,'markerfacecolor',point_color)
end

% Add mean shape to the plot
if n_shapes > 1
    meanShape = mean(landmarks,2); % x1, y1, x2, y2, ..., x20, y20
else
    meanShape = landmarks;
end
ax = plot(meanShape(1:2:end),meanShape(2:2:end),'ko',...
    'markersize',5,'linewidth',1,'markerfacecolor','k');

% Connect dots on the face (optional)
if show_lines    
%     faceLabels = getFaceRegions(face_layout);
    
    mew = [meanShape(1:2:end) meanShape(2:2:end)];
    for i = 1:length(pinna_parts_idx)
        mew_handle = plot(mew(pinna_parts_idx{i},1), mew(pinna_parts_idx{i},2),...
            'linestyle',ls,'color',line_color,'linewidth',lw);
    end
%     mew_handle = plot(mew(:,1), mew(:,2),...
%             'linestyle',ls,'color',line_color,'linewidth',lw);
end

% % Touch up the plot
% if ~hold_on
%     legend(ax,{'Mean shape'},'fontsize',FS,'location','southeast')
%     text(0.05,0.5,sprintf('n=%d',n_shapes),'units','normalized','fontsize',FS,'fontweight','bold')
% end
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
axis off
% set(gca,'YDir','reverse');
drawnow

% Varargout
if nargout > 0
    varargout{1} = mew_handle;
end

end % End of main