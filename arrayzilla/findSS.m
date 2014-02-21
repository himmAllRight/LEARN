function [ outputValues, chunkTimes ] = findSS( inputData, inputTime )
%findSS Name is out of date and will be changes eventually.

invalidManchesterCount = 0; % Keeps count of how many manchester counts are deemed invalid.

% Part 1: Creates Data Sets of Switch Bits
%-----------------------------------------
% Thresholds for for finding switches
upperThreshold = 1;
lowerThreshold = -1;

% Finds the diff of the data to find the binary transitions
diffData = diff(inputData);
time = inputTime(1:end-1);     %% Corresponding time has to be n-1 due to the diff function.

index1     = find(diffData > upperThreshold); % up-switches
index2     = find(diffData < lowerThreshold); % down-switches

index      = [];         % Index of switch locations

m = 1; % Index number for index1 values
n = 1; % Index number for index2 values

% This pieces the two lists together to regenerate an ordered list of all the switches.
for i = 1 : (length(index1) + length(index2))
    % If no more index1 values exist, add index2 value
    if m > length(index1)
        index(i) = index2(n);
        n = n + 1;
        % If no more index2 values exist, add index1 value
    elseif n > length(index2)
        index(i) = index1(m);
        m = m + 1;
        % If next value is from index1, add value
    elseif index1(m) <= index2(n);
        index(i) = index1(m);
        m = m + 1;
        % If next value is from index2, add value
    elseif index1(m) > index2(n)
        index(i) = index2(n);
        n = n + 1;
    else
        display('Error?')
    end
end

switchValues  = []; % The binary Values of the switches
switchTimes   = []; % The time value that each switch occurs at

% sets switchValues to 1 or 0 bit values.
for i = 1 : length(index)
    switchTimes(i) = time(index(i));
    if diffData(index(i)) >= 1
        switchValues(i) = 3;
    elseif diffData(index(i)) <= 1
        switchValues(i) = 0;
    end
end

% debugging
switchTimes;
switchValues;
switchYs = 1:length(switchTimes) ~= 0;




% Part 2: Uses data sets to find start/stop pairs
% ------------------------------------------------

% Alters the window width used for finding start/stop chunks of the invalid bits.
upperLimit = 100.00065; % Upper time limit for window to find start/stop.
lowerLimit = 0.00012; % Lower time limit for window to find start/stop. Default: .00012

% Sorts through time differences for potential start/stop points.
timeDiff = diff(switchTimes);

pairs = [];
pairIndex = 1;
for t = 1 : length(timeDiff)
    % If the difference between the switches is within the specified
    % window, it will be recorded as a pair.
    if (timeDiff(t) < upperLimit && timeDiff(t) > lowerLimit)
        
        % Used for plotting the pair locations
        pairPoints1(pairIndex) = switchTimes(t);   % First Value of Pair
        pairPoints2(pairIndex) = switchTimes(t+1); % Second Value of Pair
        pairPointsY1(pairIndex)= 1.55;              % Y value to plot point
        pairPointsY2(pairIndex)= 1.50;              % Y value to Plot point
        
        % Adds each switch pair to the pairs array
        pairs(pairIndex, 1) = switchTimes(t);      % First Value of Pair
        pairs(pairIndex, 2) = switchTimes(t+1);    % Second Value of Pair
        pairIndex = pairIndex + 1;
    end
end


% % Usefull plot for checking if the script found the code chunks correctly.Plots pair locations on origonal data plot.
% % Will plot the start of each chunk in green and the stop in red.
 plot(inputTime, inputData, 'b');        % Plots the input Data in background.
% plot(switchTimes, switchValues, 'b');
hold on;
scatter(pairPoints1,pairPointsY1, 'g')  % Marker for first value of each detection pair is in green.
hold on;
scatter(pairPoints2,pairPointsY2, 'r')  % Marker for second value of each detection pair is in red.
hold on;


% Part 3: Use pairs to get 64-bit Manchester chunks.
% -------------------------------------------------
% Defines window width for determining a 64-bit Manchester section.
dataWindowTop    = .0034;
dataWindowBottom = .0030;

dataChunks       = {};
chunkTimes      = [];
n                = 1;

