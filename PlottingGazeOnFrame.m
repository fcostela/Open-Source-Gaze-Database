% Script to plot gazes (as white crosses) on top of the movie frame.
% It requires to have the eye data and the video clips located in specific
% folders (configured below)
% The number of clip to use (see excel file for
% correspondence of number indexes) can be specified in vidNum.
% Ouptut => It will create a video clip (default name is VideoWithGazes' + video
% number). Format is .avi by default but this can be changed

% Created by Francisco Costela 10-May-2017 

clear
% Video clip number we want to use - See correspondence in excel file 
vidNum=25;
addpath /Applications/Psychtoolbox/PsychRects
addpath /Applications/Psychtoolbox/PsychOneliners
% folder where the the eye data are located
etPath='/Users/FranciscoCostela/Desktop/magnification/Videoclipeyetrackingdata';
% folder where the video clips are located
movPath='/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming';

% Loading all info about viewers for each clip
load 'video number lookup.mat'

% get ET data for all subjects that viewed this clip
subs4Vid = find(videoNumbers == vidNum);
for i = 1:length(subs4Vid)
    load([etPath filesep eyetrackFiles{subs4Vid(i)}]);
    temp.x = eyetrackRecord.x;
    temp.y = eyetrackRecord.y;
    temp.t = eyetrackRecord.t;
    temp.missing = eyetrackRecord.missing;
    etData(i) = temp;
end

% get movie file name
[pathstr name ext] = fileparts(movieFileName);
name = strrep(name, '_c 2','');
name = strrep(name, '_c','');
movFile = fullfile([movPath filesep name ext]);


%% read each frame of clip to matrix
[movmat movobj]=doReadMovie(movFile);
save('moviesaved.mat', 'movmat', 'movobj', '-v7.3');
% If we already saved it previously, just load file
%load moviesaved

%% get all eye positions from all subjects for each frame
subind=[1:length(etData)];
frametime=1000*linspace(0,30,length(movmat));
etAll=cell(length(frametime)-1,1);
sdims=[2560 1440]; % hor x vert
for sub=1:length(etData) % each subject
    % sort coords and time data
    etxy=[etData(sub).x' etData(sub).y'];
    ettime=etData(sub).t';
    % trim coords that are outside of screen
    indx=etxy(:,1)>=0 & etxy(:,1)<=sdims(1);
    indy=etxy(:,2)>=0 & etxy(:,2)<=sdims(2);
    etxy=etxy((indx+indy)>=2,:);
    % trim time indices
    ettime=ettime((indx+indy)>=2,:);
    % get time elapsed since beginning of clip
    % for each recorded eye position
    eltime=ettime-ettime(1);
    eltime=eltime(1:end-1);
    % detect and replace saccades so we only plot fixation times
    [etxy_new sacind]=detectSaccades(etxy,eltime);
    for i=1:length(frametime)-1 % each frame
        etind=find(eltime>=frametime(i) & eltime<frametime(i+1));
        etAll{i}=vertcat(etAll{i},[etxy_new(etind,1) etxy_new(etind,2)]);
    end
end
 
destdims=[2560 1440];
% Create new video
newMovObj=VideoWriter(['VideowithGazes' num2str(vidNum)]);
open(newMovObj);

% Iterate through all the frames
for i=1:length(etAll)
    
    etdata=etAll{i};
    frame=movmat(i).cdata;
    framedims = [size(frame,2) size(frame,1)];
    % Plot gazes on top of frame
    kdeim=plotEP2Frame(etdata,frame(:,1:721,:),destdims);
    kdeim =imresize(kdeim,[framedims(2) framedims(1)]);
    frobj.cdata=uint8(round(kdeim));
    frobj.colormap=[];
    writeVideo(newMovObj,frobj);
end
close(newMovObj)
