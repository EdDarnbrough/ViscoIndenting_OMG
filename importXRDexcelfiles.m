function [files, folder] = importXRDexcelfiles(folder)
folder = uigetdir;
files = dir(folder); 
old = cd; 
cd(folder)

for i = 1:length(files)
A(i) = ~cellfun('isempty',{strfind(files(i).name,'.csv')});
end

for i =1:length(files)
    if A(i)==1
        B = strread(files(i).name, '%s', 'delimiter', '.');
        a = genvarname(B{1});
        data =  importdata(files(i).name,',',31);
        eval([a '= data.data']);
        %b = [a 'text'];
        %eval([b '= data.textdata']);
    elseif A(i)==0
        %do nothing
    end
end
clear i a data A B 
cd(old)
clc



end

%%% if taken datatext for times
A = who;
B = strfind(A, 'text');
C = ~cellfun('isempty',B);
for i =1:length(A)
    if C(i)==1
        data = eval(A{i});
        dates{i,1} = textscan(data{18},'File date and time, %f %s %f %f:%f', 'Delimiter', '/');
        dates{i,1}{1,6} = A{i};
    elseif C(i)==0
        %do nothing
    end
end
dates = dates(~cellfun('isempty',dates));
clear A B C data i 