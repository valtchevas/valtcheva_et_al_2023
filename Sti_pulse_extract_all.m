basepath = 'E:\Fiber_Photometry_Analysis\FP_files'; %% path to folder
files = dir(basepath);
for ii = 3:length(files)
    cd([basepath,'\',files(ii).name]);
    datafiles = dir(pwd);
       for jj  = 3:length(datafiles)
           cd([basepath,'\',files(ii).name,'\',datafiles(jj).name]);
           data = dir(['*.mat']);
           value = load(data.name);
           RF_getPupCall;
           cd ..
       end
    cd ..
end
