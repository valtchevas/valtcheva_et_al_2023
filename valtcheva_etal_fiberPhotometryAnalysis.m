function []= valtcheva_etal_fiberPhotometryAnalysis(filelocation)
%% valtcheva_etal_fiberPhotometryAnalysis
% Inputs
% filelocation: location of files, make sure they are included in your
% path, and should be a string
%   assumptions: 
%       files should be .mat files produced by TDT synapse, they
%       should be named using this format: animalname_datecollected.mat
% Outputs
% .csv files are produced along the way and should be located in the same
% folder as the data. they will be named with the animal name and date the
% data was collected. 
% 
% last edited 03/16/21 KM
%% select and load data file
starti=strfind(filelocation, '/'); 
midi=strfind(filelocation, '_'); 
stopi=strfind(filelocation, '.');
location=filelocation(1:starti(end));
animal=filelocation(starti(end)+1:midi(end)-1); 
date=filelocation(midi(end)+1:stopi(end)-1); 
data=load(filelocation);                                                   % load data

%% hardcoded variables - need to know from recording
sr=1017.25;                                                                % sampling rate in hz, this is based on your specific set up

%% auditory (or whatever other) stimulus - should be represented by ttl pulses
% check this first to get rid of any junk in the beginning to disregard as
% you are setting things up 
stim = double(data.input);                                                 % this is TTL pulses for individual pup calls
firststim = find(diff([0 stim])>1, 1, 'first');                            % extract index of first stimulus
tosub = 120*sr;                                                            % only uses data from 2min (120s) prior to stimulus (based on potential initial artifacts)
ts=firststim-tosub;                                                        % index to start displaying data
if ts <0                                                                   % if there isn't much time before stimuli start playing, handle that
    ts=500; 
end
allstim=find(abs(diff([0 stim(ts:end)]))>1);                               % indices of pupcalls within cut file
allstimtime = allstim./sr;                                                 % time of pupcalls 

%% calculate time from samples
if length(data.Ca(ts:end)) == length(data.iso(ts:end))                     % making sure our actual/control data is the same length
    time=(1:length(data.Ca(ts:end)))/sr;                                   % N data points/sampling rate
end

%% get into specifics from data files (extract isosbestic and calcium imaging)
ch405=double(data.iso(ts:end));                                            % load control channel 
ch490=double(data.Ca(ts:end));                                             % load signal channel

%% filter/smooth the data 
% using a lowess filter
% F490=smooth(ch490,0.002,'lowess'); 
% F405=smooth(ch405,0.002,'lowess');

% or using a moving average
F490=smooth(ch490,499,'moving'); 
F405=smooth(ch405,499,'moving');

%% correct gcamp signal based on control channel                           (method based on Bruno, et al., 2020)
bls=polyfit(F405(1:end),F490(1:end),1);                                    % regression of control and signal channels against each other
% figure; scatter(F405(10:end-10),F490(10:end-10))                           % plot to check it out
yfit=bls(1).*F405+bls(2);                                                  % normalize the control channel 

%% df/f
df=(F490(:)-yfit(:))./yfit(:);                                             % df/f - normalized by scaled control channel
% df=df.*100;                                                              % this is in percentage df/f

%% zscore for entire file 
ind=40*sr;                                                                 % zscore based on 40s baseline pre first stimulus 
df_b=df((allstim(1)-ind):allstim(1),1);
zs_df=(df-mean(df_b))./std(df_b);

%% plot everything to see how it looks (general)
figure;
subplot(411);plot(time, df.*100,'k'); hold on;
plot(allstimtime, ones(numel(allstimtime),1), 'b.');
ylabel('% dF/F')
title('df'); 
subplot(412);plot(time, zs_df, 'k'); 
title('zscore');
subplot(413);plot(time, F405, 'r'); 
title('control');
subplot(414); plot(time, F490, 'g'); 
title('signal');
xlabel('Time (s)');

%% compare pre, during, and post each pup call set
bi=find(diff([0 allstim])>10000);                                          % find the beginning of each set of pup calls 
prei=allstim(bi);                                                          % index of set start
posti=allstim([bi(2:end)-1 end]);                                          % index of set end
pre=round([prei'-(20*sr) prei']);                                          % pre set start (20s)
post=round([posti' posti'+(40*sr)]);                                       % post set start (40s - bc of variable time btwn sets)

for j=1:numel(prei)
    
    % df/f mean
    dfmean(j,1)=mean(df(pre(j,1):pre(j,2),:));                             % "pre" 
    dfmean(j,2)=mean(df(pre(j,2):post(j,1),:));                            % "call"
    dfmean(j,3)=mean(df(post(j,1):post(j,2),:));                           % "post"

    % df/f median
    dfmed(j,1)=median(df(pre(j,1):pre(j,2),:));                            % "pre"
    dfmed(j,2)=median(df(pre(j,2):post(j,1),:));                           % "call"
    dfmed(j,3)=median(df(post(j,1):post(j,2),:));                          % "post"

    % df/f max
    dfmax(j,1)=max(df(pre(j,1):pre(j,2),:));                               % "pre"
    dfmax(j,2)=max(df(pre(j,2):post(j,1),:));                              % "call"
    dfmax(j,3)=max(df(post(j,1):post(j,2),:));                             % "post"
    
    bl=(df(pre(j,1):pre(j,2),:));                                          % baseline to zscore pre every set
    % zscore mean
    zsmean(j,1)=mean((df(pre(j,1):pre(j,2),:)-mean(bl))./std(bl));         
    zsmean(j,2)=mean((df(pre(j,2):post(j,1),:)-mean(bl))./std(bl));
    zsmean(j,3)=mean((df(post(j,1):post(j,2),:)-mean(bl))./std(bl));

    % zscore median
    zsmed(j,1)=median((df(pre(j,1):pre(j,2),:)-mean(bl))./std(bl));
    zsmed(j,2)=median((df(pre(j,2):post(j,1),:)-mean(bl))./std(bl));
    zsmed(j,3)=median((df(post(j,1):post(j,2),:)-mean(bl))./std(bl));

    % zscore max
    zsmax(j,1)=max((df(pre(j,1):pre(j,2),:)-mean(bl))./std(bl));
    zsmax(j,2)=max((df(pre(j,2):post(j,1),:)-mean(bl))./std(bl));
    zsmax(j,3)=max((df(post(j,1):post(j,2),:)-mean(bl))./std(bl));
end

%% save a couple variables to potentially use later 
% prepare info to write a .csv file w this info
A=zeros(numel(time),1); 
A(allstim,:)=1;
csvwrite([location animal '_' date '_df'],[time',df.*100,zs_df,F405,F490,A]);

% currently only writing out df and zscore mean - can include other things computed above
if numel(prei)>5                                                           % only consider the first 5 sets
    csvwrite([location animal '_' date '_dfmean'],dfmean(1:5,:));   
    csvwrite([location animal '_' date '_zsmean'],zsmean(1:5,:));
else
    csvwrite([location animal '_' date '_dfmean'],dfmean);
    csvwrite([location animal '_' date '_zsmean'],zsmean);
end
