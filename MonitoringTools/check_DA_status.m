save_path = '/media/Stuff/GDrive/Library/Maps, Data, GIS/Digital Archive/';
fid = fopen([save_path 'DigArcChecks.csv'],'a');
[S, SUCCESS, MESSAGE] = urlread('http://digitalarchive.mcmaster.ca/islandora/object/macrepo%3A66474');
tmp = sprintf('%s,',datestr(now,30),num2str(SUCCESS), ['"' MESSAGE '"']);
fprintf(fid,'%s\n',tmp(1:end-1));
fclose(fid);