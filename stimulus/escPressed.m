function pressed = escPressed
%escPressed
%
%Returns 1 if escape key is pressed, 0 otherwise
%useful for stimulus termination by user

[ keyIsDown, timeSecs, keyCode ] = KbCheck;
if keyIsDown
    keyPressed= KbName(keyCode);
    pressed = strcmp(keyPressed,'esc');
else
    pressed = 0;
end