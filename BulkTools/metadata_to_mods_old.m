master_path = 'D:\Dropbox (MUL)\Library\Maps, Data, GIS\AirPhotoIndex\AirPhoto_Metadata\';
cd(master_path);

%%% Check to see if the '\MODS\ directory exists in the master directory.
%%% If not, create it.
if exist([master_path 'MODS\'],'dir')~=7
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(master_path,'MODS');
    disp(['Output Folder \MODS\ was successfully created in ' master_path]);
end

%%%% Load the master spreadsheet (Master Spreadsheet.tsv)-figure out how
%%%% many columns it has, so that we can load the rest of the items:

%%% Incoming fields:
% title             pseudotitle             subtitle        date_in         flightline      photo_number    scale	
% latitude          longitude               thumbnail_link	archive_link    corporate_name	personal_name	publisher_name	publisher_location	
% set_date          physical_description	general_note	subj_geographic	subj_geographic	subj_geographic	
% content           country                 province        region          county          city                
% city_section      area                    index           condition_notes identifier

%% Loading the raw spreadsheet; reforming data:
%%% Load the raw spreadsheet (downloaded from Google Sheet as a .tsv
%%% (tab-separated file)
%%% URL: https://docs.google.com/spreadsheets/d/180qQStP5EkeY_3a4eM5lXcDYv3QY4zFq4l5bx3BZ8m0/edit#gid=0
fid = fopen([master_path 'Master Spreadsheet [Current] - Master.tsv'],'r');
tline = fgets(fid);

%%% Figure out how many columns there are in the file:
startIndex = regexp(tline,'\t'); numcols = size(startIndex,2)+1;
fmt = repmat('%s',1,numcols); %create the format string for reading:
frewind(fid); %rewind the pointer to the start of the file:

%%% Load the file using textscan. Reform it until it's in a first-level
%%% cell structure
tmp = textscan(fid,fmt,'Delimiter','\t','TreatAsEmpty',{'NA','na'});
C = {};

% Remove quotations (removed as of 08-Aug-2016); Collect header
% information
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
type_of_resource = 'cartographic';
genre_loc = 'Aerial photographs';
language = 'eng';
physical_form = 'remote-sensing image';

%%% Figure out the column assignments in the master file:
col_id = find(strcmp('identifier',H3)==1);      col_tit = find(strcmp('title',H3)==1);
col_pseutit = find(strcmp('pseudotitle',H3)==1);
col_photo = find(strcmp('photo_number',H3)==1); col_fline = find(strcmp('flightline',H3)==1);  

col_sub = find(strcmp('subtitle',H3)==1);       col_ca = find(strcmp('corporate_name',H3)==1);
col_pa = find(strcmp('personal_name',H3)==1);   col_dc = find(strcmp('date_in',H3)==1);
col_pub = find(strcmp('publisher_name',H3)==1); col_pubpl = find(strcmp('publisher_location',H3)==1);
col_pe = find(strcmp('scale',H3)==1);           col_pn = find(strcmp('physical_description',H3)==1);
col_note = find(strcmp('general_note',H3)==1);
    
col_sg = find(strcmp('subj_geographic',H3)==1); %multicolumn

col_cont = find(strcmp('continent',H3)==1);     col_country = find(strcmp('country',H3)==1);
col_prov = find(strcmp('province',H3)==1);      col_reg = find(strcmp('region',H3)==1);
col_county = find(strcmp('county',H3)==1);      col_city = find(strcmp('city',H3)==1);
col_csec = find(strcmp('city_section',H3)==1);   col_area = find(strcmp('area',H3)==1);
col_long = find(strcmp('longitude',H3)==1);     col_lat = find(strcmp('latitude',H3)==1);
% 
%% Creating the output xml files
out_check = cell(size(C,1)-3,2);
for i = 4:1:size(C,1)
    %%% Generate all 'item-specific' fields that are required
    
    %%%%%% Fix up date formats (if necessary)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Format will be either YYYY or MM/DD/YYYY
    % We need it in YYYY-MM-DD
    date_created = C{i,col_dc};
    slash_find = strfind(date_created,'/');
    dash_find = strfind(date_created,'-');
    if size(date_created,2)==4 || size(date_created,2)==0 || length(strfind(date_created,'['))==1 || (length(dash_find)==2 && dash_find(1)>3) %either we have the year or nothing at all or implied date - all are OK!
    elseif size(date_created,2)>=8 && length(slash_find)==2 %assume we have the date in MM/DD/YYYY
        date_created = [date_created(end-3:end) '-' date_created(1:slash_find(1)-1) '-' date_created(slash_find(1)+1:slash_find(2)-1)];
    else
        disp(['Cannot convert date format for: ' date_created '. Setting to blank.']);
        date_created = '';
    end
    % Date-other is a stripped-down version of Date ("[" and "]" and "?" removed);
%     date_other = strrep(C(:,col_dc),'[',''); date_other = strrep(date_other,']',''); date_other = strrep(date_other,'?','');
    date_other = strrep(date_created,'[',''); date_other = strrep(date_other,']',''); date_other = strrep(date_other,'?','');
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate Coordinates: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    coords = ['latitude ' C{i,col_lat} ' ; longitude ' C{i,col_long}];
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
    
    %%%%%%%%%%%%%%%%%% WRITE the XML MODS file %%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %%% open the file (or create it)
    fid2 = fopen([master_path 'MODS\' C{i,col_id} '.xml'],'w','n','UTF-8');
    % preamble
    fprintf(fid2,'%s\n','<?xml version="1.0" encoding="UTF-8"?><mods xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd">');
    fprintf(fid2,'%s\n','<accessCondition/>');
    
    % identifier
    fprintf(fid2,'%s\n',['<identifier type="local">' C{i,col_id} '</identifier>']);
    
    %title
    fprintf(fid2,'%s\n','<titleInfo>');
    fprintf(fid2,'%s\n',['<title>' title '</title>']);
    
    %subtitle
    if isempty(C{i,col_sub})==1
        fprintf(fid2,'%s\n','<subTitle/>');
    else
        fprintf(fid2,'%s\n',['<subtitle>' C{i,col_sub} '</subtitle>']);
    end
    fprintf(fid2,'%s\n','</titleInfo>'); %closes off the item opened at the start of title
    
    %name (Corporate of Personal)
    %     ind = ~isempty(C{col_ca}{i,1})*10 + ~isempty(C{col_pa}{i,1});
    %     switch ind
    %%%corporate author:
    fprintf(fid2,'%s\n','<name type="corporate">');
    if isempty(C{i,col_ca})==1
        fprintf(fid2,'%s\n','<namePart/>');
    else
        fprintf(fid2,'%s\n',['<namePart>' C{i,col_ca} '</namePart>']);
    end
    fprintf(fid2,'%s\n','</name>');
    %%%personal author:
    fprintf(fid2,'%s\n','<name type="personal">');
    if isempty(C{i,col_pa})==1
        fprintf(fid2,'%s\n','<namePart/>');
    else
        fprintf(fid2,'%s\n',['<namePart>' C{i,col_pa} '</namePart>']);
    end
    fprintf(fid2,'%s\n','</name>');
    
    
    %type of resource (constant)
%     if isempty(C{col_type}{i,1})==1
%         fprintf(fid2,'%s\n','<typeOfResource/>');
%     else
        fprintf(fid2,'%s\n',['<typeOfResource>' type_of_resource '</typeOfResource>']);
%     end
    
    %genre (constant)
%     if isempty(C{i,col_gen})==1
%         fprintf(fid2,'%s\n','<genre/>');
%     else
        fprintf(fid2,'%s\n',['<genre authority="lctgm">' genre_loc '</genre>']);
%     end
    
    
    %origin info
    fprintf(fid2,'%s\n','<originInfo>');
    %%%%publisher
    if isempty(C{i,col_pub})==1
        fprintf(fid2,'%s\n','<publisher/>');
    else
        fprintf(fid2,'%s\n',['<publisher>' C{i,col_pub} '</publisher>']);
    end
    %%%%place of publishing
    if isempty(C{i,col_pubpl})==1
        fprintf(fid2,'%s\n','<place/>');
    else
        fprintf(fid2,'%s\n','<place>');
        fprintf(fid2,'%s\n',['<placeTerm type="text">' C{i,col_pubpl} '</placeTerm>']);
        fprintf(fid2,'%s\n','</place>');
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
    
    %physical description
    fprintf(fid2,'%s\n','<physicalDescription>');
    %%% extent
    if isempty(C{i,col_pe})==1
        fprintf(fid2,'%s\n','<extent/>');
    else
        fprintf(fid2,'%s\n',['<extent>' C{i,col_pe} '</extent>']);
    end
    %%% form (constant)
%     if isempty(C{col_pf}{i,1})==1
%         fprintf(fid2,'%s\n','<form/>');
%     else
        fprintf(fid2,'%s\n',['<form authority="marcform">' physical_form '</form>']);
%     end
    %%% physical note
    if isempty(C{i,col_pn})==1
        fprintf(fid2,'%s\n','<note/>');
    else
        fprintf(fid2,'%s\n',['<note>' C{i,col_pn} '</note>']);
    end
    fprintf(fid2,'%s\n','</physicalDescription>');
    
    %note
    if isempty(C{i,col_note})==1
        fprintf(fid2,'%s\n','<note/>');
    else
        fprintf(fid2,'%s\n',['<note>' C{i,col_note} '</note>']);
    end
    
    %subject information:
    fprintf(fid2,'%s\n','<subject>');
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
    if isempty(C{i,col_cont})==1; fprintf(fid2,'%s\n','<continent/>'); else  fprintf(fid2,'%s\n',['<continent>' C{i,col_cont} '</continent>']); end
    %%%%% country
    if isempty(C{i,col_country})==1; fprintf(fid2,'%s\n','<country/>'); else  fprintf(fid2,'%s\n',['<country>' C{i,col_country} '</country>']); end
    %%%%% province
    if isempty(C{i,col_prov})==1; fprintf(fid2,'%s\n','<province/>'); else  fprintf(fid2,'%s\n',['<province>' C{i,col_prov} '</province>']); end
    %%%%% region
    if isempty(C{i,col_reg})==1; fprintf(fid2,'%s\n','<region/>'); else  fprintf(fid2,'%s\n',['<region>' C{i,col_reg} '</region>']); end
    %%%%% county
    if isempty(C{i,col_county})==1; fprintf(fid2,'%s\n','<county/>'); else  fprintf(fid2,'%s\n',['<county>' C{i,col_county} '</county>']); end
    %%%%% city
    if isempty(C{i,col_city})==1; fprintf(fid2,'%s\n','<city/>'); else  fprintf(fid2,'%s\n',['<city>' C{i,col_city} '</city>']); end
    %%%%% citySection
    if isempty(C{i,col_csec})==1; fprintf(fid2,'%s\n','<citySection/>'); else  fprintf(fid2,'%s\n',['<citySection>' C{i,col_csec} '</citySection>']); end
    %%%%% area
    if isempty(C{i,col_area})==1; fprintf(fid2,'%s\n','<area/>'); else  fprintf(fid2,'%s\n',['<area>' C{i,col_area} '</area>']); end
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
end

%%
% %% Problem-solving: There are only 4974 files being created out of 5033 rows. Means that we have 59 duplicated identifiers. hmmm
% %%% Solved. there were duplicated items
% tmp = C(:,35);
% [A,itmp,ia] = unique(tmp);
% 
% tmp(itmp,1) = '';
