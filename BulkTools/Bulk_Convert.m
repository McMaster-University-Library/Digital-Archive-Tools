load_dir = 'D:\Local\DigitalArchive-BulkDownload\tiffs';
d = dir(load_dir);
cd(load_dir);
for i = 3:1:length(d)
    fname = d(i).name;
   cmd =  ['mogrify -format jpg -resize 4000x ' fname];
   if ispc==1
       [status{i,1},result{i,1}] = dos(cmd);
   else
       [status{i,1},result{i,1}] = unix(cmd);
   end
   if status{i,1} ~=0
       disp(['Failed conversion for ' fname]);
   else
       disp(['Successful conversion for ' fname]);
   end 
end