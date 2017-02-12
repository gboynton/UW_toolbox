function timeLeftBar(rep,maxrep,message)
% TIMELEFTBAR Display time based wait bar
% timeLeftBar(rep,maxrep,message) creates and displays
% a variant of waitbar that is in real time
% rep should be the rep value in the loop
% maxrep should be the maximum value for the loop
%
%  Example: 
% maxreps=1000
% for i=1:maxreps
% === computation here === %
%   rand(2000);
%   timeLeftBar( i,maxreps,'message')
% end
%     
% written by Geoffrey M. Boynton. Edited Ione Fine

handle = findobj(allchild(0),'flat','Tag','TMWWaitbar');
if isempty(handle)
    handle=waitbar(1);
    tic
end

if rep>maxrep
    if rep==maxrep+1
        warndlg('timeLeftBar: rep number > maxrep number');
    end
    return
end
if ~exist('message','var')
    message = 'Time left:';
end

timeLeft = toc*(maxrep-rep)/rep;  % seconds

if timeLeft<60 %less than a minute
    timeLeftStr = sprintf('%d sec',floor(timeLeft));
elseif timeLeft <60*60  %between one minute and an hour
    timeLeftStr = sprintf('%d min %d sec',floor(timeLeft/60),floor(mod(timeLeft,60)));
else %more than an hour (show hours and minutes)
    timeLeftStr = sprintf('%d hr %d min',floor(timeLeft/3600),...
        floor(floor(mod(timeLeft,3600)/60)));
end

waitbar(rep/maxrep,handle,sprintf('%s %s',message,timeLeftStr));
if rep==maxrep
    delete(handle)
end
