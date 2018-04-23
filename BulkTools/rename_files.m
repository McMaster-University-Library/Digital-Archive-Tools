dir_in = 'H:\Digitization_Projects\Air_Photos\';

d = dir(dir_in);
d_list = struct2cell(d); d_list = d_list';

%% 1934:
% First step - try to rename all files without 1934 at the start -- there
% will be repeats, so we only want to do this for the ones that don't exist
% in the 1934 set.
dir2 = [dir_in 'AirPhotos_1934_Hamilton/'];
d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
        if strncmp(d2(i).name,'1934',4)
        else
            newname1 = strrep(d2(i).name,'-','_');
            if exist([dir2 '1934_' newname1],'file')==2; % If the file exists already
                disp(['Did not rename ' d2(i).name ' to 1934_' d2(i).name]);
            else
                [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 '1934_' newname1]);
                if status == 1
                    disp(['Successfully renamed ' d2(i).name ' to 1934_' d2(i).name]);
                end
            end
        end
        %         year = d2(i).name(1:4);
        %         fline = d2(i).name(
    end
    
end
% Step 2 -- rename the files to their final name.
d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
        if strncmp(d2(i).name,'1934',4)
            uscores = strfind(d2(i).name,'_');
            year = d2(i).name(1:4);
            fline = d2(i).name(uscores(1)+1:uscores(2)-1);
            shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_Hamilton_' year '_' fline '-' shot '.tif'];
                     [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
        end
    end
end

%% 1943:
dir2 = [dir_in 'AirPhotos_1943_Hamilton/'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
            dash = strfind(d2(i).name,'-');
            year = '1943';
            fline = d2(i).name(1:dash(1)-1);
            shot =   d2(i).name(dash(1)+1:end-4);
            
            testname = ['AirPhotos_Hamilton_' year '_' fline '-' shot '.tif'];
                  [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
    end
end

%% 1950
% First step - try to rename all files without 1934 at the start -- there
% will be repeats, so we only want to do this for the ones that don't exist
% in the 1934 set.
yr = '1950';

dir2 = [dir_in 'AirPhotos_' yr '_Hamilton/'];
d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
        if strncmp(d2(i).name,yr,4)
        else
            newname1 = strrep(d2(i).name,'-','_');
            if exist([dir2 yr '_' newname1],'file')==2; % If the file exists already
                disp(['Did not rename ' d2(i).name ' to ' yr '_' d2(i).name]);
            else
                 [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 yr '_' newname1]);
status = 1;
                if status == 1
                    disp(['Successfully renamed ' d2(i).name ' to ' yr '_' d2(i).name]);
                end
            end
        end
        %         year = d2(i).name(1:4);
        %         fline = d2(i).name(
    end
    
end
% Step 2 -- rename the files to their final name.
d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
        if strncmp(d2(i).name,yr,4)
            uscores = strfind(d2(i).name,'_');
            year = d2(i).name(1:4);
            fline = d2(i).name(uscores(1)+1:uscores(2)-1);
            shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_Hamilton_' year '_' fline '-' shot '.tif'];
                      [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
        end
    end
end

%% Hamilton 1951-52
% We can cheat here and just add the prefix to all of these
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1951-1952';
dir2 = [dir_in 'AirPhotos_' yr '_Hamilton/'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_Hamilton_' yr '_' d2(i).name];
                      [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
%% Hamilton 1952
% We can cheat here and just add the prefix to all of these
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1952';
dir2 = [dir_in 'AirPhotos_' yr '_Hamilton/'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_Hamilton_' d2(i).name];
                      [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
%                       status = dos(['ren "' dir2 d2(i).name ' ' testname);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end

%% sOntario 1954-1955
% We can cheat here and just add the prefix to all of these
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1954-1955';
site = 'sOntario';
dir2 = [dir_in 'AirPhotos_' yr '_' site '\'];

d2 = dir(dir2);
for i = 4:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_' site '_' d2(i).name];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
%%% Shoot, screwed this up and forgot the year. fixing now:
d2 = dir(dir2);
for i = 3:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
             uscores = strfind(d2(i).name,'_');
             name = d2(i).name(uscores(2)+1:end);
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_' site '_' yr '_' name];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end

clear yr site;

%% Hamilton 1958-1959
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1958-1959';
site = 'Hamilton';
dir2 = [dir_in 'AirPhotos_' yr '_' site '\'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_' site '_' yr '_' d2(i).name];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
clear yr site;

%% Hamilton 1959-1962
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1959-1962';
site = 'Hamilton';
dir2 = [dir_in 'AirPhotos_' yr '_' site '\'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_' site '_' yr '_' d2(i).name];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
clear yr site;

%% Hamilton 1960
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1960';
site = 'Hamilton';
dir2 = [dir_in 'AirPhotos_' yr '_' site '\'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
            testname = ['AirPhotos_' site '_' yr '_' d2(i).name];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
clear yr site;

%% Hamilton 1966
% AirPhotos_Hamilton_1950_A12510-116.tif
yr = '1966';
site = 'Hamilton';
dir2 = [dir_in 'AirPhotos_' yr '_' site '\'];

d2 = dir(dir2);
for i = 1:1:length(d2)
    if exist([dir2 d2(i).name],'file')==2
%         if strncmp(d2(i).name,yr,4)
%             uscores = strfind(d2(i).name,'_');
%             year = d2(i).name(1:4);
%             fline = d2(i).name(uscores(1)+1:uscores(2)-1);
%             shot =   d2(i).name(uscores(2)+1:end-4);
newname = strrep(d2(i).name,'_','-');
            testname = ['AirPhotos_' site '_' yr '_664-' newname];
%                       [status,message,messageid] = movefile([dir2 d2(i).name], [dir2 testname]);
                      status = dos(['ren "' dir2 d2(i).name '" ' testname]);
            disp(['Successfully renamed ' d2(i).name ' to ' testname]);
%         end
    end
end
clear yr site;
