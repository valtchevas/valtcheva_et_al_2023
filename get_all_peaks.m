clear all;clc;
basepath = 'E:\Business and friend work\Robert Fromeki\FP files-20221002T150414Z-001\FP files';
cd(basepath)
%% path to folder
files = dir(basepath);

for ii = 3:length(files)
    cd([basepath,'\',files(ii).name]);
    datafiles = dir(pwd);
    all_peri_dF = [];dirFlags = [datafiles.isdir];
    subFolders = datafiles(dirFlags);pks_all = [];tms_all = [];
       for jj  = 3:length(subFolders)
        cd([basepath,'\',files(ii).name,'\',subFolders(jj).name]);       
        %% get pks locs of each trial
        load('peakInfo.mat')
        if length(peakInfo.am) <= 4
            pks_all = [pks_all;peakInfo.am'];
            tms_all = [tms_all;peakInfo.ts'];
        else 
            pks_all = [pks_all;peakInfo.am(1:4)'];
            tms_all = [tms_all;peakInfo.ts(1:4)'];
        end
       end
      cd ..
    save('peakInfo_all.mat','pks_all','tms_all')
    cd ..
    close all
end
