function [cellstack, cellnamestack]=flattenStruct2Cell(I)
%  Extention of struct2cell
%  Takes a (possibly) nested structure and returns a linear cell array
%  containing all the elements of the structure and another cell array
%  containing the names of elements
%   usage I is a structure
%   Input
%   cellstack is the array of non-structure elements
%
%   Output
%   cellnamestack is the name of the element including the path through the
%   hirearchy
% Modified by JJB (20180322) to unpack cell arrays that exist within
% structure. Previously were being passed along into final cell array.
[C] = struct2cell(I);
tmpnames=fieldnames(I);

cellstack={};
cellnamestack={};
n=1;

tempCell=C;
tmpNames=fieldnames(I);
done=0;

while done==0
    
    tmp={};
    oldtmpnames=tmpnames;
    tmpnames={};
    i = 1;
    while i<=length(tempCell)
%     for i=1:length(tempCell) % cycle through all top-level cells (i.e. branches of structure)
        if iscell(tempCell{i})==1
                tmp_reassign = tempCell{i};
                tmp_reassign_name = tmpNames{i};
                tempCell{i} = tmp_reassign{1};
                tmpNames{i} = [tmp_reassign_name '_1'];
                for k = 2:1:length(tmp_reassign)
                    tempCell{length(tempCell)+k-1} =tmp_reassign{k};
                    tmpNames{length(tmpNames)+k-1}= [tmp_reassign_name '_' num2str(k)];
%                     oldtmpnames{length(oldtmpnames)+k-1} = tmp_reassign_name;
                    oldtmpnames{length(oldtmpnames)+k-1} = [tmp_reassign_name '_' num2str(k)]; % Added this later. Testing
                    
                end
%                 i = i-1;
                continue
        end 
        if isstruct(tempCell{i})==0 && iscell(tempCell{i})==0% If the top-level cell is not a structure,
            cellstack{n}=tempCell{i};
            cellnamestack{n}=tmpNames{i};
            n=n+1;
            tempCell{i}=[];tmpNames{i}=[];
        end
        
        if isstruct(tempCell{i})    % If the top-level cell is a structure, turn it into a cell and cycle through all sub-elements
            tmp=[tmp; struct2cell(tempCell{i})];
            nn=fieldnames(tempCell{i});
            for k=1:length(nn)
                nn{k}= [oldtmpnames{i} '_' char(nn{k})  ];
            end
            tmpnames=[tmpnames; nn];
        end
        i = i+1;
    end
    
    
    tempCell=tmp;
    tmpNames=tmpnames;
    if length(tempCell)==0
        done=1;
    end
    
    
end

