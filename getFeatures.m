function [ Features, Labels, LabelsExpanded ] = getFeatures( signals, fs, winTime, varargin )
%getFeatures extracts all relevant features from a signal or set of signals
%   optional arguments:
%   'TIMES' can be used to input the matrix of segmented times
%   'LABELS' can be used to input label vector
%   'NUMCEPS' can be used to specify the # of melfcc coefficients (max 13)
%   'CELL' can be used to return a feature cell broken up by events instead
%   of a single feature matrix, IF THERE ARE MULTIPLE EVENTS
%   'EXPANDED' returns expanded labels
% 
%   [ Features, Labels ] = getFeatures( signals, Fs, winTime, varargin )
% 
%   The feature order is [melfccs, specCentroid, STE, loudness,
%   SpectralFlux, SpectralEntropy, SpectralRollOff, wavelets]

Features = []; Labels = [];
TIMES = []; ANNOTS = [];
numCeps = 20;

entropyBins = 10;
RolOffThresh = 0.5;
% longTime = [1 4 14:19];

if ~isempty(varargin)
    tindex = find(strcmp(varargin,'TIMES'),1);
    aindex = find(strcmp(varargin,'ANNOTS'),1);
    nindex = find(strcmp(varargin,'NUMCEPS'),1);
    cindex = find(strcmp(varargin,'CELL'),1);
    
    if ~isempty(tindex)
        TIMES = varargin{tindex+1};
    end
    if ~isempty(aindex)
        ANNOTS = varargin{aindex+1};
    end
    if ~isempty(nindex)
        numCeps = min([varargin{nindex+1},13]);
    end
end

if iscell(signals)
    Features = cell(length(signals),1);
    
    for n = 1:length(Features)
        FeatureLen = floor(length(signals{n})/(winTime*fs));
        
        Features{n} = [...
            melfcc(signals{n},fs,'wintime',winTime,'hoptime',winTime,'numcep',numCeps)'...
            SpecCentroid(signals{n},winTime*fs,0,winTime*fs)'...
            ShortTimeEnergy(signals{n},winTime*fs,winTime*fs)'...
            loudness(signals{n},winTime*fs)'...
            SpectralFlux(signals{n},winTime*fs,winTime*fs)...
            SpectralEntropy(signals{n},winTime*fs,winTime*fs,1024,entropyBins)...
            SpectralRollOff(signals{n},winTime*fs,winTime*fs,RolOffThresh,fs)'...
            waveletFeatures(signals{n},winTime*fs)];
        
        A = autocorr(signals{n});
        longFs = Features{n}(:,numCeps+1:numCeps+6);
        
        LongFeatures = [mean(longFs,1) mean(A) median(A) std(A)];
        Features{n} = [Features{n} repmat(LongFeatures,size(Features{n},1),1)];
    end
    
    if ~isempty(ANNOTS) && ~isempty(TIMES)
        Labels = getEventLabels(TIMES,ANNOTS);
        LabelsExpanded = labelExpand(Labels,Features); %labelExpand requires Features to be a cell
    end
    
    if isempty(cindex)
        Features = cell2mat(Features);
    end
    
else
    FeatureLen = floor(length(signals)/(winTime*fs));
    
    Features = [...
    melfcc(signals,fs,'wintime',winTime,'hoptime',winTime,'numcep',numCeps)'...
    SpecCentroid(signals,winTime*fs,0,winTime*fs)'...
    ShortTimeEnergy(signals,winTime*fs,winTime*fs)'...
    loudness(signals,winTime*fs)'...
    SpectralFlux(signals,winTime*fs,winTime*fs)...
    SpectralEntropy(signals,winTime*fs,winTime*fs,1024,entropyBins)...
    SpectralRollOff(signals,winTime*fs,winTime*fs,RolOffThresh,fs)'...
    waveletFeatures(signals,winTime*fs)];

    A = autocorr(signals);
    longFs = Features(:,numCeps+1:numCeps+6);
    
    LongFeatures = [mean(longFs,1) mean(A) median(A) std(A)];
    Features = [Features repmat(LongFeatures,size(Features,1),1)];
end

end

