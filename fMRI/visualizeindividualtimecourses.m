function visualizeIndividualTimecourses(vtc,co,thr,artifacts, NORMALIZE,nplots,offset, sample, pred)
% function visualizeIndividualTimecourses(vtc,[co],[thr],[artifacts], [NORMALIZE],[nplots],[offset], [sample], [pred])

%
% visualizes individual voxel timecourses.
% useful for finding outlier timepts/voxels
%
% takes as input:
% vtc = nvox x ntpts vector
% co = the correlation value for each voxel, if not specified uses 0
% thr = a threshold cutoff, if not specified uses 0
% artifacts - a vector of timepoints with artifacts that should be excluded, default
% removes none
% NORMALIZE - use the vtc as given (NORMALIZE=0), or 0 mean, remove linear fit, and
% normalize by standard deviation. Default is not to normalize
% nplots is the number of individual timecourses to put on a 'page',
% default 10
% offset describes their vertical offsets, default is 3SD
% sample is to sample every Nth voxel, default is to create 5 pages
% pred is the time course prediction for each voxel. It will plot it on top
% of the time course and report both the original correlation value you gave the algorthm, 
% and the correlation with the tc once the artifacts have been removed and
% normalization has occured
if ~exist('co') || length(co)<1
    co=NaN;
end
if ~exist('thr') || isempty('thr')
    thr=0;
end
if ~exist('nplots') || isempty('nplots')
    nplots=10;
end
if ~exist('offset') || isempty('offset')
    offset=3;
end
if ~exist('NORMALIZE') || isempty('NORMALIZE')
    NORMALIZE=0;
end
if ~exist('sample')|| isempty('sample')
    sample=floor(size(vtc,1)./(nplots*10));
    disp(['Will sample every ', num2str(sample), 'th voxel']);
end

% pull out bad timepoints
if exist('artifacts')
    vtc(:,artifacts)=NaN;
    gvals=setdiff(1:size(vtc,2), artifacts);
else
    gvals=1:size(vtc,2);
end

if ~NORMALIZE
    offset=offset./median(std(vtc, [],2));
end
ct=0;
for vN=1:size(vtc,1)% means there is always nplot time series in a page
    % remove residual mean and slope and normalize by the standard
    % deviation
    if NORMALIZE
        vtc(vN,gvals)=vtc(vN,gvals)-mean(vtc(vN,gvals));
        plin=polyfit(linspace(0,1, length(gvals)), vtc(vN,gvals), 1);
        vtc(vN,gvals)=(vtc(vN,gvals)-plin(2))./plin(1);
        vtc(vN,gvals)=vtc(vN,gvals)./std(vtc(vN,gvals));
    end
    
    if  (double(mod(vN,sample)==0) && isnan(co)) || (double(mod(vN,sample)==0 && co(vN, 1)>thr))
        % plot the time course
        figure(100)
        plot(1:size(vtc,2), vtc(vN,:)+(ct*offset), '-', 'Color', [0 .1 .3]) ; hold on
        plot(artifacts, ones(length(artifacts),1)+(ct*offset), 'g.', 'MarkerSize', 10);
        if ~isnan(co)
        text(double(size(vtc,2)+5), double(ct*offset),num2str(round(co(vN), 2)));
        end
        if exist('pred')
            [pfit, jnk,jnk2]=polyfit(pred(vN,gvals), vtc(vN,gvals),1);
         
            %%!! BUG IN PFIT, HAVING THREE  OUTPUTS FUCKS IT UP!!!!
            predS(vN,gvals)=[pred(vN,gvals)-mean(pred(vN,gvals))]*pfit(1); % scale the prediction
              tmp=corrcoef(vtc(vN,gvals), predS(vN,gvals));newco(vN)=tmp(1,2);
              plot(1:size(vtc,2), predS(vN,:)+(ct*offset),'r-');
            text(double(size(vtc,2))+35, double(ct*offset),[num2str(round(newco(vN), 2))]); 
            newamp(vN)=pfit(1);
        end
        
        ct=ct+1;
        if ct>nplots;
            set(gca, 'YLim', [-offset (ct*offset)]),
            set(gca, 'XLim', [0 size(vtc,2)+70]);
            axis off
            drawnow; pause; figure(100); clf;
            ct=0;
        end
    end
end