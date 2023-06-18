clear all;clc;
%%%% change locations
basepath = 'E:\Fiber_Photometry_Analysis\FP_files'; 
cd(basepath)

%% path to folder
files = dir(basepath);
rmpath('C:\Users\XX\Documents\MATLAB\chronux_2_12\spectral_analysis\continuous'); %% find where is your chronux_2_12 toolbox

for ii = 3:length(files)
    cd([basepath,'\',files(ii).name]);
    datafiles = dir(pwd);
       for jj  = 3:length(datafiles)
        cd([basepath,'\',files(ii).name,'\',datafiles(jj).name]);
        data = load('signal_peri.mat');
        %% dF/F computation
        dFoverF_peri = []
        for kk = 1:size(data.Ca_peri,1)
            ch405=double(data.iso_peri(kk,:));                                            % load isosbestic data (but ignore long pre stim baseline)
            ch490=double(data.Ca_peri(kk,:));                                             % load calcium imaging data (but ignore long pre stim baseline)
            % or using a moving average
            F490=smooth(ch490,299,'moving'); 
            F405=smooth(ch405,299,'moving');

            %% correct gcamp signal based on isosbestic channel
            bls=polyfit(F405(1:end),F490(1:end),1);                                    % regression of isosbestic and signals against each other
            % scatter(F405(10:end-10),F490(10:end-10))                                   % plot to check it out
            yfit=bls(1).*F405+bls(2);
            %% df/f
            df=(F490(:)-yfit(:))./yfit(:); 
            tm = [1:length(df)]/data.fs;
            figure;
            subplot(411);plot(tm,df.*100,'k'); hold on;xline(20,'r--');
            ylabel('%dF/F')
            title([datafiles(jj).name,'-',num2str(kk)]); 
            xlabel('Time (s)');
            subplot(412);plot(tm, F405, 'r'); hold on;xline(20,'r--');
            title('isosbestic');
            xlabel('Time (s)');
            subplot(413); plot(tm,F490, 'g'); hold on;xline(20,'r--');
            title('gcamp');
            xlabel('Time (s)');% not percentage df/f
                     
            durations = 1000;
            df_win =smoothdata(df(tm>20&tm<140)',1000);
            subplot(414);findpeaks(df,'minpeakheight',median(df_win)+3*std(df_win),...
                'WidthReference','halfprom','MinPeakDistance',durations(1)*2); 
            title('time-shifted at 0');hold on; xline(0.1,'r--');
            
            savefig(gcf,[datafiles(jj).name,'-',num2str(kk)])
            dFoverF_peri(kk,:) = df';
        end   
        save('dFoverF_peri.mat','dFoverF_peri')
        cd ..
       end
    cd ..
end
addpath('C:\Users\yiyao\Documents\MATLAB\chronux_2_12\spectral_analysis\continuous');
