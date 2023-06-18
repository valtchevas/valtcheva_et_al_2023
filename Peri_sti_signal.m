clear all;clc;
basepath = 'E:\Fiber_Photometry_Analysis\FP_files'; %% path to folder
files = dir(basepath);
for ii = 3:length(files)
    cd([basepath,'\',files(ii).name]);
    datafiles = dir(pwd);
       for jj  = 3:length(datafiles)
           cd([basepath,'\',files(ii).name,'\',datafiles(jj).name]);
           data = dir(['*.mat']);
           value = load(data(1).name);
           load([datafiles(jj).name,'.pulses.events.mat']);
           if isfield(value,'ans')==1
                fs = length(value.iso)/value.ans.epocs.Tick.onset(end);
           else fs = 1018; %% ask experimentor 
           end
           
           win = round((pulses.intsPeriods(:,1) + [-20 120])*fs);% seconds before and seconds after 
           Ca_peri = [];iso_peri = [];
           for kk = 1:length(pulses.intsPeriods);
               if win(kk,2) < length(value.Ca)
                   Ca_peri(kk,:) = value.Ca(win(kk,1):win(kk,2));
                   iso_peri(kk,:) = value.iso(win(kk,1):win(kk,2));
               end  
               save('signal_peri.mat','Ca_peri','iso_peri','fs');
           end           
           cd ..
       end
    cd ..
end