% looks through pairs to see if time difference matches the time of the manchester signal.
for i=1 : (length(pairs) - 1)
    timeGap = pairs(i+1, 1) - pairs(i, 2); % Finds the time gap between the the end of one pair and the start of the next.
    
    % If the timegap falls within the specified window, it will be added as
    % a 'dataChunk' and saved.
    if timeGap < dataWindowTop && timeGap > dataWindowBottom
        chunkIndex = find(inputTime >= pairs(i,2) & inputTime <= pairs(i+1,1));
        dataChunks{n} = inputData(chunkIndex(1):chunkIndex(length(chunkIndex))); % Extracts chunk from origonal data.
        chunkTimes(n,1) = inputTime(chunkIndex(1)); % Saves the start time of each chunk for output.
        chunkTimes(n,2) = inputTime(chunkIndex(length(chunkIndex)));
        
        n = n +1;
    end
    
end




% Part 4 v.3: New method to divide the chunks into 64 pieces and calculate
% 1 or 0 for each based on the already established switchValues and
% switchTimes established in Part 1.

manchesterBits = {};
chunkBits = [];
testingVal = 8;

for i = 1: length(dataChunks)
    chunkSwitchInd  = find(switchTimes >= chunkTimes(i,1) & switchTimes < chunkTimes(i,2));      % Index values of chunk
    chunkSwitchTime = switchTimes((chunkSwitchInd(1)):(chunkSwitchInd(length(chunkSwitchInd)))); % Time values of chunk
    chunkSwitchVals = switchValues(chunkSwitchInd(1):chunkSwitchInd(length(chunkSwitchInd)));    % Values of chunk
    
    switchDiff = diff(chunkSwitchTime);  % Difference of switch times
    m = 1;                               % Index for chunkBits
    
    for j = 1: length(switchDiff)
        % If normal bit, add bit value to array.
        if( switchDiff(j) > 0.000035 & switchDiff(j) < 0.000065)
            chunkBits(m) = chunkSwitchVals(j);
            m = m + 1;           
        end

        % If double length bit, add two bit values to array.
        if( switchDiff(j) > 0.000085 & switchDiff(j) < 0.00012)
            for z = 1: 2
		chunkBits(m) = chunkSwitchVals(j);
            	m = m + 1;
        end

        % If diff is really small, it is a double data point. don't record
        % it.
        if( switchDiff(j) < 0.00002)
            % Do nothing? 
        end
    end

    manchesterBits{i} = chunkBits;

%     % Plotting for debugging 
      if( i == testingVal)
          scatter(chunkSwitchTime, chunkSwitchVals, 'm')
          hold on;
%          switchDiff
%          switchMarker = chunkSwitchTime;
%          switchDiff =diff(switchMarker);
%          chunkSwitchVals;
%          switchMarkerY  = (1:length(switchMarker)) ~= 0;
%         
      end
end



% The older/more complicated/ not as elequent method. I left it incase it helps in any way.

% % Part 4 v.2 : Divide chunks into 64 pieces and calculate 1 or 0 for each
% % segment to get the 64-bit Manchester sequence.
% % ------------------------------------------------------------------
% 
% 
% manchesterBits = {};
% 
% edgeChunks = {};
% 
% for i = 1 : length(dataChunks)
%     chunkLength         = length(dataChunks{i}); % Finds the length of chunk.
%     unitLength          = chunkLength / 64; % Divides the length into 64 pieces.
%     unitHalf            = unitLength/2;
%     remainders          = mod(chunkLength,64); % Remainder needed to add to basex64 to get chunklength
%     remainFirstHalf     = ceil(remainders);
%     remainSecondHalf    = floor(remainders);
%     remainderCount      = 1;
%     
%     start               = 1;
%     midValue            = 1.5;  % THIS needs to change.
%     midValueLow         = midValue - 1;
%     midValueHigh        = midValue + 1;
%     bitString = [];
%     
%     tags = [start];
%     remainders;
%     for m = 1 : 64
%         remainderCount;
%         if ( m < 33)
%             if(m < 17)
%                 if( remainderCount <= (ceil(ceil(remainders/2)/2)))
%                     ending = ceil(start + unitLength);
%                     remainderCount = remainderCount + 1;
%                 else % Floor
%                     ending = floor(start + unitLength);
%                 end
%             else
%                 if(remainderCount <= ceil(remainders/2))
%                     ending = ceil(start + unitLength);
%                     remainderCount = remainderCount + 1;
%                 else % Floor
%                     ending = floor(start + unitLength);
%                 end
%             end
%         else
%             if( m < 49)
%                 if(remainderCount <= (ceil(remainders/2) + (ceil(floor(remainders/2)/2))))
%                     ending = ceil(start + unitLength);
%                     remainderCount = remainderCount + 1;
%                 else % Floor
%                     ending = floor(start + unitLength);
%                 end
%             else
%                 if(remainderCount < remainders)
%                     ending = ceil(start + unitLength);
%                     remainderCount = remainderCount + 1;                    
%                 else % Floor
%                     ending = floor(start + unitLength);
%                 end
%             end
%             
%         end
%         
% %         % Put larger needed chunks at begininng and end
% %         if(m < (ceil(remainders/2)) || m > (64 - (floor(remainders/2))))
% %             ending = ceil(start + unitLength);
% %         else
% %             ending = floor(start + unitLength);
% %         end
%         
%         
%         %         if( mod(m,2) == 0 )
%         %             ending = floor(start + unitLength);
%         %         else
%         %             ending = ceil(start + unitLength);
%         %        end
%         tags(m+1)=ending;
%         
%         set = dataChunks{i}(start:ending);
%         for n = 1 : length(set)
%             % If the value is above the mid, set to 1
%             if set(n) > midValueHigh
%                 set(n) = 1;
%                 % If it is below, set to 0
%             elseif set(n) < midValueLow
%                 set(n) = 0;
%             end
%         end
%         bitString(m) = mode(set); % Set the bit value of the set to the mode of its values.
%         start = ending; % Shift the new start to the current end.
%     end
%     manchesterBits{i} = bitString; % Add each bit string to the manchesterBits.
%     
% end
% 
% % Shows how the chunks are divided up into 64s
% tagsT = (1:length(tags)) ~= 0;
% tagsT = tagsT *2;
% 
% dataChunksT = 1:length(dataChunks{i});
% manchesterBits{i}
% 
% scatter(dataChunksT,dataChunks{i})
% hold on
% scatter(tags, tagsT, 'g')
% hold on
% 
% 
% 
% % % Used for debugging
% %for i = 1 : length(manchesterBits)
% %     display(i)
% %     display(manchesterBits{i})
% % end



