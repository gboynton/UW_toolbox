function GrabData

figure(1)
clf


%xLow and xHigh

uicontrol('Style','pushbutton','Position',[20,200,60,40],'String','Load Image',...
    'CallBack',{@load_image_callback});

uicontrol('Style','pushbutton','Position',[20,150,60,40],'String','Save Data',...
    'CallBack',{@save_data_callback});

uicontrol('Style','togglebutton','Tag','xLowPix',...
    'Position',[20,20,60,20],'String','X Low','CallBack',{@axis_pix_callback});

uicontrol('Style','edit','Tag','xLowVal','Position',[80,20,60,20],'String','0',...
    'CallBack',{@plot_callback});

uicontrol('Style','togglebutton','Tag','xHighPix',...
    'Position',[20,50,60,20],'String','X High','CallBack',{@axis_pix_callback});

uicontrol('Style','edit','Tag','xHighVal','Position',[80,50,60,20],'String','1',...
    'CallBack',{@plot_callback});


%yLow and yHigh

uicontrol('Style','togglebutton','Tag','yLowPix',...
    'Position',[160,20,60,20],'String','Y Low','CallBack',{@axis_pix_callback});

uicontrol('Style','edit','Tag','yLowVal','Position',[220,20,60,20],'String','0',...
    'CallBack',{@plot_callback});

uicontrol('Style','togglebutton','Tag','yHighPix',...
    'Position',[160,50,60,20],'String','Y High','CallBack',{@axis_pix_callback});

uicontrol('Style','edit','Tag','yHighVal','Position',[220,50,60,20],'String','1',...
    'CallBack',{@plot_callback});





uicontrol('Style','togglebutton','Tag','undo',...
    'Position',[20,100,60,40],'String','Undo Last','CallBack',{@undo_callback});


% uicontrol('Style','togglebutton','Tag','undo',...
%     'Position',[330,20,60,50],'String','Plot','CallBack',{@plot_callback});


uicontrol('Style','popupmenu','Tag','PlotType',...
    'Position',[400,50,60,20],'String',{'bar','plot'},'CallBack',{@plot_callback});

uicontrol('Style','togglebutton','Tag','ErrorBars',...
    'Position',[460,50,60,20],'String',{'Error bars'},'CallBack',{@plot_callback});

uicontrol('Style','text','Position',[400,20,60,20],'String','n rows','CallBack',{@plot_callback});

uicontrol('Style','edit','Tag','nRows',...
    'Position',[460,20,60,20],'String','1','CallBack',{@plot_callback});


uicontrol('Style','togglebutton','Tag','xLog','Position',[300,20,60,20],'String','log(x)',...
    'CallBack',{@plot_callback},'Value',0);

uicontrol('Style','togglebutton','Tag','yLog','Position',[300,50,60,20],'String','log(y)',...
    'CallBack',{@plot_callback},'Value',0);

set(1,'WindowButtonDownFcn',@mouse_click_callback)


p = [];
p.xPix = [];
p.yPix = [];

set(1,'UserData',p);

%%
function axis_pix_callback(src,ev)
p = get(1,'UserData');
fieldName = get(src,'Tag');
[x,y] = ginput(1);
tmp = get(1,'Position');
sz = tmp([3,4]);
switch(fieldName(1))
    case 'x'
        p = setfield(p,fieldName,x);
    case 'y'
        p = setfield(p,fieldName,y);
end
if isfield(p,'boxHandle')
    if ishandle(p.boxHandle)
        delete(p.boxHandle);
    end
end

p.boxHandle = plot([p.xLowPix,p.xHighPix,p.xHighPix,p.xLowPix,p.xLowPix],...
    [p.yLowPix,p.yLowPix,p.yHighPix,p.yHighPix,p.yLowPix],'r-');

set(1,'UserData',p);
set(src,'Value',1);
plot_callback;

function mouse_click_callback(hObject,~)

p = get(1,'UserData');

if ~isfield(p,'xPix')
    p.xPix = [];
    p.yPix = [];
end

n = length(p.xPix)+1;

pos=get(gca,'CurrentPoint');
pos = pos(1,[1,2]);
p.hData(n) = plot(pos(1),pos(2),'k+','MarkerSize',15);
p.hText(n) = text(pos(1),pos(2),num2str(n),'HorizontalAlignment','right','VerticalAlignment','bottom');

p.xPix(n) = pos(1);
p.yPix(n) = pos(2);

set(1,'UserData',p);
plot_callback;
figure(1);

%%
function undo_callback(src,ev)
p=get(1,'UserData');

if isfield(p,'xPix')
    n = length(p.xPix);
    if n>0
        if ishandle(p.hData(n))
            delete(p.hData(n));
        end
        if ishandle(p.hText(n))
            delete(p.hText(n));
        end
        p.hData = p.hData(1:end-1);
        p.hTest = p.hText(1:end-1);
        p.xPix = p.xPix(1:end-1);
        p.yPix = p.yPix(1:end-1);
        set(1,'UserData',p);
    end
    plot_callback;
