function dumpc3dToTrc(c3dIn,exportFolder)
	temp = strsplit(c3dIn,'/');
	
	trcName = strrep(temp{end},'.c3d','.trc');
% 	disp(sprintf('Handling %s',c3dIn));
	if ~exist([exportFolder trcName],'file')
        try
            data = readC3D(c3dIn);


            %Write the data into a trc file. Note that VICON z is up -> reorganise the
            %coordinate axes into y,z,x, or x,z,-y

            trcHeader = {sprintf('PathFileType\t4\t(X/Y/Z)\t%s',trcName),
                        sprintf('DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames'),
                        sprintf('%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d', ...
                        data.header.trajectorySampleRate,data.header.trajectorySampleRate,data.header.numTrajectorySamples,data.header.numTrajectories,'mm',data.header.trajectorySampleRate,1,data.header.numTrajectorySamples)};

            markerNames = fieldnames(data.trajectories)';
            outputNames = cellfun(@(y) y{2},cellfun(@(x) strsplit(x,'er_'),markerNames,'uni',0),'uni',0);
            % keyboard;
            markerHeader = {'Frame#','Time',outputNames{1}};
            markerHeader = [markerHeader cellfun(@(x) sprintf('\t\t%s',x),outputNames(2:end),'uni',0)];
            xyzHeader = cellfun(@(x) sprintf('X%d\tY%d\tZ%d',x,x,x),num2cell(1:length(outputNames)),'uni',0);

            %Write trc header;
            if ~exist(exportFolder,'dir')
               mkdir( exportFolder);
            end

            fih = fopen([exportFolder trcName],'w');
            cellfun(@(x) fprintf(fih,'%s\n',x),trcHeader);
            cellfun(@(x) fprintf(fih,'%s\t',x),markerHeader(1:end-1));
            fprintf(fih,'%s\n',markerHeader{end});

            fprintf(fih,'\t\t');    %Write the empty columns for frame# and time
            cellfun(@(x) fprintf(fih,'%s\t',x),xyzHeader(1:end-1));
            fprintf(fih,'%s\n\n',xyzHeader{end});   %Write the extra empty here row as well

            %Print marker data
            markerData = [];
            for m = markerNames
                %markerName = markerMatch{find(cellfun(@(x) strcmp(x,m{1}),exportNames))}{1};
                xyz = data.trajectories.(m{1}).xyz';
                %reorganise the coordinate axes into y,z,x, or x,z,-y
                markerData = [markerData, xyz(:,2), xyz(:,3), xyz(:,1)];
            end

            %Replace 0 with missing
            markerData(markerData == 0) = nan;


            sampleIndices = [1:data.header.numTrajectorySamples]';
            sampleInstants = double([sampleIndices-1])./double(data.header.trajectorySampleRate);
            markerData = [sampleIndices,double(sampleInstants),markerData];

            %Remove data rows with no visible markers
            nanRows = find(all(isnan(markerData(:,3:end)),2));
            markerData(nanRows,:) = [];

            fFormat = '%d\t%f';
            for m = 1:length(markerNames)
                for d = 1:3
                    fFormat = [fFormat '\t%f'];
                end
            end
            fFormat =[fFormat '\n'];

            for s = 1:size(markerData,1)'
                fprintf(fih,fFormat,markerData(s,:));
            end

            fclose(fih);
            disp(sprintf('Did %s',c3dIn));
        catch
            disp(sprintf('ERROR %s',c3dIn));
        end
    else
        disp(sprintf('EXISTS %s',c3dIn));
	end
end