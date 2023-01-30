names = fieldnames(Area_1);

for q = 1:length(names)
    
    eval(['VAR = ' names{q} ';']);
    subnames = fieldnames(VAR);
    for w = 1:length(subnames)
        eval(['var = ' names{q} '.' subnames{w} ';'])
        LoadGrad = (smooth(gradient(var.Test(:,3)),10));
        figure(69), hold on; 
        figure(69), plot(LoadGrad); 
        fin(1) = length(LoadGrad);
        for loop = 1:20 %number of unload and holds
            Ustart = find(LoadGrad(fin:-1:1)<min(LoadGrad(1:fin))./2,1);
            Ustart = find(LoadGrad(fin-Ustart-1:-1:1)>min(LoadGrad(1:fin))./3,1)+Ustart;
            Hstart = find(LoadGrad(fin-Ustart:-1:1)>max(LoadGrad)./2,1);
            figure(69), stem(fin-Ustart,10); figure(69), stem(fin-Ustart-Hstart,10);
            h = var.Test(fin-Ustart-Hstart:fin-Ustart,2).*10^-9; t = var.Test(fin-Ustart-Hstart:fin-Ustart,1);
            [strainrate, est, h, dhdt]=Disp_fit(t, h);
            %Now pick a version of your creep hold to use as correction
            P = var.Test(fin-Ustart-Hstart:fin-Ustart,3)./(24.5*h.^2);
            %simplest here is the last dhdt
            x = var.Test(fin-Ustart:fin,2)*10^-9; y = var.Test(fin-Ustart:fin,3)*10^-6; time = var.Test(fin-Ustart:fin,1);
            x = x-time.*dhdt(end);
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
            Data(:,loop) = [max(x), dPdh(1), max(y), IndenterMod, IndenterHard];
            fin = find(LoadGrad(fin-Ustart-Hstart:-1:1)<0,1);
        end
        eval(['Area_1.' names{q} '.' subnames{w} '= Data;']);
        clear figtitle data dPdh guess IndenterHard IndenterMod LoadGrad P peak2fit power start x y Data
    end
end