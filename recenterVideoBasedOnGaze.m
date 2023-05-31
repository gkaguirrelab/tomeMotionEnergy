clear all; clc
% Obtain the cleaned data

% Load the cleaned data
gazeDataSave = '/home/ozzy/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/pupilDataQAPlots_eyePose_MOVIE_July2020/gazeData_cleaned.mat';
load(gazeDataSave);

% These are the fields to process
fieldNames = {'tfMRI_MOVIE_AP_run01','tfMRI_MOVIE_AP_run02','tfMRI_MOVIE_PA_run03','tfMRI_MOVIE_PA_run04'};

% A suffix for the output avi
%fileSuffix = '_TOME_3017_model';
fileSuffix = '_allSubjects';

% The symbol to plot
plotSymbol = 'FilledCircle';

% Include eye

% The movie start times (in seconds) for each of the acquisitions
movieStartTimes = [1880, 2216, 892, 1228];

% Account for a quarter-second phase shift that appears to be present
% between the eye tracking and the movie
phaseCorrect = -0.25;

% How long a trail (in frames) do we leave behind each tracking circle?
nTrail = 0;

% Convert gaze coodinates and stop radius to screen coordinates
screenCoord = @(gazeCoord) (-gazeCoord).*(1080/20.8692) + [1920 1080]/2;
symbolRadius = @(relRad) (1+relRad) .* 25;

% Set up the video in
videoInFilePath = '/home/ozzy/Dropbox (Aguirre-Brainard Lab)/TOME_materials/StimulusFiles/PixarShorts.mov';
v = VideoReader(videoInFilePath);

% % Define the filename out stem
% dropboxBaseDir = getpref('movieGazeTOMEAnalysis','dropboxBaseDir');
% fileOutStem = fullfile(dropboxBaseDir,'TOME_analysis','movieGazeTrack');
fileOutStem = '/home/ozzy/Desktop/video';

% Subject number to process
theSub = 13;

% Loop over the fieldNames
for ff = 1:length(fieldNames)

    % Get this cleaned matrix and saveName
    vqCleaned = gazeData.(fieldNames{ff}).vqCleaned;
    saveID = gazeData.(fieldNames{ff}).nameTags{theSub};
        
    % Set up the timebase.
    timebaseSecs = (gazeData.timebase./1000) + movieStartTimes(ff) + phaseCorrect; 
    
    % Set up the video out
    fileNameOut = fullfile(fileOutStem,[fieldNames{ff} '_gazeTrack_' saveID '.avi']);
    vo = VideoWriter(fileNameOut);
    
    % Set the frame rate for the output
    vo.FrameRate = 1/(timebaseSecs(2)-timebaseSecs(1));
    
    % Open the video out object
    open(vo);
    
    % Loop through the frames
    hw = waitbar(0,'Running...');
    for tt = 1:length(timebaseSecs)
        v.CurrentTime=timebaseSecs(tt);
        f = readFrame(v);
        [imageHeight, imageWidth, ~] = size(f);
        center = [imageWidth/2 imageHeight/2];    
        thisCoord = screenCoord(squeeze(vqCleaned(theSub,1:2,tt)));
        if ~any(isnan(thisCoord))
            diff = center - thisCoord;
%             f = insertShape(f,plotSymbol,[thisCoord 10],'LineWidth',3);
            f = imtranslate(f, [diff(1), diff(2)]);
            waitbar(tt/length(timebaseSecs),hw);
%             imagesc(f)
        end
        writeVideo(vo,f)
    end
    
    % Close and clear the video objects
    close(vo);
    clear vo
    
end

clear v