% The manchester decoder. This takes a 64-bit manchester code, converts it into a 32-bit binary code,
% and then converts that into a decimal value. I have tested this secion with self-generated
% 64-bit manchester examples, but part 4 has to be fixed before it can be fully utilized with real
% data. Part four keeps generating some manchester chunks that are deemed 'Invalid manchester code'.
% Once part 4 is fixed, this section 'SHOULD' work.

% Part 5: Decode Manchester codes
% -------------------------------

manchesterBits = manchesterBits(16:length(manchesterBits));

 binaryBits = {}; % Cell array of all the sequences in binary form.
% Go through all the manchest chunks.
 for x = 1 : length(manchesterBits)
     manchesterNum = manchesterBits{x}; % manChesterNum is each 64 bit sequence
     
     if mod(length(manchesterNum),2)~= 0 % Makes sure manchester sequence is even.
         length(manchesterNum)
         error('Length of array must be even')
     end
     
     binNum = []; % 32-bit binary number.
     n = 1;
     for i = 1: 2 :length(manchesterNum) % loops by 2
         % If the first value is different than second, it sets the binNum
         % value to the first one. ( Based on the convention).
         if manchesterNum(i) ~= manchesterNum(i+1)
             binNum(n) = manchesterNum(i);
             n = n + 1;
         else % If the two values are the same, it is not valid Manchester Code.
             display(x)
             display(manchesterNum)
             %error('invalid manchester code')
             display('invalid manchester code')i
	     
	     % Counts the number of invalid codes generated for debugging
             invalidManchesterCount = invalidManchesterCount + 1;
             
         end
     end
     binaryBits{x} = binNum; % adds number
 end
 
 % Convert Binary to decimal.
% *This section can probably be made much simplier. I feel I wrote something that is 
% much more complicated than it needs to be due to my ignorance of matlab data structures.
 decVal = []; % Decimal Values
 
 for i =1 : length(binaryBits)
     X = binaryBits{i};
     X = mat2str(X); % Converts Matrix to string
     binStr    = ''; % Empty string that will be filled and converted.
     binStrInd = 1;
     for n = 1 : length(X)
         % Makes a string only containing 1s and 0s from X to be converted.
	 % *gets rid of spaces and other useless characters.
         if X(n) == '1'
             binStr = strcat(binStr,'1');
             binStrInd = binStrInd + 1;
         elseif X(n) == '0'
             binStr = strcat(binStr,'0');
             binStrInd = binStrInd + 1;
         end
     end
     decVal(i) = bin2dec(binStr); % Converts the binary numbers to decimal
 end
 
 %outputValues = decVal; % changes name
 
% invalidManchesterCount
 
 end
outputValues, outputTimes;
