%Helper class to use JAVA http://code.j3d.org C3DParser to read a C3D file
%into matlab
%Written by Timo Rantalainen 2018 tjrantal at gmail dot com
%The C3D java classes need to be in java classpath for this function to
%work

function data = readC3D(c3dFile)
    function ret = handleStringArray(aIn)
        ret = {};
        for i = 1:aIn.length
           ret = [ret;  strtrim(aIn(i).toCharArray')];
        end
    end

	c3dParser = javaObject('org.j3d.loaders.c3d.C3DParser', ...
            javaObject('java.io.FileInputStream',c3dFile));
	c3dParser.parse(true);  %Parse the file
			
	header = c3dParser.getHeader(); %Get the C3D header information
    events = c3dParser.getEventParameter(); %Get the EVENT parameter group parameters
	analogData = c3dParser.getAnalogSamples();
	trajectories = c3dParser.getTrajectories();
    data = struct();
    
    %Get info from Header
    data.header.trajectorySampleRate = header.trajectorySampleRate;
    data.header.analogSampleRate = header.analogSampleRate;
    data.header.numAnalogSamplesPer3DFrame = header.numAnalogSamplesPer3DFrame;
    data.header.numTrajectories = header.numTrajectories;
    data.header.numTrajectorySamples = header.numTrajectorySamples;
    try
        data.header.start3DFrame = header.start3DFrame;
        data.header.end3DFrame = header.end3DFrame;
    catch
    end
    data.header.string = header.toString.toCharArray'; 
    
    %Get events
	try
		data.events = struct();
		data.events.labels = handleStringArray(events.labels); %Labels;
		data.events.descriptions= handleStringArray(events.descriptions); %Descriptions
		data.events.contexts = handleStringArray(events.contexts); %Event contexts (left/right)
		data.events.times = events.times;   %Event times
		data.events.frames = floor(events.times.*header.trajectorySampleRate)+1;   %Event frames
	catch
		%No event parameter
	end
    
    %Header events, not implemented
%     eventLabels = {};
%     for l = 1:length(data.header.events.eventTimes)
%        eventLabels = [eventLabels;   header.eventLabels(l).toCharArray'];
%     end
%     data.header.events.eventLabels = eventLabels;
    %Trajectories
    
    for m= 1:length(trajectories)
        tempName = trajectories(m).label.toCharArray';
        tempName = ['marker_' strtrim(regexprep(tempName,'\.|\:|\*','_'))];   %Hack to use the marker name as a field name
%         keyboard;
        try
%          tempData = typecast(swapbytes((trajectories(m).coordinates)),'single');
         tempData = trajectories(m).coordinates;
         data.trajectories.(tempName).xyz = reshape(tempData,[3,trajectories(m).numFrames]);
         data.trajectories.(tempName).numFrames = trajectories(m).numFrames;
%          figure
%          plot(data.trajectories.(tempName).xyz(:,2:end-1)')
%          title(tempName)
        catch
            disp(sprintf('Marker %s FAILED',tempName));
        end
    end
    
    %AnalogData

    for a= 1:length(analogData)
        tempName = analogData(a).label.toCharArray';
        tempName = strtrim(regexprep(tempName,'\.|\:|\*|\s','_'));   %Hack to use the marker name as a field name
%          tempData = typecast(swapbytes((trajectories(m).coordinates)),'single');
         tempData = analogData(a).analogSamples;
         
         cnt = 0;
         origTemp = tempName;
         tempName = sprintf('%s_%03d',origTemp,cnt);
         
         if isfield(data,'analog') & isfield(data.analog,tempName)
             while isfield(data,'analog') & isfield(data.analog,tempName)
                 cnt = cnt+1;
                 tempName = sprintf('%s_%03d',origTemp,cnt);
             end
         end
         
         
         
         data.analog.(tempName).data = analogData(a).analogSamples;
         data.analog.(tempName).numAnalogSamples = analogData(a).numAnalogSamples;
         data.analog.(tempName).numFrames = analogData(a).numFrames;
%          figure
%          plot(data.analog.(tempName).data)
%          title(tempName)
    end
end