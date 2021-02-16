%% High Load Data
folder = uigetdir;
var = dir(folder);
Region = strsplit(folder, '\'); Region = Region{end};
for f = 3:length(var)
        if contains(var(f).name, '.hld') == 1
                data = importdata([var(f).folder '\' var(f).name], ' ', 100000);
                BeginingOfTime = find(contains(data, 'Time')==1);
                k = 1; clear h; 
                for h = BeginingOfTime(end-1)+1:BeginingOfTime(end)-2 
                    DriftRate(k,:) =cellfun(@str2num,split(data{h}))'; 
                    k = k +1; 
                end
                k = 1; clear h; 
                for h = BeginingOfTime(end)+1:length(data) 
                    TestData(k,:) =cellfun(@str2num,split(data{h}))'; 
                    k = k +1; 
                end
                %This bit can take up to 45s each time
                varname = ['cant_' Region '.Data_' var(f).name(1:end-4)]; %Add front leter
                varname = strrep(varname,' ','_');
                eval([varname '.Test =TestData;']);
                eval([varname '.Drift =DriftRate;']);
                BeginingOfTime = find(contains(data, 'Time')==1);
                DriftHead = data{BeginingOfTime(end-1)};
                CreepHead = data{BeginingOfTime(end)}; 
                %------------------------------------
                clear BeginingOfTime data TestData DriftRate varname 
        end
        fprintf('Complete %d of %d \n', f , length(var))
end
clear f h k        
%% Analysis to get Modulus and Hardness data
%% change the name and number 1-3 for each temperature set
%name = 'TR25C_.Data_PartialUnload7_5mN'; no=1; clear var
Region = 'BM_Area_1';
eval(['Area =' Region ';']);
name = fieldnames(Area);

for q = 1:length(name)-3
a=1;
eval(['var = ' Region '.' name{q} ';'])
%Partial Unload
if max(var.Test(:,1))>60
time = (round(max(var.Test(:,1))*10))./10-1;
%Look at all hold segments
for loop=1:20
j = find(var.Test(:,1)>time,1);
if isempty(j) == 1; j = length(var.Test); end 
i = find(var.Test(:,1)>time-1,1);
[~,turn] = min(var.Test(i:j,2));
figure(a), hold off;
figure(a), plot(var.Test(i:j,2))%,var.Test(i:j,3))%./(24.5.*(var.Test(i:j,2)).^2))
x = var.Test(i+turn:j,2); y = var.Test(i+turn:j,3);
[m, c, m_e, dc, r] = linfit([1:length(x)]',gradient(x),ones(length(x),1).*0.01);
figure(a), hold on;
figure(a), plot((1:length(x)), x, 'r')
figure(a), plot((1:length(x)), min(x)+cumsum((1:length(x))*m+c))
Data = [min(x), max(x), length(x),turn, m, c, m_e, dc, r, mean(y)];
Record(:,a)=Data;
a=a+1;
time = time-3;
end
clear x y a turn m c m_e dc r i j 
HoldCreep = [Record(10,:);Record(1,:);Record(3,:);Record(5,:);Record(6,:); Record(3,:).*Record(5,:)+Record(6,:)];
time = (round(max(var.Test(:,1))*10))./10;
a=1;
CreepDrift = (Record(3,:)+(1:310)').*Record(5,:)+Record(6,:);
CreepLoad = repmat(Record(10,:),310,1);
CreepTime = repmat((1:310)',1,20);
[xq,yq] = meshgrid(1:5100, 1:310);
Creep = griddata(CreepLoad,CreepTime,CreepDrift,xq,yq);
%Fill in Nan values above and below
Low = find(isnan(Creep(1,:))<1,1); High = find(isnan(Creep(1,Low+1:end))==1,1)+Low;
Creep(:,High:end)= repmat(Creep(:,High-1),1,5100-High+1);
Creep(:,1:Low)= repmat(Creep(:,Low+1),1,Low);
close all
clear xq yq CreepTime CreepLoad CreepDrift 

for loop=1:20
j = find(var.Test(:,1)>time,1);
if isempty(j) == 1; j = length(var.Test); end 
i = find(var.Test(:,1)>time-1,1);
[~,turn] = max(var.Test(i:j,2));
y = (var.Test(i:j,3)); y(y<1)=1;
for k = 1:length(y); creephold(k)=Creep(k,abs(round(y(k)))); end
x = (var.Test(i:j,2)-cumsum(creephold)').*10.^(-9);
y = y.*10.^(-6);
figure(a), hold off;
figure(a), plot(x,y)%./(24.5.*(var.Test(i:j,2)).^2))
for z = 1:6; [~, ~, ~, ~, r(z)] = linfit(x(1:z*50),y(1:z*50),y(1:z*50).*0.05); end
[~,z]=max(r);
[m, c, m_e, dc, r] = linfit(x(1:z*50),y(1:z*50),y(1:z*50).*0.05);
figure(a), hold on;
figure(a), plot(x, y, 'r')
figure(a), plot(x, x.*m+c)
Data = [min(x), max(x), turn, m, c, m_e, dc, r, max(y)];
RecordUnload(:,a)=Data;
a=a+1;
time = time-3;
clear x y m c m_e dc r Data creephold turn
end

%Single Unload
else 
    [Data] = BasicFit(var,q);
    RecordUnload(:,q) = Data;
    clear x y m c m_e dc r Data creephold turn figtitle h t P time
end

eval([Region  '.Modulus(1:size(RecordUnload,2),q) = ((0.5*(pi^0.5)).*(RecordUnload(4,:)./((24.5)^0.5.*RecordUnload(2,:))));'])
eval([Region  '.Hardness(1:size(RecordUnload,2),q) = RecordUnload(9,:)./((24.5).*RecordUnload(2,:).^2);']);
eval([Region  '.Depth(1:size(RecordUnload,2),q) = RecordUnload(2,:);']);
%close all
% figure, plot(RecordUnload(2,:), RecordUnload(4,:))
% xlabel('nm'); ylabel('Stiffness')
eval([Region '.' name{q} '.Record = RecordUnload']);
eval([Region '.' name{q} '.LoadDrift = HoldCreep']);
clear a b c Data dc HoldCreep f i j m m_e r Record time turn x y RecordUnload 
end

%% Analysis for Creep rate
name = 'TR25C_.Data_Creep10_1_5mN'; no=1;
a=1;
eval(['var = ' name ';'])
StaticLoad = find(gradient(smooth(var(:,3),100))<0);
[~,p] = max(gradient(StaticLoad)); 
Start = StaticLoad(p+1);
StaticLoad = find(gradient(smooth(var(:,3),100))>0);
[~,p] = max(gradient(StaticLoad));
fin = StaticLoad(p); clear StaticLoad p 
if fin<Start; fin = length(var); end
time = var(Start:fin,1); disp = var(Start:fin,2); 
Pressure = (10^12).*var(Start:fin,3)./(24.5.*var(Start:fin,2).^2);
[Pressure, strainrate, est]=Disp_fit(time, disp, Pressure);
eval([name '.Pressure = Pressure;']);
eval([name '.' list{k} '.strainrate = strainrate;']);
eval([name(i).name '.' list{k} '.est = est;']);
SumP(1:length(Pressure),no) = Pressure; SumSR(1:length(strainrate),no) = strainrate; SumE(1:length(est),no) = est;
figure(3), plot(Pressure, strainrate, 'DisplayName', [things(i).name ' ' list{k}])
clear Pressure strainrate est time disp
eval([name(1:6) '.SumP = SumP;']);
eval([name(1:6) '.SumSR = SumSR;']);
eval([name(1:6) '.SumE = SumE;']);


function [Pressure, strainrate, est]=Disp_fit(time, disp, Pressure)
figure(10), plot(time,disp-disp(1)); hold on %Raw data
ylabel('creep displacement (nm)'); xlabel('time held at load (s)')
%Fit displacement
%check size
[uV ~] = memory; info = whos('time');
if (uV.MaxPossibleArrayBytes)^0.5<info.bytes
    factor = floor(8.*length(time)./(uV.MaxPossibleArrayBytes)^0.5); 
    time = time(1:factor:end); disp = disp(1:factor:end); Pressure = Pressure(1:factor:end);
end
peak2fit = spec1d(time(1:ans), disp(1:ans), (disp(1:ans)).*0.1);
power = -0.5;
EndGrad = (disp(end)-disp(round(end/2)))./(time(end)-time(round(end/2)));
Intcept = disp(end)-EndGrad.*time(end);
decrease = -(Intcept + EndGrad.*50-disp(find(time>50,1)))./(50^(power));
guess = [Intcept , EndGrad, decrease, power];
[fittedpeak, data] = fits(peak2fit, 'creep_disp', guess, [1 1 1 1]);
%plot(fittedpeak)
h = data.pvals(3).*(time).^(data.pvals(4)) + data.pvals(2).*(time) + data.pvals(1); 
eh = data.evals(3).*(time).^(data.evals(4)) + data.evals(2).*(time) + data.evals(1); 
figure(10), plot(time, h-disp(1)) %Fit of raw data
%Strain rate from J. Mater. Res., Vol. 27, No. 1, Jan 14, 2012
dhdt = data.pvals(3).*data.pvals(4).*(time).^(data.pvals(4)-1) + data.pvals(2);
%figure(2), plot(time,dhdt.*disp./disp(1), 'DisplayName', [named{i} ' dhdt' ]) %strain rate
%xlabel('time held at load (s)'); ylabel('strain rate*h/h0 (s^{-1})')

% %Fit stress relaxation
% peak2fit = spec1d(time-time(1), Pressure, Pressure.^0.5);
% [~,dataP] = fits(peak2fit, 'creep_disp', [3e6 0 7e7 -1], [1 1 1 1]);
% stressrelaxrate = dataP.pvals(3).*dataP.pvals(4).*(time-time(1)).^(dataP.pvals(4)-1) + dataP.pvals(2);
% figure(3), plot(time-time(1),stressrelaxrate./stressrelaxrate(1), 'DisplayName', [named{i} ' dstressdt' ])
strainrate = dhdt./h; est = strainrate.*eh./h;
%figure(3), plot((time-time(1)), strainrate, 'DisplayName', named{i})
%xlabel('time held at load (s)'); ylabel('strain rate')
% figure(4), plot(Pressure(a:end), strainrate(a:end), 'DisplayName', [named{i} ' ' num2str(max(disp))])
% xlabel('Pressure (Pa)'); ylabel('strainrate')
% All_P(a,1:251) = interp1(strainrate,Pressure,SR);
%figure(6), plot((time-time(1)), abs(stressrelaxrate./strainrate), 'DisplayName', named{i})
%[n,Everythin,dn,dE,r] = linfit(log(Pressure), log(strainrate), log(est./strainrate));
%figure(5), plot(log(Pressure), log(strainrate), 'DisplayName', named{i})
%xlabel('log stress'); ylabel('log strainrate')
% eval('n_r(i) = n;');
% eval('n_re(i) = dn;');
% a = a+1;
% clear var time disp Pressure peak2fit guess data h eh fittedpeak dhdt strainrate est n dn dE r   
end
