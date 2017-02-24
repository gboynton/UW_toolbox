function showImage(varargin)
%showImage(img,[scaleFactor])
%
%shows an RGB (mxnx3) or grayscale (mxn) image in the current figure
%
%For grayscale double images, values are scaled to fit the range from black
%to white.
%
%For grayscale uint8 images, a colormap of size 256 is applied without
%scaling.
%
%Roll the mouse over the image to see pixel location and image value in the title.
%Left-click (alt-click) on image (left to right) to change the gamma of the color
%       table (gray-scale only)
%Double-click rescales image and graycale to default.
%
%scaleFactor: a 1x1 or 1x2 vector determining the image size.
%A scale factor of 3 sets image size to 3 screen pixels for each image pixel.
%Default is either 1, or the value make the maximum dimension 250 screen pixels.
%
%Example:
%[x,y] = meshgrid(linspace(-3,3,400));
%img = cos(pi*(x+y)).*exp(-x.^2-y.^2);
%showImage(img)

%Written by G.M. Boynton.  2/16/2008

if ~isa(varargin{1},'char') %Call from user

    img  = varargin{1};
    if ~isreal(img)
        img = [real(img),zeros(size(img,1),4),imag(img)];
    end
    set(gcf,'UserData',img);  %store image info in gcf 'UserData'
    minSize = 275;

    sz = [size(img,1),size(img,2)];
    if nargin>1
        scFac = varargin(2);
        if numel(size(scFac))==1
            scFac = [scFac,scFac];%single scale factor input (turn it into a 1x2)
        else
            scFac = [varargin{2},varargin{2}];%1x2 scale factor input for (x,y) dimensions
        end
    else %default scale factor
        if max(sz)<minSize %image too small for 'truesize'
            scFac = minSize/max(sz)*[1,1];
        else %image big enough for 'truesize' scaling
            scFac = [1,1];
        end
    end

    clf %use the current figure

    %set new position scaled to new size, keeping UL corner same.
    figPos = get(gcf,'Position');
    figPos(2) = figPos(2) + (figPos(4)-sz(1)*scFac(1));
    figPos(3) = sz(2)*scFac(2);
    figPos(4) = sz(1)*scFac(1);
    set(gcf,'Position',figPos);

    %set axis values to pixel locations
    xax = linspace(1,sz(2),sz(2)*scFac(1));
    yax = linspace(1,sz(1),sz(1)*scFac(2));

    %call MATLAB's 'image' command

    if ndims(img) == 3  %RGB image: no scaling
        if size(img,3) == 3
            himg = image(xax,yax,img);
            set(gcf,'Name',sprintf('%dx%d RGB',sz(1),sz(2)));
        end
    else %gray-scale image
        if isa(img,'uint8')
            himg = image(xax,yax,img);
            set(gcf,'Name',sprintf('%dx%d uint8',sz(1),sz(2)));
        elseif isa(img,'double') % scale to 0<=x<=256
            himg= image(xax,yax,256*(double(img)-min(img(:)))/(max(img(:)-min(img(:)))));
            set(gcf,'Name',sprintf('%dx%d min: %5.2f, max: %5.2f',sz(1),sz(2),min(img(:)),max(img(:))));
        end

        colormap(gray(256));

    end
    %Set axis and figure properties
    axis off
    set(gca,'Units','pixels');
    set(gca,'Position',[0,0,sz(2)*scFac(2),sz(1)*scFac(1)]); %rescale image to fit window
    set(gcf,'MenuBar','none');
    set(gcf,'NumberTitle','off');
    drawnow
    %Callbacks
    set(himg,'ButtonDownFcn','showImage(''butthit'')');  %mouse click
    set(gcf,'ResizeFcn','showImage(''resize'')');
    set(gcf,'WindowButtonMotionFcn','showImage(''mouseMove'')'); %mouse rollover

else  %Call of showImage through a Callback function
    img = get(gcf,'UserData');
    sz = [size(img,1),size(img,2)];
    switch(varargin{1}) %action string
        case 'butthit'  %mouse click
            butt = get(gcf,'selectiontype');
            switch butt
                case 'open'  %double-click: reset image size an cmap to default
                    showImage(img);
                case 'normal'  %right-click: change color table gamma
                    if ndims(img) == 2  %gray-scale image
                        %alter the color map
                        cp = get(gca,'CurrentPoint');
                        x = 2*(round(cp(1,1))/size(img,2)-.5); %-1<x<1
                        %y = round(cp(1,2))/size(img,1);
                        colormap(gray(256).^(2^(5*x)));
                    end
            end
        case 'resize'
            figPos = get(gcf,'Position');
            %calculate the new scale factors
            newScFac = figPos([4,3])./[size(img,1),size(img,2)];
            showImage(img,[newScFac(1),newScFac(2)]);
        case 'mouseMove' %mouse rollover
            cp = get(gca,'CurrentPoint');
            x = round(cp(1,1));
            y = round(cp(1,2));
            x = max(min(x,sz(2)),1);
            y = max(min(y,sz(1)),1);
            if ndims(img) == 3
                if size(img,3) == 3  %RGB image
                    if isa(img,'uint8');
                        set(gcf,'Name',(sprintf('[%d,%d] (%d,%d,%d)',y,x,img(y,x,1),img(y,x,2),img(y,x,3))));
                    elseif isa(img,'double')
                        set(gcf,'Name',(sprintf('[%d,%d] (%5.2f,%5.2f,%5.2f)',y,x,img(y,x,1),img(y,x,2),img(y,x,3))));
                    end
                end
            else  %gray-scale image
                if isa(img,'double')
                    if size(img,1)>=y & size(img,2)>=x
                        set(gcf,'Name',(sprintf('[%d,%d] %5.2f',y,x,img(y,x))));
                    end
                elseif isa(img,'uint8');
                    set(gcf,'Name',(sprintf('[%d,%d] %d',y,x,img(y,x))));
                end
            end
    end
end
return


%% Example images to show

[x,y] = meshgrid(linspace(-1,1,250));
img = cos(3*pi*(x+y)).*exp(-9*(x.^2+y.^2));  %Gabor
figure(1)
showImage(img)

img = uint8(12*mod(x,1)+12*mod(y,1)+123);  %contrast illusion
figure(2)
showImage(img)

img = x;
img(x>-.7 & x<-.3 & y<.2 & y>-.2) = 0;
img(x>.3 & x<.7 & y<.2 & y>-.2) = 0;
figure(3)
showImage(img); %simultaneous contrast illusion (play with gamma for best effect)



