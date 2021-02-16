%% Load files 
%% Step 1:
folder = uigetdir; %opens box so folder with data in can be selected. 
files = dir(folder); %gets the names of all the files in that folder
old = cd; % makes a note of your main Matlab directory before changing
cd(folder) %move to the folder of interest

type = '.xls'; %which files do you want to pick out
%% Step 2:
for i=1:length(files) %for all files in the folder
    A(i) = ~cellfun('isempty',{strfind(files(i).name,type)}); %check if it is the file type you want
    if A(i) == 1 %if it is . . . 
        B = strread(files(i).name, '%s', 'delimiter', '.'); %get files name . . . 
        C =  importdata(files(i).name); %importdata . . . 
        D{i}= B{1}; %take the important bit of the file name without xls
        if isstruct(C) ==1
            data = C.data; %select just the numbers if it is a structure
        elseif isstruct(C) == 0
            data = C; %take everything if a simple array
        end
        B{1} = strrep(B{1}, '-', '_'); %get rid of invalid char
        B{1} = strrep(B{1}, '(', ''); %get rid of invalid char
        B{1} = strrep(B{1}, ')', ''); %get rid of invalid char
        B{1} = strrep(B{1}, ' ', '_'); %get rid of invalid char
        %B{1} = ['Data_' B{1}]; %put Data at the begining of variable name to avoid it starting with a number which Matlab doesn't like, uncomment if needed
        eval([B{1} '= data;']); %name variable containing data after filename
    elseif A(i) == 0 
        %do nothing
    end 
end
%Get rid of the dummy variables we uesd and go back to our Matlab directory
clear i A B C D data type
clc
cd(old)
%%
%Now there are structures in your workspace mirroring the xls files recorded

%NB Columns are: 
% 'Displacement Into Surface','Load On Sample','Time On Sample','Harmonic Contact Stiffness','Hardness','Modulus','Raw Displacement','Raw Load','Time','Phase Angle','Harmonic Displacement','Harmonic Frequency','Harmonic Load','Harmonic Stiffness'
%'nm','mN','s','N/m','GPa','GPa','nm','mN','s','deg','nm','Hz','uN','N/m'
%% Make Contact Depth based on Stiffness and Load as column where space
things = whos; 
figure; hold on 
for j = 1:length(things)
    vars = things(j).name; 
    eval(['VARS = ' vars ';']);
    if isstruct(VARS) == 1
        vars = things(j).name; 
        eval(['VARS = ' vars ';']);
        fields = fieldnames(VARS);
        for i = 1:length(fields)
            A(i) = ~cellfun('isempty',{strfind(fields{i},'Test00')}); %check if it is the file type you want
            if A(i) == 1
                eval( ['var =' vars '.' fields{i} ';'])
                P = var(:,2); S = var(:,4); h = var(:,1);
                dummy = (10.^-9)*(h)-0.75*(10.^-3)*(P)./S;
                Space = 7; %size(var,2)+1;
                eval([vars '.' fields{i} '(:,' num2str(Space) ') = dummy;']);
                plot(dummy, P, 'DisplayName', [vars ' ' fields{i}])
                clear A a i j dummy P S h
            else 
                %do nothing
            end    
        end
    else 
        %do nothing
    end
    axis([0 2000e-9 0 500])
    xlabel('Displacement (m)'); ylabel('Load (mN)')
end
clear things var vars VARS fields Space i j A