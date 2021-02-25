h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif';
var = var.Test;
for n = 1:2626 %length(var)
    % Draw plot for y = x.^n
    t = var(1:n,2)*10^-9;
    d = var(1:n,3)*10^-3;
    plot(t,d, 'r')
    axis([0 6e-5 0 25])
    xlabel('Displacement (m)'); ylabel('Load (\muN)') 
    drawnow 
      % Capture the plot as an image 
      frame = getframe(h); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if n == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end
  
%If created gif doesn't run in powerpoint etc contact Ed Darnbrough he can 
% use VirtualDub to change the codex to an animated gif