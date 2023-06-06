clear all;
datafiles = dir(pwd);
all_peri_dF = [];dirFlags = [datafiles.isdir];
subFolders = datafiles(dirFlags);
for jj  = 3:length(subFolders)
cd([subFolders(jj).folder,'\',subFolders(jj).name]);
load('dFoverF_peri.mat');load(['signal_peri.mat']);
%% dF/F computation
all_peri_dF_in = [];
if size(dFoverF_peri,1)<4
    for kk = 1:size(dFoverF_peri,1)
        data = dFoverF_peri(kk,:);
        x = [1:length(data)];
        xq = [1:(fs/100):length(data)];
        data1 = interp1(x,data,xq);
        all_peri_dF_in(kk,:) = data1(1:14000);
    end
else
    for kk = 1:4
        data = dFoverF_peri(kk,:);
        x = [1:length(data)];
        xq = [1:(fs/100):length(data)];
        data1 = interp1(x,data,xq);
        all_peri_dF_in(kk,:) = data1(1:14000);
    end
end
all_peri_dF = [all_peri_dF;all_peri_dF_in];
%% get pks locs of each trial
end
cd ..
miu = mean(all_peri_dF(:,1:2000),2);
sigma = std(all_peri_dF(:,1:2000),0,2);
Norm_dF_all = (all_peri_dF-miu)./sigma ;
h = figure;
x_axis = [1:length(all_peri_dF)]./100-20;
peri_dF = median(Norm_dF_all);
plot(x_axis, smoothdata(peri_dF,'gaussian',fs),'k','LineWidth',1);

hold on
peri_dF = mean(Norm_dF_all);
plot(x_axis, smoothdata(peri_dF,'gaussian',fs),'b','LineWidth',1);
xlim([-20 inf]);xline(0,'r--');yline(0,'r--');xlabel('Time(s)');ylabel('dF/F(z-scored)');


legend('median','mean','Audio signal')

filename = pwd;
[filepath,name,ext] = fileparts(filename);
savefig(h,[name,ext,'_',num2str(fs),'_Normed_mean_median','.fig']);
print(h,[name,ext,'_',num2str(fs),'_Normed_mean_median','.svg']);


