function [] = draw_line(fig,x,y,col,ann_type,str,width, head, style, margin)
% This function draw a line on a figure

    arguments
        fig
        x
        y
        col
        ann_type
        str = ''
        width = 0.5
        head = false
        style = '-'
        margin = 0
    end
    

    line_angle = angle_between_points([x(1) y(1)], [x(2) y(2)], 'deg');
    
    x(1) = x(1) + margin * cosd(line_angle);
    x(2) = x(2) - margin * cosd(line_angle);
    y(1) = y(1) + margin * sind(line_angle);
    y(2) = y(2) - margin * sind(line_angle);

    if strcmp(ann_type, 'textarrow')

        str = ['$' str(1) '_{' str(2:end) '}$'];
        ha = annotation(ann_type,'String',str, 'LineStyle',style, 'FontSize',14);
        ha.Interpreter = 'latex';
        ha.FontName = 'Consolas';

    else

        ha = annotation(ann_type,'LineStyle',style);

    end

    ha.Parent = fig.CurrentAxes;
    ha.X = x;
    ha.Y = y;

    ha.Color = col;

    ha.LineWidth = width;

    if head && strcmp(ann_type, 'doublearrow')

        ha.HeadStyle = 'none';
        head_angle = 45;
        head_size = 0.9;

        x1 = x(1) + head_size * cosd(line_angle + head_angle);
        y1 = y(1) + head_size * sind(line_angle + head_angle);

        x2 = x(1) + head_size * cosd(line_angle - head_angle);
        y2 = y(1) + head_size * sind(line_angle - head_angle);


        an = annotation('line','LineStyle','-');
        an.Parent = fig.CurrentAxes;
        an.X = [x(1) x1];
        an.Y = [y(1) y1];
        an.Color = col;
        an.LineWidth = width;
        an = annotation('line','LineStyle','-');
        an.Parent = fig.CurrentAxes;
        an.X = [x(1) x2];
        an.Y = [y(1) y2];
        an.Color = col;
        an.LineWidth = width;


        x1 = x(2) + head_size * cosd(line_angle + head_angle + 180);
        y1 = y(2) + head_size * sind(line_angle + head_angle + 180);

        x2 = x(2) + head_size * cosd(line_angle - head_angle + 180);
        y2 = y(2) + head_size * sind(line_angle - head_angle + 180);

        an = annotation('line','LineStyle','-');
        an.Parent = fig.CurrentAxes;
        an.X = [x(2) x1];
        an.Y = [y(2) y1];
        an.Color = col;
        an.LineWidth = width;
        an = annotation('line','LineStyle','-');
        an.Parent = fig.CurrentAxes;
        an.X = [x(2) x2];
        an.Y = [y(2) y2];
        an.Color = col;
        an.LineWidth = width;
        
    end

    if ~head && ~strcmp(ann_type, 'line')
        ha.HeadStyle = 'none';
    end

end