function [] = bulk_rename(file_dir,rename_list_path)
%%% This function attempts to rename all files in a directory (specified by
%%% file_dir) according to a lookup table, whose path is specified by
%%% rename_list.
%
%
%
% inputs:
% file_dir: The full path of the directory containing files to be renamed
% rename_list_path: A lookup table formatted as a two-column csv file. The table
% is structured as: | filename_in,filename_out |
%

rename_list_path = 'E:\Italy_50k\rename.csv';
file_dir = 'E:\Italy_50k\';

%% Load the rename list
fid = fopen([rename_list_path],'r');
tline = fgetl(fid);
numcols = length(regexp(tline,','))+1;
formatspec = repmat('%s',1,numcols);
D = textscan(fid,formatspec,'Delimiter',',');

% Restructure into a flatter cell array; Remove quotation marks.
for pp = 1:1:size(D,2)
    %     isString = cellfun('isclass', D{1,pp}, 'char');
    %     D{1,pp}(isString) = strrep(D{1,pp}(isString), '"', '');
    rename_list(:,pp) = D{1,pp}(1:end,1);
end

%% Run through directory; rename files that have an entry
clear D;

d = dir(file_dir);

for i = 3:1:length(d)
    right_row = find(strcmp(d(i).name,rename_list(:,1))==1);
    
    if ~isempty(right_row)==1
        status = movefile([file_dir d(i).name],[file_dir rename_list{right_row,2}]);
        if status==1
            disp(['Renamed file ' d(i).name ' --> ' rename_list{right_row,2}]);
        else
            disp(['Failed to rename file ' d(i).name]);
        end
    end
    
end
