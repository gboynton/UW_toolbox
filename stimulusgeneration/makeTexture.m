function tex = makeTexture(display,img)

if isfield(display,'gamma')
    img =  display.gamma(ceil(img)+1);
end
tex=Screen('MakeTexture', display.windowPtr, img);


