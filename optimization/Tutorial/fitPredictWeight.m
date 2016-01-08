function err = fitPredictWeight(p,w,data)

pEst = predictWeight(p,w);

err = sum((data(:)-pEst(:)).^2);
