function [strainrate, est, h, dhdt]=Disp_fit(time, disp)
%figure(10), plot(time,disp-disp(1)); hold on %Raw data
%ylabel('creep displacement (nm)'); xlabel('time held at load (s)')
%Fit displacement
%check size
[uV ~] = memory; info = whos('time');
if (uV.MaxPossibleArrayBytes)^0.5<info.bytes
    factor = floor(8.*length(time)./(uV.MaxPossibleArrayBytes)^0.5); 
    time = time(1:factor:end)-time(1); disp = disp(1:factor:end); 
else 
    time = time-time(1);
end
peak2fit = spec1d(time, disp, ones(length(disp),1).*0.1.*10.^(-9));%data taken as accurate to 0.1nm
power = 0.5; h0 = disp(1);
EndGrad = (disp(end)-disp(round(end-10)))./(time(end)-time(round(end-10)));
decrease = (time(end).^power).*(((disp(end)-h0)./(time(end))));
guess = [h0 , EndGrad, decrease, power];
figure, plot(time, disp); hold on; plot(time, feval('creep_disp', time, guess))
[fittedpeak, data] = fits(peak2fit, 'creep_disp', guess, [1 1 1 1]);
%plot(fittedpeak)
h = data.pvals(3).*(time).^(data.pvals(4)) + data.pvals(2).*(time) + data.pvals(1); 
eh = data.evals(3).*(time).^(data.evals(4)) + data.evals(2).*(time) + data.evals(1); 
%figure(10), plot(time, h-disp(1)) %Fit of raw data
%Strain rate eq(12) from J. Mater. Res., Vol. 27, No. 1, Jan 14, 2012
dhdt = data.pvals(3).*data.pvals(4).*(time).^(data.pvals(4)-1) + data.pvals(2);
strainrate = dhdt./h; est = strainrate.*eh./h; 
end