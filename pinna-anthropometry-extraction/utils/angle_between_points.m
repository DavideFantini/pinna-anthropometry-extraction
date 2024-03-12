function [angle] = angle_between_points(p1, p2, unit)
% This function compute the angle in radians between pairs of points
%
% INPUT
%  - x1: first set of points [n_points X 2 coordinates (x, y)]
%  - x2: second set of points [n_points X 2 coordinates (x, y)]
%  - unit: unit of measurement ['rad', 'deg']
%
% OUTPUT
%  - angle: angle

    arguments
        p1
        p2
        unit = 'rad'

    end

    angle = atan2(p2(:,2) - p1(:,2), p2(:,1) - p1(:,1));

    if strcmp(unit, 'deg')
        angle = rad2deg(angle);
    end
end