function [files, folder] = importImages(folder)
folder = uigetdir;
files = dir(folder); 
old = cd; 
cd(folder)

for i = 1:length(files)
A(i) = ~cellfun('isempty',{strfind(files(i).name,'.bmp')});
end

for i =1:length(files)
    if A(i)==1
        B = strread(files(i).name, '%s', 'delimiter', '.');
        a = genvarname(B{1});
        data =  imread(files(i).name);
        eval([a '= data']);
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

%%% Mashup

Tag = 'Du_';
Tag = 'U_';
Tag = 'UO_';
VARS = whos;
for i = 1:length(VARS)
A(i) = ~cellfun('isempty',{strfind(VARS(i).name,Tag)});
end
C(240,320,sum(A)) =0;
for i =1:length(VARS)
    if A(i)==1
        B = textscan(VARS(i).name, [Tag '%s'], 'delimiter', '.');
        num = eval(cell2mat(B{1}));
        C(:,:,num+1) = double(rgb2gray(eval(VARS(i).name)));
    elseif A(i)==0
        %do nothing
    end
end
a = genvarname(Tag);
eval([a '= C']);
clear i a data A B C num 


cd(folder)
filename = 'UO.gif';
for n = 0:1:229
      imshow(eval(['UO_' num2str(n)]))
      frame = getframe(1);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      if n == 0;
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
      else
          imwrite(imind,cm,filename,'gif','WriteMode','append');
      end
end
clear n filename frame im imind cm 