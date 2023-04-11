function [gaussian] = gaussian2D(mu,variance,y_res,x_res)
% --------------------------- DESCRIPTION ------------------------------- %
% This function return a matrix containing a 2D Gaussian.
%
% ----------------------------- INPUTS ---------------------------------- %
%   - mu: Gaussian mean
%   - variance: Gaussian variance
%   - x_res: x resolution
%   - y_res: y resolution
%
% ----------------------------- OUTPUTS --------------------------------- %
%   - gaussian: output 2D Gaussian


    % Create a mesh grid
    [X,Y]=meshgrid(linspace(1, x_res,x_res),linspace(1, y_res,y_res));
    
    % Compute the 2D Gaussian
    gaussian=exp(-((X-mu(2)).^2/(2*variance))-((Y-mu(1)).^2/(2*variance)));

end