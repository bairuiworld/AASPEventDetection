% Load Development Data
% Perform perfect segmentation using annotation file
% 
% Authors: Christian Sherland
%          Sameer Chauhan
%          Sharang Phadke
%
% Date: 2-27-13
%
% Project: Speech Processing Signal Segmentation
%
% Bugs: 
% 
globalVar;

%Read time tags for dev set
fid = fopen('../Datasets/Office Live/events_OL_development/annotation1/script01_bdm.txt');
devAnnots = textscan(fid,'%f%f%s','delimiter','\t');
fclose(fid);

%Read dev dataset sound file
[fullDev,fs] = wavread('../Datasets/Office Live/events_OL_development/bformat/script01-01.wav');

% initialize things
times = 0:pointOhOne:length(fullDev)/fs;
devSignals = cell(length(devAnnots{1}),1);
devLabels = zeros(length(devAnnots{1}),1);
fullDevLabels = zeros(length(times)-1,1);

%Parse dev data signals with annotation tags
for ii = 1 : length(devAnnots{1})
   devSignals{ii} = fullDev(ceil(devAnnots{1}(ii)*fs):ceil(devAnnots{2}(ii)*fs));
   devLabels(ii) = getClassNum(devAnnots{3}(ii));
   
   ind = find((times >= devAnnots{1}(ii)).*(times <= devAnnots{2}(ii))); 
   fullDevLabels(ind) = 1;
end

% get features of full signal and of the events only
fullDevFeatures = getFeatures(fullDev,fs,pointOhOne);
devFeatures = getFeatures(devSignals,fs,pointOhOne,'CELL'); % keep this in cell format for now

fname = './MAT files/development.mat';
save(fname,'fs','fullDev','fullDevLabels','fullDevFeatures','devSignals','devLabels','devAnnots','devFeatures');