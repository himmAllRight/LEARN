function [ strobes ] = getStrobes( inputData, sampleRate )
% Will search through input data and find the strobes of audio data. It
% will then extract them and add them to a structure.

sampleRate
% Parameters
% ----------------------
diff_data       = diff(inputData); % Differences of each data point from the input data
diff_dataT      = 1:(length(diff_data)); % Equivalent index scale of diff_data
noiseTop        = .005; % Top diff threshold used to differentiate noise from strobes
noiseBottom     = -.005;% Bottom diff threshold used to differentitate noise from strobes.

findStrobes     = []; % Values from inputData of found strobes from searching diff values.
findStrobesT    = []; % Indicies of corresponding data points.
dataIndex       = 1;  % Index of previous two variables.


% Will search through the diff_data
for i = 1: length(diff_data)
    % If the diff value is greater than the thresholds, it will add the
    % point and index to the findStrobes arrays.
   if diff_data(i) > noiseTop || diff_data(i) < noiseBottom
      findStrobes(dataIndex) = inputData(i); % Add data to findStrobes
      findStrobesT(dataIndex) = i; % Add index of corresponding data point.
      dataIndex = dataIndex + 1; % Increment dataIndex for next value.
   end
end

% NOTE: The previous part finds the strobes using the diff data. However, because
% it only finds points above the diff thresholds, the start/stops of each
% pulse have to be found so that they can be used to get the full range of origonal data
% That is what the next section is for.

% Find time pairs for start/stop of each pulse.
diff_findStrobesT = diff(findStrobesT); % Difference between times (start/stops between strobes will show up as large values.
cutLocs = [findStrobesT(1)]; % indicies of strobes. The first value is always the first value of findStrobesT.
cutInd  = 2; % Start index at 2. (1 is already accounted for)

% Loop through diff_find strobes to look for start/stops.
for i = 1: length(diff_findStrobesT)
    % If the difference between points is over a certain value, it is the
    % transition between data of different strobes.
   if(diff_findStrobesT(i) > 2000) % The 2000 can be changed if need be.
       cutLocs(cutInd) = findStrobesT(i); % adds the stop index of prev signal at current switch
       cutInd = cutInd+1; % Increment index for next value.
       cutLocs(cutInd) = findStrobesT(i+1); % adds the start index of the next signal at switch.
       cutInd = cutInd+1; % increment index again.
   end
end
cutLocs(cutInd) = findStrobesT(length(findStrobesT)); % The last data value is the last stop, so it is added at the end.
length(cutLocs) % Prints out how many start/stop points it found for testing.

% Lastly: Use each start/stop to cut out the data/time chunks from the origonal
% data into a struct.
 
strobes = struct('data','time'); % Creates the struct
strobesIndex = 1; % Struct index

% For the length of the start/stops, use them to cut out the origonal data
% and add it to the struct.
for i = 1 : 2 : length(cutLocs)
    strobes(strobesIndex).data      = inputData(cutLocs(i):(cutLocs(i+1))); % cut and add data
    %strobes(strobesIndex).time      = (cutLocs(i):cutLocs(i+1)); % cut and add corresponding time values for data. (In int values)
    strobes(strobesIndex).time      = ((cutLocs(i):cutLocs(i+1))/sampleRate); % cut and add corresponding time values for data. (In seconds)
    strobes(strobesIndex).startTime = strobes(strobesIndex).time(1); % Add the start time of the pulse.
    strobes(strobesIndex).startData = strobes(strobesIndex).data(1); % Add the starting data point of the strobe.
    strobes(strobesIndex).endTime   = strobes(strobesIndex).time(length(strobes(strobesIndex).time)) % Add ending time
    strobes(strobesIndex).endData   = strobes(strobesIndex).data(length(strobes(strobesIndex).data)) % Add ending data point
    
    max = 0; % set max var to 0 to find amplitude max for this strobe
    maxLoc = 0; % max index
    % search all the data points of a strobe for the max.
    for j=1:length(strobes(strobesIndex).data)
        % if a data point is greater than a max, add it as a new max.
        if strobes(strobesIndex).data(j) > max
           max = strobes(strobesIndex).data(j); % set new max
           maxLoc = strobes(strobesIndex).time(j); % set new max location
        end
    end
    strobes(strobesIndex).max = max;       % Add max to strobe data
    strobes(strobesIndex).maxLoc = maxLoc; % Add max location to strobe data
    strobesIndex = strobesIndex+1;         % Increase strobes index.
end
strobes % Print out strobes struct for checking/testing (can be commented out)
strobes(1) % Print out first strobe as an example for testing ( can be commented out)


% Visualization

inputDataTime = 1:length(inputData); % Creates incremental time for plotting inputData
cutLocsY = 1:length(cutLocs) == 0; % Y values of 0 of each point, for plotting

% These plots can be used to visualize what the function is doing.
% Uncomment different plots and the following 'hold on' as desired
%to see what is be extracted and where.
% ----------------------------------------------------------------
plot(inputDataTime,inputData, 'b') % Plots the inputData in blue
hold on
scatter(findStrobesT,findStrobes,'g') % Plots range of what it has found to be a strobe in green
hold on
%scatter(strobes(6).time,strobes(6).data,'g') % Plots full data of an example extracted strobe in green
%hold on
scatter(cutLocs,cutLocsY,'r') % Plots the start and stop points for each strobe it found in red.
hold on

strobes

