function tile(m,n,monitor)
% tile([m],[n],[monitor])
%
% Tiles matlab figures in the monitor in rows starting at the top-left.
%
% Inputs:
%   m  #of rows of figures 
%   n  #of columns (defaults set to match aspect ratio of monitor)
%   monitor monitor number (1 is desktop, 2+ is extended, default is
%       highest available)
%
% Example:
%
% close all
% for i=1:12
%    figure(i)
%    set(gcf,'MenuBar','none','Color','k');
%    text(0,0,num2str(i),'FontSize',64,'HorizontalAlignment','Center','Color','g');
%    xlim([-1,1]);ylim([-1,1]);axis off
%  end
%  tile(3,4)
 
 
% Written 3/30/12 gmb (after getting frustrated by Matlab's positioning of
% figures outside the monitor by default)

monitorPos = get(0,'MonitorPositions');
figs = sort(get(0,'Children'))';

for i=1:length(figs)
    figNum(i) = get(figs(i),'Number');
end

[foo,id] = sort(figNum);

%monitorPos(2,:) = monitorPos(1,:)+[0,monitorPos(1,4),0,0];
nMonitors = size(monitorPos,1);

if ~exist('monitor','var')
    monitor= nMonitors;
end

if monitor>nMonitors
    error(sprintf('No monitor #%d available',monitor));
end

sz = monitorPos(monitor,[3,4]); %(x,y)






x0 = monitorPos(monitor,1);
y0 = monitorPos(monitor,2)+sz(2);


x =x0;
y =y0;

% Monitor 1 is assumed to have Windows menu on the bottom
if monitor==1
    sz(2) = sz(2)-50;
end
if ~exist('m','var')
    m = [];
end
if ~exist('n','var')
    n = [];
end
if isempty(m)
    m = ceil(sqrt(length(figs)*sz(2)/sz(1)));
end

if isempty(n)
    n = ceil(length(figs)/m);
end

dx = round((sz(1))/n);
dy = round((sz(2))/m);

set(0,'Units','pixels');



for i=figs(id)
    set(i,'units','pixels');
    set(i,'OuterPosition',[x,y-dy,dx,dy]);
   % set(i,'MenuBar','none');
    x = x+dx;
    if x>=x0+sz(1)-5
        x = x0;
        y = y-dy;
    end
end

