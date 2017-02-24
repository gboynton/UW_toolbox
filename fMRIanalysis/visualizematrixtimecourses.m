
function visualizeTimecourses(vtc, co, thr)
%function [M]=visualizeTimecourses(vtc, [co], [thr])
%
% visualizes the matrix of voxel x time. 
% useful for finding outlier timepts/voxels
% if co and thr are included the image includes a side matrix that describes
% for each voxel whther or not it passed a particular threshold
% 
% takes as input:
% vtc = nvox x ntpts vector
% co = the correlation value for each voxel
% thr = a threshold cutoff

    %% image the full time/series voxel matrix to look for buggers
    ct=1;
    for vN=1:size(vtc, 1)
          Mvtc(ct,:)=vtc(vN, :);
        if exist('co') && co(vN)>=thr
            Mco(ct)=1;
        else
            Mco(ct)=0;
        end
        ct=ct+1;
    end
    
    subplot('Position', [.1 .1 .8 .88]) %left, bottom, width,height
    imagesc(Mvtc);
    subplot('Position', [.92 .1 .05 .88])
    imagesc(Mco');axis off
    colormap(gray(255));
    xlabel('TRs')
    ylabel('voxels')
end
