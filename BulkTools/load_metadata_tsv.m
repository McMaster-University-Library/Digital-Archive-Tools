function [C, H1, H2, H3] = load_metadata_tsv(meta_sheet)

%%% Loading the raw spreadsheet; reforming data:
fid = fopen([meta_sheet],'r');
tline = fgets(fid);

%%% Figure out how many columns there are in the file:
startIndex = regexp(tline,'\t'); numcols = size(startIndex,2)+1;
fmt = repmat('%s',1,numcols); %create the format string for reading:
frewind(fid); %rewind the pointer to the start of the file:

%%% Load the file using textscan. Reform it until it's in a first-level
%%% cell structure
tmp = textscan(fid,fmt,'Delimiter','\t','TreatAsEmpty',{'NA','na'});
C = {};

%%% Fix a problem with Google Sheet export where the final column has one
%%% less element in it than the others.
if length(tmp{1,1}) - length(tmp{1,end}) == 1
    tmp{1,end}{length(tmp{1,end})+1,1} = '';
end

% Remove quotations (removed as of 08-Aug-2016); Collect header information
% replace '&' with '&amp;' (added 08-Aug-2016):
for i = 1:1:size(tmp,2)
    %     C(:,i) = strrep(tmp{1,i}(:,1),'"',''); % remove all quotation marks from tmp and assign it a column in C
    C(:,i) = strrep(tmp{1,i}(:,1),'&','&amp;'); % remove all quotation marks from tmp and assign it a column in C
    H1{i,1} = C{1,i};
    H2{i,1} = C{2,i};
    H3{i,1} = C{3,i};
end
clear tmp;
fclose(fid);