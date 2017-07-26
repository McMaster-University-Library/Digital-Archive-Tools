master_path = 'H:\Digitization_Projects\Gabriela\AirPhoto_Metadata\';
cd(master_path);
if exist([master_path 'MODS\'],'dir')~=7
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(master_path,'MODS');
    disp(['Output Folder \MODS\ was successfully created in ' master_path]);
end
% tab_string = repmat(sprintf('\t'), 1, 60);
fmt = repmat('%s',1,28);
% fmt = [fmt '\t']
%tline = fgets(fid);
fid = fopen('Air Photo Metadata Master.txt','r');
H1 = textscan(fid,fmt,'Delimiter','\t','TreatAsEmpty',{'NA','na'},1);
C = textscan(fid,fmt,'Delimiter','\t','TreatAsEmpty',{'NA','na'});
fclose(fid);
for i = 1:1:size(C,2)
    H1{i,1} = C{1,i}{1,1};
    H2{i,1} = C{1,i}{2,1};
end

%%% Identify proper columns for things:
col_id = find(strcmp('identifier',H2)==1);      col_tit = find(strcmp('title',H2)==1);
col_sub = find(strcmp('subtitle',H2)==1);       col_ca = find(strcmp('corporateauthor',H2)==1);
col_pa = find(strcmp('personalauthor',H2)==1);  col_type = find(strcmp('typeofresource',H2)==1);
col_gen = find(strcmp('genreloc',H2)==1);       col_dc = find(strcmp('dateCreated',H2)==1);
col_pub = find(strcmp('publisher',H2)==1);      col_pubpl = find(strcmp('publicationplace',H2)==1);
col_do = find(strcmp('dateOther',H2)==1);       col_lang = find(strcmp('language',H2)==1);
col_pf = find(strcmp('physicalform',H2)==1);    col_pe = find(strcmp('physicalextent',H2)==1);
col_pn = find(strcmp('physicalnote',H2)==1);    col_note = find(strcmp('note',H2)==1);
col_sg = find(strcmp('subjectgeographic',H2)==1); %multicolumn
col_cont = find(strcmp('continent',H2)==1);     col_country = find(strcmp('country',H2)==1);
col_prov = find(strcmp('province',H2)==1);      col_reg = find(strcmp('region',H2)==1);
col_county = find(strcmp('county',H2)==1);      col_city = find(strcmp('city',H2)==1);
col_csec = find(strcmp('citySection',H2)==1);   col_area = find(strcmp('area',H2)==1);
col_coord = find(strcmp('coordinates',H2)==1);



for i = 3:1:size(C{1,1},1)
    fid2 = fopen([master_path 'MODS\' C{1}{i,1} '.xml'],'w+');
    % preamble
    fprintf(fid2,'%s\n','<?xml version="1.0" encoding="UTF-8"?><mods xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd">');
    fprintf(fid2,'%s\n','<accessCondition/>');
    
    % identifier
    fprintf(fid2,'%s\n',['<identifier type="local">' C{col_id}{i,1} '</identifier>']);
    
    %title
    fprintf(fid2,'%s\n','<titleInfo>');
    fprintf(fid2,'%s\n',['<title>' C{col_tit}{i,1} '</title>']);
    
    %subtitle
    if isempty(C{col_sub}{i,1})==1
        fprintf(fid2,'%s\n','<subTitle/>');
    else
        fprintf(fid2,'%s\n',['<subtitle>' C{col_sub}{i,1} '</subtitle>']);
    end
    fprintf(fid2,'%s\n','</titleInfo>'); %closes off the item opened at the start of title
    
    %name (Corporate of Personal)
    %     ind = ~isempty(C{col_ca}{i,1})*10 + ~isempty(C{col_pa}{i,1});
    %     switch ind
    %%%corporate author:
    fprintf(fid2,'%s\n','<name type="corporate">');
    if isempty(C{col_ca}{i,1})==1
        fprintf(fid2,'%s\n','<namePart/>');
    else
        fprintf(fid2,'%s\n',['<namePart>' C{col_ca}{i,1} '</namePart>']);
    end
    fprintf(fid2,'%s\n','</name>');
    %%%personal author:
    fprintf(fid2,'%s\n','<name type="personal">');
    if isempty(C{col_pa}{i,1})==1
        fprintf(fid2,'%s\n','<namePart/>');
    else
        fprintf(fid2,'%s\n',['<namePart>' C{col_pa}{i,1} '</namePart>']);
    end
    fprintf(fid2,'%s\n','</name>');
    
    
    %type of resource
    if isempty(C{col_type}{i,1})==1
        fprintf(fid2,'%s\n','<typeOfResource/>');
    else
        fprintf(fid2,'%s\n',['<typeOfResource>' C{col_type}{i,1} '</typeOfResource>']);
    end
    
    %genre
    if isempty(C{col_gen}{i,1})==1
        fprintf(fid2,'%s\n','<genre/>');
    else
        fprintf(fid2,'%s\n',['<genre authority="lctgm">' C{col_gen}{i,1} '</genre>']);
    end
    
    
    %origin info
    fprintf(fid2,'%s\n','<originInfo>');
    %%%%publisher
    if isempty(C{col_pub}{i,1})==1
        fprintf(fid2,'%s\n','<publisher/>');
    else
        fprintf(fid2,'%s\n',['<publisher>' C{col_pub}{i,1} '</publisher>']);
    end
    %%%%place of publishing
    if isempty(C{col_pubpl}{i,1})==1
        fprintf(fid2,'%s\n','<place/>');
    else
        fprintf(fid2,'%s\n','<place>');
        fprintf(fid2,'%s\n',['<placeTerm type="text">' C{col_pubpl}{i,1} '</placeTerm>']);
        fprintf(fid2,'%s\n','</place>');
    end
    %%%datecreated
    %%%%%% Fix up date formats (if necessary)%%%%%%%%%%%%
    %Format will be either YYYY or MM/DD/YYYY
    % We need it in YYYY-MM-DD
    date_tmp = C{col_dc}{i,1};
    slash_find = strfind(date_tmp,'/');
    if size(date_tmp,2)==4 || size(date_tmp,2)==0 || length(strfind(date_tmp,'['))==1 %either we have the year or nothing at all or implied date - all are OK!
    elseif size(date_tmp,2)>=8 && length(slash_find)==2 %assume we have the date in MM/DD/YYYY
        
        date_tmp2 = [date_tmp(end-3:end) '-' date_tmp(1:slash_find(1)-1) '-' date_tmp(slash_find(1)+1:slash_find(2)-1)];
    else
        
    end
    
    if isempty(C{col_dc}{i,1})==1
        fprintf(fid2,'%s\n','<dateCreated/>');
    else
        fprintf(fid2,'%s\n',['<dateCreated>' C{col_dc}{i,1} '</dateCreated>']);
    end
    %%%dateother
    if isempty(C{col_do}{i,1})==1
        fprintf(fid2,'%s\n','<dateCreated/>');
    else
        fprintf(fid2,'%s\n',['<dateOther>' C{col_do}{i,1} '</dateOther>']);
    end
    fprintf(fid2,'%s\n','</originInfo>');
    
    
    %language
    fprintf(fid2,'%s\n','<language>');
    if isempty(C{col_lang}{i,1})==1
        fprintf(fid2,'%s\n','<languageTerm/>');
    else
        fprintf(fid2,'%s\n',['<languageTerm type="code" authority="iso639-2b">' C{col_lang}{i,1} '</languageTerm>']);
    end
    fprintf(fid2,'%s\n','</language>');
    
    
    %physical description
    fprintf(fid2,'%s\n','<physicalDescription>');
    %%% extent
    if isempty(C{col_pe}{i,1})==1
        fprintf(fid2,'%s\n','<extent/>');
    else
        fprintf(fid2,'%s\n',['<extent>' C{col_pe}{i,1} '</extent>']);
    end
    %%% form
    if isempty(C{col_pf}{i,1})==1
        fprintf(fid2,'%s\n','<form/>');
    else
        fprintf(fid2,'%s\n',['<form authority="marcform">' C{col_pf}{i,1} '</form>']);
    end
    %%% note
    if isempty(C{col_pn}{i,1})==1
        fprintf(fid2,'%s\n','<note/>');
    else
        fprintf(fid2,'%s\n',['<note>' C{col_pn}{i,1} '</note>']);
    end
    fprintf(fid2,'%s\n','</physicalDescription>');
    
    %note
    if isempty(C{col_note}{i,1})==1
        fprintf(fid2,'%s\n','<note/>');
    else
        fprintf(fid2,'%s\n',['<note>' C{col_note}{i,1} '</note>']);
    end
    
    %subject information:
    fprintf(fid2,'%s\n','<subject>');
    %%%cycle through the geographic subjects
    for j = 1:1:length(col_sg)
        if isempty(C{col_sg(j)}{i,1})==1
            fprintf(fid2,'%s\n','<geographic/>');
        else
            fprintf(fid2,'%s\n',['<geographic>' C{col_sg(j)}{i,1} '</geographic>']);
        end
    end
    %%%heirarchicalGeographic
    fprintf(fid2,'%s\n','<hierarchicalGeographic>');
    %%%%% continent
    if isempty(C{col_cont}{i,1})==1; fprintf(fid2,'%s\n','<continent/>'); else  fprintf(fid2,'%s\n',['<continent>' C{col_cont}{i,1} '</continent>']); end
    %%%%% country
    if isempty(C{col_country}{i,1})==1; fprintf(fid2,'%s\n','<country/>'); else  fprintf(fid2,'%s\n',['<country>' C{col_country}{i,1} '</country>']); end
    %%%%% province
    if isempty(C{col_prov}{i,1})==1; fprintf(fid2,'%s\n','<province/>'); else  fprintf(fid2,'%s\n',['<province>' C{col_prov}{i,1} '</province>']); end
    %%%%% region
    if isempty(C{col_reg}{i,1})==1; fprintf(fid2,'%s\n','<region/>'); else  fprintf(fid2,'%s\n',['<region>' C{col_reg}{i,1} '</region>']); end
    %%%%% county
    if isempty(C{col_county}{i,1})==1; fprintf(fid2,'%s\n','<county/>'); else  fprintf(fid2,'%s\n',['<county>' C{col_county}{i,1} '</county>']); end
    %%%%% city
    if isempty(C{col_city}{i,1})==1; fprintf(fid2,'%s\n','<city/>'); else  fprintf(fid2,'%s\n',['<city>' C{col_city}{i,1} '</city>']); end
    %%%%% citySection
    if isempty(C{col_csec}{i,1})==1; fprintf(fid2,'%s\n','<citySection/>'); else  fprintf(fid2,'%s\n',['<citySection>' C{col_csec}{i,1} '</citySection>']); end
    %%%%% area
    if isempty(C{col_area}{i,1})==1; fprintf(fid2,'%s\n','<area/>'); else  fprintf(fid2,'%s\n',['<area>' C{col_area}{i,1} '</area>']); end
    fprintf(fid2,'%s\n','</hierarchicalGeographic>');
    
    %%%Cartographic information
    fprintf(fid2,'%s\n','<cartographics>');
    
    if isempty(C{col_coord}{i,1})==1
        fprintf(fid2,'%s\n','<coordinates/>');
    else
        fprintf(fid2,'%s\n',['<coordinates>' C{col_coord}{i,1} '</coordinates>']);
    end
    
    fprintf(fid2,'%s\n','</cartographics>');
    fprintf(fid2,'%s\n','</subject>');
    fprintf(fid2,'%s\n','</mods>');
    fclose(fid2);
end