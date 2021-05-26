%Written by Timo Rantalainen 2021 tjrantal at gmail dot com. Released into
%the public domain apart from the java code, which is licensed under GPL

close all; %Close all open figures
fclose all; %Close all open files
clear all; %Clear the workspace
clc;    %Clear the terminal
addpath('functions');   %Add functions from this folder
addpath('functions/c3dreader'); %Add functions from this folder
javaclasspath({'.','source/j3d/build/libs/j3d-0.0.1.jar'}); %Add the java c3d reader. Uses http://code.j3d.org C3DParser 

toPlot = {'marker_RAnkleAngles','marker_RKneeAngles','marker_RHipAngles'};
datapath = 'data/'; %Look for any c3d files in this folder
fList = getFilesAndFolders([datapath '*.c3d']);
for f = fList'
    data = readC3D([datapath f.name]);  %Read the c3d file
    frameIndices = [data.header.start3DFrame:data.header.end3DFrame]+1;
    
    
%     keyboard;
    fh = figure('position',[0 50 1200 600]);
    for j = 1:length(toPlot)
        subplot(length(toPlot),1,j)
        
        angles = data.trajectories.(toPlot{j}).xyz';
        plot(frameIndices,angles);
        minMax = [min(angles(:)), max(angles(:))];
        hold on;
        for e = 1:length(data.events.frames)
           plot([1 1].*data.events.frames(e),minMax);
        end
        title(sprintf('%s %s',f.name,toPlot{1}));
    end
end

