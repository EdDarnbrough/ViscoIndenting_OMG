function [] = SaveandClose(folder,type,number)
if nargin == 0
    folder = cd; type = '-djpeg'; number = 0;
elseif nargin == 1
    type = '-dpng'; number = 0;
elseif nargin == 2
    number = 0;
end

for i = 1:length(findobj('type','figure'))
    set(gcf,'PaperPositionMode','auto')

    if isempty(get(gcf, 'Name')) ==1
        h = get(gcf, 'Number');
    elseif isempty(get(gcf, 'Name')) ==0
        h = get(gcf,'Name'); 
    end
    
    print([folder '\' num2str(number) '_' sprintf('%d',h)],type, '-r0');close(h);
end
end
    