function [keys,RT] = waitTill(waitTime,startTime)
%[keys,RT] = waitTill(waitTime,[startTime])
%
%Returns a vector of keys pressed and the timing of the presses during an
%interval of 'waitTime' seconds.  By default, the clock starts within the
%function, but if startTime is provided then the function will return
%waitTime seconds after startTime was defined with 'GetSecs'.  
%
%An empty variable is returned if no key was pressed during the interval.

%3/24/09 Written by G.M. Boynton at the University of Washington

%Initialize the output variables
keys = {};
RT = [];

%Read the clock if no clock time was provided
if ~exist('startTime','var')
    startTime = GetSecs;
end

%Give a warning if the waiting interval is zero or less
if GetSecs-startTime > waitTime
    disp('Warning! waitTill: waiting interval is less than zero')
end

%Turn off the output to the command window
ListenChar(2);

nKeys = 0;
%loop until waitTime seconds has passed since startTime was defined
while GetSecs-startTime < waitTime
    %see if a key is pressed
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    if keyIsDown %a key is down: record the key and time pressed
        nKeys = nKeys+1;
        RT(nKeys) = timeSecs-startTime;
        keys{nKeys} = KbName(keyCode);
        %clear the keyboard buffer 
        while KbCheck; end
    end
end
%Turn on the output to the command window
ListenChar(0);

%We're done now, so go home.