end
%%
function plot_callback(src,ev)
p=get(1,'UserData');

[x,y,s] = getData(p);

errorBars=get(findobj('Tag','ErrorBars'),'Value');
figure(2)
clf

if length(x)
    
    
    h = findobj('Tag','PlotType');
    plotTypes = get(h,'String');
    plotType = plotTypes{get(h,'Value')};
    
    xLog = get(findobj('Tag','xLog'),'Value');
    yLog = get(findobj('Tag','yLog'),'Value');
    
    
    switch plotType
        case 'plot'
            if xLog
                xx = log(x);
            else
                xx=  x;
            end
            if yLog
                yy = log(y);
            else
                yy = y;
            end
            
            if errorBars
                errorbar(xx,yy,s,'o-','MarkerFaceColor','w')
                if xLog
                    logx2raw;
                end
            else
                plot(xx,yy,'o-','MarkerFaceColor','w')
                if xLog
                    logx2raw;
                end
            end
        case 'bar'
            bar(y,'BarWidth',1);
            numbars = size(y,2);
            numgroups = size(y,1);
            if errorBars
                hold on
                errorbar(x, y, s, 'k', 'linestyle', 'none');
            end
    end
end


%%
function [x,y,s] =getData(p)

n = length(p.xPix);

if n
    h = findobj('Tag','PlotType');
    
    plotTypes = get(h,'String');
    plotType = plotTypes{get(h,'Value')};
    errorBars=get(findobj('Tag','ErrorBars'),'Value');
    
    
    xLog = get(findobj('Tag','xLog'),'Value');
    yLog = get(findobj('Tag','yLog'),'Value');
    
    if errorBars
        n = ceil(n/2);
    end
    
    xLowVal = str2double(get( findobj('Tag','xLowVal'),'String'));
    xHighVal = str2double(get( findobj('Tag','xHighVal'),'String'));
    yLowVal = str2double(get( findobj('Tag','yLowVal'),'String'));
    yHighVal = str2double(get( findobj('Tag','yHighVal'),'String'));
    h = findobj('Tag','nRows');
    nRows = str2num(get(h,'String'));
    
    nCols  = ceil(n/nRows);
    
    
    x = NaN*ones(nRows,nCols);
    y = NaN*ones(nRows,nCols);
    s = NaN*ones(nRows,nCols);
    
    xx =   (p.xPix-p.xLowPix)*(xHighVal-xLowVal)/(p.xHighPix-p.xLowPix)+xLowVal;
    yy =   (p.yPix-p.yLowPix)*(yHighVal-yLowVal)/(p.yHighPix-p.yLowPix)+yLowVal;
    
    if xLog
        k = (log(xHighVal)-log(xLowVal))/(xHighVal-xLowVal);
        a = xLowVal*exp(-k*xLowVal);
        xx = a*exp(k*xx);
    end
    
    if errorBars
        
        nBars = floor(length(yy)/2);
        x(1:n) = xx(1:2:n*2-1);
        s(1:nBars) = abs(yy(2:2:nBars*2)-yy(1:2:nBars*2-1));
        y(1:n) = yy(1:2:n*2-1);
    else
        x(1:n) = xx;
        y(1:n) = yy;
        s = [];
    end
    switch plotType
        case 'bar'
            numbars = size(y,2);
            numgroups = size(y,1);
            hold on
            groupwidth = min(0.8, numbars/(numbars+1.5));
            
            for i=1:size(y,2)
                
                x(:,i) = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars); % Aligning error bar with individual bar
            end
    end
    
    
else
    x = [];
    y = [];
    s = [];
end

%%
function load_image_callback(src,ev)

fileName = uigetfile({'*.tif;*.tiff;*.jpeg'});

if fileName
    [img,map] = imread(fileName);
    
    figure(1)
    if ndims(double(img))<3
        img(:, :, 2)=img(:, :, 1);
         img(:, :, 3)=img(:, :, 1);
    end
        
    image(img(:,:,1:3))
    colormap(map);
    axis equal
    axis off
    hold on
    p = get(1,'UserData');
    p.xLowPix = 2;
    p.yLowPix = size(img,1)-1;
    p.xHighPix = size(img,2)-1;
    p.yHighPix = 2;
    
    p.boxHandle = plot([p.xLowPix,p.xHighPix,p.xHighPix,p.xLowPix,p.xLowPix],...
        [p.yLowPix,p.yLowPix,p.yHighPix,p.yHighPix,p.yLowPix],'r-');
    
    p.xPix = [];
    p.yPix = [];
    
    set(1,'UserData',p);
    title(fileName);
    
end

function save_data_callback(src,ev)
p = get(1,'UserData');

[x,y,s] = getData(p);

fileName = uiputfile;

errorBars=get(findobj('Tag','ErrorBars'),'Value');
if errorBars
    save(fileName,'x','y','s');
else
    save(fileName,'x','y');
end



