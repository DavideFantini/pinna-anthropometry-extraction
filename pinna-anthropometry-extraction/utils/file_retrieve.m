function [file_list, n_files] = file_retrieve(source_path, extension, pattern)
% --------------------------- DESCRIPTION ------------------------------- %
% This function retrieves all the files in the specified source path with
% the desired extension.
%
% ----------------------------- INPUTS ---------------------------------- %
%   - source_path: directory in which retireve the files
%   - extension: desidered extension of the retrieved files
%
% ----------------------------- OUTPUTS --------------------------------- %
%   - file_list: list containing all the retrieved files
%   - n_files: numeber of retrieved files

    if nargin<3
        pattern='';
    else
        pattern=strcat('*',pattern);
    end

    % Retrieving of the files in the source path with the specified
    % extension
    file_list = dir([source_path pattern '*.' extension]);
    
    % Number of retrieved files
    n_files = length(file_list);
    
    % If in the directory there aren't files with the specified extension
    % an error is thrown
    if ~n_files
        error(['No files found in ' source_path]);
    end

end