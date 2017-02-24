%DemoCollated

clear all
close all
clear mex
cd('C:\Users\Ione Fine\Desktop\MM_adapt')
addpath(genpath('C:\Program Files\MATLAB\R2015b\toolbox\BVQXtools_v08d'));
addpath(genpath('C:\Users\Ione Fine\Documents\Work\Science\Programming Utilities\Fine Utilities\DataUtilities'));
vtcfilelist(1,:)={'R1_Nov12_AudVis1_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov12_AudVis2_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov13_AudVis1_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov13_AudVis2_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov13_AudVis3_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'};

vtcfilelist(2,:)={'R1_Nov12_VisAud1_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov12_VisAud2_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov12_VisAud3_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov13_VisAud1_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'
    'R1_Nov13_VisAud2_SCCA_3DMCTS_THPGLMF2c_TAL.vtc'};

prtfilelist(1,:)={'fMRI_AudVis1_Nov12.prt'
    'fMRI_AudVis2_Nov12.prt'
    'fMRI_AudVis1_Nov13.prt'
    'fMRI_AudVis2_Nov13.prt'
    'fMRI_AudVis3_Nov13.prt'};

prtfilelist(2,:)={'fMRI_VisAud1_Nov12.prt'
    'fMRI_VisAud2_Nov12.prt'
    'fMRI_VisAud3_Nov12.prt'
    'fMRI_VisAud1_Nov13.prt'
    'fMRI_VisAud2_Nov13.prt'};

roifilelist={'R1_MTL_Vis_qfdr05_TAL_BIG.msk'
    'R1_MTR_Vis_qfdr05_TAL_BIG.msk'};
symList=['s', 'o'];
titlestr={'Aud Adapt', 'Vis Adapt'}'
OUTLIERFLAG=1; % remove outliers

NORMALIZE=1;
cd('vtc')
for av=1:2
    for rr=1:2
        roi=BVQXfile(roifilelist{rr});
        ctSame=1;ctDiff=1;       
        for f=1:size(vtcfilelist, 2)
            clear vtcM;
            vtc = BVQXfile(vtcfilelist{av, f}, '*.vtc');
            prt = BVQXfile(prtfilelist{av,f}, '*.prt');
            cond=prt.Cond;
            maskVec = find(roi.Mask);
            maskVec=maskVec(1:100);
            
            for tpt=1:size(vtc.VTCData,1)
                tmp=vtc.VTCData(tpt, :, :, :);
                vtcM(:,tpt) = tmp(maskVec);
            end
            if NORMALIZE
                for vN=1:size(vtcM, 1)
                    vtcM(vN,:)=vtcM(vN,:)-mean(vtcM(vN,:));
                    plin=polyfit(linspace(0,1, size(vtcM,2)), vtcM(vN,:), 1);
                    vtcM(vN,:)=(vtcM(vN,:)-plin(2))./plin(1);
                    %                     vtcM(vN,:)=vtcM(vN,:)./std(vtcM(vN,:));
                end
            end
            [y, out]=hampel(std(vtcM, [], 2),12,3);
            %             figure(f); clf
            %             subplot(1,2 ,1)
            %             visualizeTimecourses(vtcM, abs(1-out), .5);
            
            %      figure(f+1); clf
            vtcM(find(out),:)=NaN;
            for vN=1:size(vtcM, 1)
                vtcM(vN,:)=vtcM(vN,:)./std(vtcM(vN,:));
            end
            
            %  visualizeTimecourses(vtcM); pause
            
            %% collate the sames
            for ss=1:size(cond(1).OnOffsets, 1)
                if cond(1).OnOffsets(ss,1)<189 % take the mean over voxels
                    sameVTC(ctSame,:)=squeeze(nanmedian(vtcM(:, cond(1).OnOffsets(ss,1)-4:cond(1).OnOffsets(ss,2)+4), 1));
                    ctSame=ctSame+1;
                end
            end
            for ss=1:size(cond(2).OnOffsets, 1)
                if cond(2).OnOffsets(ss,1)<189 % take the mean over voxels
                    diffVTC(ctDiff,:)=squeeze(nanmedian(vtcM(:, cond(2).OnOffsets(ss,1)-4:cond(2).OnOffsets(ss,2)+4), 1));
                    ctDiff=ctDiff+1;
                end
            end
            %
            %
            
        end % each file
        mnRespSame(rr,av,:)= squeeze(mean(sameVTC,1));
        mnRespDiff(rr,av,:)= squeeze(mean(diffVTC,1));
        stdRespSame(rr,av,:)= squeeze(std(sameVTC,[],1)./sqrt(size(sameVTC,1)));
        stdRespDiff(rr,av,:)= squeeze(std(diffVTC,[],1)./sqrt(size(sameVTC,1)));
        figure(100)
        subplot(2, 1,av)
        errorbar(1:12, squeeze(mnRespSame(rr,av,:)),  squeeze(stdRespSame(rr,av,:))*7/10, ['-k',symList(rr)], 'MarkerFaceColor', 'k'); hold on
        errorbar(1:12, squeeze(mnRespDiff(rr,av,:)) ,  squeeze(stdRespDiff(rr,av,:))*7/10, ['-r',symList(rr)], 'MarkerFaceColor', 'r'); hold on
        set(gca, 'XLim', [ 0 13])
        title(titlestr{av})
        pause
    end  % each roi
    
end


%, collated.pRFs,OUTLIERFLAG)
