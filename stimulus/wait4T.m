function wait4T

ch = '';
while ~strcmp(ch,'t');
    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
    keyPressed= KbName(keyCode);
    if ~isempty(keyPressed)
        ch = keyPressed(end);
    end
end

