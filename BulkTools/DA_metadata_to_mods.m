function [] = DA_metadata_to_mods(working_dir, meta_sheet,title_flag)
% Generates Digital-Archive upload-ready xml MODS files from a spreadsheet.
% Spreadsheet should be exported from https://docs.google.com/spreadsheets/d/1xmSuWdqUQ0a9RNCi2DErNO1bBcK6J06ps0moyYkg4Qk
%
% inputs:
% working_dir is the directory containing the (tab-delimited) metadata sheet (meta_sheet), and where MODS output will take place.
% meta_sheet is the filename of the metadata spreadsheet to be processed
% title_flag = 0: use title field to generate title; title_flag = 1: generate aerial-photo title from multiple fields
%
% example: DA_metadata_to_mods('D:\Local\GordonGriffiths','Gordon Griffith Fonds.tsv',0)
%
%%%% Preparation
% 1. Download the metadata spreadsheet as a tab-separated file
% (e.g. https://docs.google.com/spreadsheets/d/17hx390QwHaXibQ7wm3ZNIdbLaB-KDLBNABk08XPBJCg/edit#gid=1930434503)
% (e.g.2 https://docs.google.com/spreadsheets/d/180qQStP5EkeY_3a4eM5lXcDYv3QY4zFq4l5bx3BZ8m0/edit#gid=0)
% 2. Ensure that the relevant headers are on the third row of the spreadsheet, and have names that match the field names
% listed below.
% 3. Run this function, providing the appropriate path and metadata sheet filename

if nargin==2
    title_flag = 0;
end

% Display error message and exist if the working_dir directory is not found
if exist([working_dir],'dir')~=7
    disp(['Inputted working directory can''t be found: ' working_dir]);
    return;
else
end

% ensure that the path is structured with a trailing '\'
if strcmp(working_dir(end),'\')~=1
    working_dir = [working_dir '\'];
end
% working_dir = 'D:\Dropbox (MUL)\Library\Maps, Data, GIS\AirPhotoIndex\AirPhoto_Metadata\';

cd(working_dir);

%%% Check to see if the '\MODS\ directory exists in the master directory.
%%% If not, create it.
if exist([working_dir 'MODS\'],'dir')~=7
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(working_dir,'MODS');
    disp(['Output Folder \MODS\ was successfully created in ' working_dir]);
end

%%% Possible incoming fields:
% title             pseudotitle             subtitle        date_in         flightline      photo_number    scale
% latitude          longitude               thumbnail_link	archive_link    corporate_name	personal_name
% publisher_name	publisher_location	publisher_location2(additional)
% set_date          physical_description    media_type	general_note	subj_geographic
% continent           country                 province        region          county          city
% city_section      area                    index           condition_notes
% identifier

%% % Load the master spreadsheet (Master Spreadsheet.tsv)
%%% figure out how many columns it has, so that we can load the rest of the items:

%%% Loading the raw spreadsheet; reforming data:
fid = fopen([working_dir meta_sheet],'r');
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
%%% Define constants:
% type_of_resource = 'cartographic';
% genre_loc = 'Aerial photographs';
language = 'eng';
% physical_form = 'remote-sensing image';

%%% Figure out the column assignments in the master file:
col_id = find(strcmp('identifier',H3)==1);      col_tit = find(strcmp('title',H3)==1);
col_pseutit = find(strcmp('pseudotitle',H3)==1); col_type = find(strcmp('type_of_resource',H3)==1);
col_photo = find(strcmp('photo_number',H3)==1); col_fline = find(strcmp('flightline',H3)==1);

col_sub = find(strcmp('subtitle',H3)==1);       col_ca = find(strcmp('corporate_name',H3)==1);
col_pa = find(strcmp('personal_name',H3)==1);   col_dc = find(strcmp('date_in',H3)==1);
col_do = find(strcmp('date_other',H3)==1);

col_pub = find(strcmp('publisher_name',H3)==1); col_pubpl = find(strcmp('publisher_location',H3)==1);
col_pubpl2 = find(strcmp('publisher_location2',H3)==1);
col_pe = find(strcmp('scale',H3)==1);           col_pn = find(strcmp('physical_description',H3)==1);
col_note = find(strcmp('general_note',H3)==1);  col_pf= find(strcmp('physical_form',H3)==1);
col_genre = find(strcmp('genre_loc',H3)==1);    col_mt = find(strcmp('media_type',H3)==1);
col_pl = find(strcmp('physical_location',H3)==1);

col_sg = find(strcmp('subj_geographic',H3)==1); %multicolumn
col_topic = find(strcmp('subj_topic',H3)==1);

col_cont = find(strcmp('continent',H3)==1);     col_country = find(strcmp('country',H3)==1);
col_prov = find(strcmp('province',H3)==1);      col_reg = find(strcmp('region',H3)==1);
col_county = find(strcmp('county',H3)==1);      col_city = find(strcmp('city',H3)==1);
col_csec = find(strcmp('city_section',H3)==1);   col_area = find(strcmp('area',H3)==1);
col_long = find(strcmp('longitude',H3)==1);     col_lat = find(strcmp('latitude',H3)==1);
%
%% Creating the output xml files
out_check = cell(size(C,1)-3,2);
for i = 4:1:size(C,1)
    try
        %%% Generate all 'item-specific' fields that are required
        
        %%%%%% Fix up date formats (if necessary)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Format will be either YYYY or MM/DD/YYYY
        % We need it in YYYY-MM-DD
        date_created = C{i,col_dc};
        slash_find = strfind(date_created,'/');
        dash_find = strfind(date_created,'-');
        % Date formats that are OK as-is
        if size(date_created,2)==4 || ... % just the year
                size(date_created,2)==0 || ... % blank
                length(strfind(date_created,'['))==1 || ... % has inferred date
                (length(dash_find)>=1 && dash_find(1)>3) % in YYYY-MM-DD or YYYY-MM format (changed from (dash_find)==2 to (dash_find)>=1
            % Fix if in MM/DD/YYYY
        elseif size(date_created,2)>=8 && length(slash_find)==2 %assume we have the date in MM/DD/YYYY
            date_created = [date_created(end-3:end) '-' date_created(1:slash_find(1)-1) '-' date_created(slash_find(1)+1:slash_find(2)-1)];
        else
            disp(['Cannot convert date format for: ' date_created '. Setting to blank.']);
            date_created = '';
        end
        % Date-other is a stripped-down version of Date ("[" and "]" and "?" removed);
        %     date_other = strrep(C(:,col_dc),'[',''); date_other = strrep(date_other,']',''); date_other = strrep(date_other,'?','');
        if isempty(col_do)==1
            date_other = strrep(date_created,'[',''); date_other = strrep(date_other,']',''); date_other = strrep(date_other,'?','');
        else
            date_other = C{i,col_do};
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate Coordinates: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isempty(col_lat)==1 || isempty(C{i,col_lat})==1 || isempty(col_long)==1 || isempty(C{i,col_long})==1
            coords = '';
        else
            coords = ['latitude ' C{i,col_lat} ' ; longitude ' C{i,col_long}];
        end
        
        
        switch title_flag
            case 1
                %%%%% Generate Title %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                flightline = C{i,col_fline}; if isempty(flightline)==0; t_flightline = ['Flightline ' flightline]; flightline = ['_' flightline] ; else t_flightline = ''; end
                photo = C{i,col_photo}; if isempty(photo)==0; t_photo = ['Photo ' photo]; else t_photo = ''; end
                
                if ~isempty(flightline)+~isempty(photo)>0 % if at least one of the two fields is not empty
                    sq1 = ' : [';
                    sq2 = ']';
                    join = '-';
                else
                    sq1 = '';
                    sq2 = '';
                    join = '';
                end
                
                if ~isempty(flightline)+~isempty(photo)==2 % if both fields have content
                    Tjoin = '-';
                    iTitle = '';
                elseif ~isempty(flightline)+~isempty(photo)==0 % if both are empty
                    Tjoin = '';
                    iTitle = ['-' C{i,col_tit}];
                    iTitle=strrep(iTitle,'" "','');
                    iTitle=strrep(iTitle,'[','');
                    iTitle=strrep(iTitle,']','');
                    iTitle=strrep(iTitle,'/','');
                    iTitle=strrep(iTitle,',','');
                else
                    Tjoin = '';
                    iTitle = '';
                end
                
                %Make the title string
                if isempty(C{i,col_tit})==0 %format for if the air photo has a title on it (aka the very first column has content)
                    title = [C{i,col_tit} sq1 t_flightline Tjoin t_photo sq2];
                else
                    title = ['[' C{i,col_pseutit} ', ' date_other ']' sq1 t_flightline Tjoin t_photo sq2];
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            otherwise
                title = C{i,col_tit};
        end
        %%%%%%%%%%%%%%%%%% WRITE the XML MODS file %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% open the file (or create it)
        fid2 = fopen([working_dir 'MODS\' C{i,col_id} '.xml'],'w','n','UTF-8');
        % preamble
        fprintf(fid2,'%s\n','<?xml version="1.0" encoding="UTF-8"?><mods xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd">');
        fprintf(fid2,'%s\n','<accessCondition/>');
        
        % identifier
        fprintf(fid2,'%s\n',['<identifier type="local">' C{i,col_id} '</identifier>']);
        
        %title
        fprintf(fid2,'%s\n','<titleInfo>');
        fprintf(fid2,'%s\n',['<title>' title '</title>']);
        
        %subtitle
        if isempty(col_sub)==1 || isempty(C{i,col_sub})==1
            fprintf(fid2,'%s\n','<subTitle/>');
        else
            fprintf(fid2,'%s\n',['<subtitle>' C{i,col_sub} '</subtitle>']);
        end
        fprintf(fid2,'%s\n','</titleInfo>'); %closes off the item opened at the start of title
        
        %name (Corporate of Personal)
        %     ind = ~isempty(C{col_ca}{i,1})*10 + ~isempty(C{col_pa}{i,1});
        %     switch ind
        %%%corporate author:
        if isempty(col_ca)==1 || isempty(C{i,col_ca(1)})==1
            %         fprintf(fid2,'%s\n','<namePart/>');
        else
            for j = 1:1:size(col_ca,1)
                fprintf(fid2,'%s\n','<name type="corporate">');
                fprintf(fid2,'%s\n',['<namePart>' C{i,col_ca(j,1)} '</namePart>']);
                fprintf(fid2,'%s\n','</name>');
            end
        end
        %%%personal author:
        if isempty(col_pa)==1 || isempty(C{i,col_pa(1)})==1
            %         fprintf(fid2,'%s\n','<namePart/>');
        else
            for j = 1:1:size(col_pa,1)
                fprintf(fid2,'%s\n','<name type="personal">');
                fprintf(fid2,'%s\n',['<namePart>' C{i,col_pa(j,1)} '</namePart>']);
                fprintf(fid2,'%s\n','</name>');
            end
        end
        
        %type of resource (constant)
        if isempty(col_type)==1 || isempty(C{i,col_type})==1
            fprintf(fid2,'%s\n','<typeOfResource/>');
        else
            fprintf(fid2,'%s\n',['<typeOfResource>' C{i,col_type} '</typeOfResource>']);
        end
        
        %genre (constant)
        if isempty(col_genre)==1 || isempty(C{i,col_genre})==1
            fprintf(fid2,'%s\n','<genre/>');
        else
            fprintf(fid2,'%s\n',['<genre authority="lctgm">' C{i,col_genre} '</genre>']);
        end
        
        %origin info
        fprintf(fid2,'%s\n','<originInfo>');
        %%%%publisher
        if isempty(col_pub)==1 || isempty(C{i,col_pub})==1
            fprintf(fid2,'%s\n','<publisher/>');
        else
            fprintf(fid2,'%s\n',['<publisher>' C{i,col_pub} '</publisher>']);
        end
        %%%%place of publishing
        if isempty(col_pubpl)==1 || isempty(C{i,col_pubpl})==1
            fprintf(fid2,'%s\n','<place/>');
        else
            fprintf(fid2,'%s\n','<place>');
            fprintf(fid2,'%s\n',['<placeTerm type="text">' C{i,col_pubpl} '</placeTerm>']);
            fprintf(fid2,'%s\n','</place>');
            if isempty(col_pubpl2)==1 || isempty(C{i,col_pubpl2})==1 %print publishing place 2
            else
                fprintf(fid2,'%s\n','<place>');
                fprintf(fid2,'%s\n',['<placeTerm type="text">' C{i,col_pubpl2} '</placeTerm>']);
                fprintf(fid2,'%s\n','</place>');
            end
        end
        %%%datecreated
        if isempty(date_created)==1
            fprintf(fid2,'%s\n','<dateCreated/>');
        else
            fprintf(fid2,'%s\n',['<dateCreated>' date_created '</dateCreated>']);
        end
        %%%dateother
        if isempty(date_other)==1
            fprintf(fid2,'%s\n','<dateOther/>');
        else
            fprintf(fid2,'%s\n',['<dateOther>' date_other '</dateOther>']);
        end
        fprintf(fid2,'%s\n','</originInfo>');
        
        %language
        fprintf(fid2,'%s\n','<language>');
        %     if isempty(C{col_lang}{i,1})==1
        %         fprintf(fid2,'%s\n','<languageTerm/>');
        %     else
        fprintf(fid2,'%s\n',['<languageTerm type="code" authority="iso639-2b">' language '</languageTerm>']);
        %     end
        fprintf(fid2,'%s\n','</language>');
        
        %% location
        fprintf(fid2,'%s\n','<location>');
        %%% physical location
        if isempty(col_pl)==1 ||isempty(C{i,col_pl})==1
            fprintf(fid2,'%s\n','<physicalLocation/>');
        else
            fprintf(fid2,'%s\n',['<physicalLocation>' C{i,col_pl} '</physicalLocation>']);
        end
        fprintf(fid2,'%s\n','</location>');
        %% physical description
        fprintf(fid2,'%s\n','<physicalDescription>');
        %%% extent
        if isempty(col_pe)==1 ||isempty(C{i,col_pe})==1
            fprintf(fid2,'%s\n','<extent/>');
        else
            fprintf(fid2,'%s\n',['<extent>' C{i,col_pe} '</extent>']);
        end
        
        %%% physical form
        if isempty(col_pf)==1 || isempty(C{i,col_pf})==1
            fprintf(fid2,'%s\n','<form/>');
        else
            fprintf(fid2,'%s\n',['<form authority="marcform">' C{i,col_pf} '</form>']);
        end
        
        %%% physical note
        if isempty(col_pn)==1 ||isempty(C{i,col_pn})==1
            fprintf(fid2,'%s\n','<note/>');
        else
            fprintf(fid2,'%s\n',['<note>' C{i,col_pn} '</note>']);
        end
        
        %%% media type
        if isempty(col_mt)==1 ||isempty(C{i,col_mt})==1
            fprintf(fid2,'%s\n','<internetMediaType/>');
        else
            fprintf(fid2,'%s\n',['<internetMediaType>' C{i,col_mt} '</internetMediaType>']);
        end
        
        fprintf(fid2,'%s\n','</physicalDescription>');
        
        %note
        if isempty(col_note)==1 || isempty(C{i,col_note})==1
            fprintf(fid2,'%s\n','<note/>');
        else
            fprintf(fid2,'%s\n',['<note>' C{i,col_note} '</note>']);
        end
        
        %subject information:
        fprintf(fid2,'%s\n','<subject>');
        
        %%%%% topical subject
        if isempty(col_topic)==1 || isempty(C{i,col_topic})==1; fprintf(fid2,'%s\n','<topic/>'); else  fprintf(fid2,'%s\n',['<topic>' C{i,col_topic} '</topic>']); end
        
        %%%cycle through the geographic subjects
        for j = 1:1:length(col_sg)
            if isempty(C{i,col_sg(j)})==1%
                fprintf(fid2,'%s\n','<geographic/>');
            else
                fprintf(fid2,'%s\n',['<geographic>' C{i,col_sg(j)} '</geographic>']);
            end
        end
        %%%heirarchicalGeographic
        fprintf(fid2,'%s\n','<hierarchicalGeographic>');
        %%%%% continent
        if isempty(col_cont)==1 || isempty(C{i,col_cont})==1; fprintf(fid2,'%s\n','<continent/>'); else  fprintf(fid2,'%s\n',['<continent>' C{i,col_cont} '</continent>']); end
        %%%%% country
        if isempty(col_country)==1 || isempty(C{i,col_country})==1; fprintf(fid2,'%s\n','<country/>'); else  fprintf(fid2,'%s\n',['<country>' C{i,col_country} '</country>']); end
        %%%%% province
        if isempty(col_prov)==1 || isempty(C{i,col_prov})==1; fprintf(fid2,'%s\n','<province/>'); else  fprintf(fid2,'%s\n',['<province>' C{i,col_prov} '</province>']); end
        %%%%% region
        if isempty(col_reg)==1 ||isempty(C{i,col_reg})==1; fprintf(fid2,'%s\n','<region/>'); else  fprintf(fid2,'%s\n',['<region>' C{i,col_reg} '</region>']); end
        %%%%% county
        if isempty(col_county)==1 ||isempty(C{i,col_county})==1; fprintf(fid2,'%s\n','<county/>'); else  fprintf(fid2,'%s\n',['<county>' C{i,col_county} '</county>']); end
        %%%%% city
        if isempty(col_city)==1 || isempty(C{i,col_city})==1; fprintf(fid2,'%s\n','<city/>'); else  fprintf(fid2,'%s\n',['<city>' C{i,col_city} '</city>']); end
        %%%%% citySection
        if isempty(col_csec)==1 || isempty(C{i,col_csec})==1; fprintf(fid2,'%s\n','<citySection/>'); else  fprintf(fid2,'%s\n',['<citySection>' C{i,col_csec} '</citySection>']); end
        %%%%% area
        if isempty(col_area)==1 || isempty(C{i,col_area})==1; fprintf(fid2,'%s\n','<area/>'); else  fprintf(fid2,'%s\n',['<area>' C{i,col_area} '</area>']); end
        fprintf(fid2,'%s\n','</hierarchicalGeographic>');
        
        %%%Cartographic information
        fprintf(fid2,'%s\n','<cartographics>');
        
        if isempty(coords)==1
            fprintf(fid2,'%s\n','<coordinates/>');
        else
            fprintf(fid2,'%s\n',['<coordinates>' coords '</coordinates>']);
        end
        
        fprintf(fid2,'%s\n','</cartographics>');
        fprintf(fid2,'%s\n','</subject>');
        fprintf(fid2,'%s\n','</mods>');
        fclose(fid2);
    catch
        disp(['Error encountered on line ' num2str(i) ' of input file. ID= ' C{i,col_id} ])
        try
            fclose(fid2);
        catch
        end
    end
end

%%
% %% Problem-solving: There are only 4974 files being created out of 5033 rows. Means that we have 59 duplicated identifiers. hmmm
% %%% Solved. there were duplicated items
% tmp = C(:,35);
% [A,itmp,ia] = unique(tmp);
%
% tmp(itmp,1) = '';
