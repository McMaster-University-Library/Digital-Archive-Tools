function [] = aerialphoto_digarc_scraper(macrepo_start, macrepo_end, master_path)
%%% aerialphoto_digarc_scraper.m
% The purpose of this script is to build a lookup table between identifiers 
% and URLs for each Hamilton-area air photo on the digital archive. 
% This script crawls through URLs on the digital archive (by incrementing
% the macrepo numbers), parses the HTML, and for only items in the air
% photo collection, extracts the identifier and URL for that object. 
% The range of URLs is specified by the 'macrepo_start' and 'macrepo_end'
% input arguments. 
%
%
% example:
% [] = aerialphoto_digarc_scraper(82000, 85000);

%% Paths and input values:
%%% If no input arguments are provided, search the entire potential range:
if nargin==0
 macrepo_start = 65000;
 macrepo_end = 85000;
  disp('no starting or ending macrepo numbers were specified--running for the entire potential range');
end

%%% If no starting path is provided, use the default
if nargin < 3
    % modify this path if you would like to change the default:
master_path = 'D:\GDrive\jason.brodeur@gmail.com\Library\Maps, Data & GIS\Projects\Aerial (Air) Photo Index Refresh\Matlab Scripts\';
disp('no master_path variable inputted-- using the default path set inside of function');
end

%%%%% 
cd(master_path);
url_start = 'http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A';

%% Run through each URL

output_table = {};
tic;
for i = macrepo_start:1:macrepo_end
    the_url = [url_start num2str(i)];
    if rem(i,500)==0
        t = toc;
        disp(['Page ' num2str(i-macrepo_start+1) ' completed. Total time: ' num2str(t)]);
    end
    try
        html = urlread(the_url);
       
        % Look for a unique identifying string in the html that identifies
        % this as an aerial photo:
        a = strfind(html,'<td>AirPhotos_');  % a = strfind(html,'<td>Identifier</td>');
        if isempty(a)
            continue;
        end
        % If we find the identifying string, pull out the URL and
        % identifier from the HTML:
        snippet = html(a+4:a+80);
        b = strfind(snippet,'</td>');
        ident = snippet(1:b-1);
        output_table{size(output_table,1)+1,1} = the_url;
        output_table{size(output_table,1),2} = ident;
        disp(['worked for ' num2str(i)]);
    catch
    end
end

%% Write to the Output File:
% fid = fopen([master_path 'URLtableout.csv'],'w');
fid = fopen([master_path 'Airphotos-URL_Identifier_Lookup.csv'],'a');

for i = 1:1:size(output_table,1)
fprintf(fid,'%s, %s\n',output_table{i,:});
end
fclose(fid);