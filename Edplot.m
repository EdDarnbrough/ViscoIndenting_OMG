function [title] = Edplot(var,x,y,Name,thickness,Normalise,color)
if nargin == 1
    x = 1; y = 2; thickness = 2; Name = ['']; Normalise = 1; color = 'b';
elseif nargin == 3
    thickness = 2; Name = ['']; Normalise = 1;color = 'b';
elseif nargin == 4
    thickness = 2; Normalise = 1;color = 'b';
elseif nargin == 5
    Normalise = 1;color = 'b';
elseif nargin == 6
    color = 'b';
end

if Normalise == 1
    Normalise =1;
elseif Normalise ~= 1
    Normalise = sum(var(:,y));
end

h = plot(var(:,x), var(:,y)./Normalise, 'linewidth', thickness, 'color', color);
title = varname(var);
set(h,{'Displayname'},{Name})
legend show

axis([15 90 100 100000]);
%set(gca,'XTick',[0:100:250]);
%set(gca,'YTick',[0:0.25:1]);
ylabel('Intensity (counts)','FontSize', 30, 'FontName', 'Arial');
xlabel('Two Theta (degrees)','FontSize', 30, 'FontName', 'Arial');

set( gcf , 'PaperUnits' , 'Centimeters' ,...
'Units' , 'Centimeters' ,...
'PaperOrientation' , 'Portrait' ,...
'PaperPositionMode' , 'auto' ,...
'Position' , [1 1 40 20] );
PAPER = get( gcf , 'Position' );
set ( gcf , 'PaperSize' , [PAPER(3) PAPER(4)] );
set( gca , 'Units' , 'centimeters' ,...
'Position' , [4.5 3.5 23.25 13.25] ,...
'FontSize' , 30 ,...
'FontName' , 'Arial' )

set( gca , ...
'FontSize' , 30 ,...
'FontName' , 'Helvetica',...
'YScale', 'log')
end

