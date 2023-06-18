
clear all;clc;
basepath = 'E:\Fiber_Photometry_Analysis\FP_files';
cd(basepath)
rmpath('C:\Users\XX\Documents\MATLAB\chronux_2_12\spectral_analysis\continuous');

%% path to folder
files = dir(basepath);

for ii = 3:length(files)
    cd([basepath,'\',files(ii).name]);
    datafiles = dir(pwd);
    all_peri_dF = [];dirFlags = [datafiles.isdir];
    subFolders = datafiles(dirFlags);
       for jj  = 3:length(subFolders)
        cd([basepath,'\',files(ii).name,'\',subFolders(jj).name]);
        load('dFoverF_peri.mat');load(['signal_peri.mat']);
        %% dF/F computation
        all_peri_dF_in = [];
        for kk = 1:size(dFoverF_peri)
            data = dFoverF_peri(kk,:);
            x = [1:length(data)];
            xq = [1:(fs/100):length(data)];
            data1 = interp1(x,data,xq);
            all_peri_dF_in(kk,:) = data1(1:14000);
        end
        all_peri_dF = [all_peri_dF;all_peri_dF_in];
        
        h = figure('Units', 'normalized');
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        options.alpha      = 0.5;
        options.line_width = 2;
        options.error      = 'sem';
        options.x_axis = [1:length(all_peri_dF)]./100-20;
        plot_areaerrorbar(smoothdata(all_peri_dF,2), options);
        xlim([-20 inf]);xline(20,'b');
        df_win = median(all_peri_dF(:,2000:14000));
        durations = 100;
        [pks,locs] = findpeaks(df_win,'minpeakheight',median(df_win)+3*std(df_win),...
            'WidthReference','halfprom','MinPeakDistance',durations(1)*2);
        
        %% get pks locs of each trial
       end
      cd ..
      savefig(h,[files(ii).name,'.fig']);
      print(h,[files(ii).name,'.dsvg']);
      save('all_peri_dF.mat','all_peri_dF','pks','locs');
    cd ..
    close all
end
addpath('C:\Users\yiyao\Documents\MATLAB\chronux_2_12\spectral_analysis\continuous');
