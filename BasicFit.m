function [Data] = BasicFit(var,q)
LoadGrad = (smooth(gradient(var.Test(:,3)),10));
start = find(LoadGrad<min(LoadGrad)./2,1);
x = var.Test(start:end,2)*10^-9; y = var.Test(start:end,3)*10^-6; time = var.Test(start:end,1);
%% Correct Based on final hold creep rate
% Hold_start = find(LoadGrad(start:-1:1)>max(LoadGrad)./2,1);
% h = var.Test(start-Hold_start:start,2).*10^-9; t = var.Test(start-Hold_start:start,1);
% [strainrate, est, h, dhdt]=Disp_fit(t, h);
% figure(q), plot(x,y); hold on;
% dPdt = (y(end)-y(1))./(time(end)-time(1));
% x = x-dhdt(end).*(time-time(1));
%% Fit as a power law curve
power = 2; guess = [max(y)./(max(x)-min(x))^power, min(x), power];
peak2fit = spec1d(x, y, ones(length(y),1).*0.001); %using 1microN as error
[~, data] = fits(peak2fit, 'Power_unload', guess, [1 1 1]); 
% equation for fit eq(3) from https://doi.org/10.1557/JMR.2002.0386 
P = (data.pvals(1).*(x-data.pvals(2)).^(data.pvals(3)));
figure(q), plot(x,y); hold on; plot(x,P)
dPdh = (data.pvals(1).*data.pvals(3)).*(x-data.pvals(2)).^(data.pvals(3)-1);
figtitle = ['Modulus ' num2str(((0.5*(pi^0.5)).*dPdh(1)./(((24.5)^0.5).*max(x)))./10^9) ' GPa'];
title(figtitle)
IndenterMod = ((0.5*(pi^0.5)).*dPdh(1)./(((24.5)^0.5).*max(x)));
IndenterHard = max(y)./(24.5.*max(x).^2);
Data(:,q) = [max(x), dPdh(1), max(y), IndenterMod, IndenterHard];

clear figtitle data dPdh guess IndenterHard IndenterMod LoadGrad P peak2fit power start x y
end