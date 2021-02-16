function [files,folder] = importTXTfiles(folder)
%run using F9
folder = uigetdir;
files = dir(folder); 
old = cd; 
cd(folder)
DELIM = '\t'; type = '.csv';
sizeofDataHeader = 0;
%%
for i=1:length(files)
    A(i) = ~cellfun('isempty',{strfind(files(i).name,type)}); %look for txt files
    if A(i) == 1
        B = strread(files(i).name, '%s', 'delimiter', '.'); %get files name
        C = fopen(files(i).name);
        C =  textscan(C,'%s', 'Delimiter', DELIM);%importdata
        C = C{1,1};
        D{i}= B{1};
        if isstruct(C) ==1
            data = C.data; %select just the numbers
        elseif isstruct(C) == 0
            data = C{1,1};
        end
        B{1} = strrep(B{1}, '-', '_');
        B{1} = strrep(B{1}, ' ', '_');%get rid of invalid char
        %B{1} = ['gilso_' B{1}];
        eval([B{1} '= data']); %name data after filename
    elseif A(i) == 0 
        %do nothing
    end 
end
%%
clear i A B C D data DELIM type sizeofDataHeader
clc
cd(old)
end