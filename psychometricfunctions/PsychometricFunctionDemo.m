% PsychometricFunctionDemo.m

clear all; close all;

%%
% the visuals of the psychometric function are determined as follows
pS.MarkerFaceColor='b';
pS.MargerEdgeColor='g';
pS.ErrorBarColor= 'm';
pS.LineColor='r'; % curve fit color
pS.MarkerSize=4; % controls size
pS.MarkerScale=0; % whether the marker scales with the number of data points

logFlag=0;

funName = 'weibull'; % psychometric function name to be fitted, weibull or normcdf

% load example psychometric data
load resultsStaircase.mat % 'results' structure
% 'results' is a structure with two fields, intensity and response.
% 'results.intensity' is the stimuli intensity level for each trial
% 'results.response' is the observer response for each trial, where 1 is a
% correct response and 0 is an incorrect response.

% Let's take a look at the proportion correct of the subject as a function
% of the stimuli intensity level. We can do so by calling 'plotPsycho' on
% the 'results' structure.

h=plotPsycho(results, [], [], logFlag, pS);
xlabel('Stimuli Intensity Levels');
title('Results');

%%
% Let's try fitting a weibull function to the psychometric data and
% calculate the error with the maximum log likihood

% initial parameters for psychometric function
pInit.b = 1; % slope
pInit.t = 0.2; % stimuli intensity at threshold
%pInit.g = 0.5; % chance performance, only used for weibull function, defaults to 0.5 if unspecified
%pInit.e = (0.5)^(1/3); % the  performance level which you consider threshold ~80 for (0.5)^(1/3), only used for weibull

% calculate the maximum log-likelihood with the initial parameters
initErr = fitPsychometricFunction(pInit, results, funName);

% We can how well the initial parameters would fit by plotting the data
% and psychometric curve fit together
plotPsycho(results, funName, pInit, logFlag, pS);
xlabel('Stimuli Intensity Levels');
title(sprintf('Initial %s Fit\nb = %5.4f, t = %5.4f\nError = %5.4f', ...
    funName, pInit.b, pInit.t, initErr));

% You can play around with the parameters that initially go into the
% weibull fit to see if you can minimize the error manually

%%
% Alternatively, we can fit the weibull a nonlinear minization seach by
% calling fit.m. Usually when fitting the weibull, the slope (b) and stimuli
% intensity at threshold (t) are the parameters allowed to vary when
% fitting. We'll call fit with the initial parameters as seeds

freeList = {'b', 't'}; % free parameters, allowed to vary when fitting
[pFit,fitErr] = fit('fitPsychometricFunction', pInit, freeList, results, funName);

% We can see how well the fitted parameters look with our data
plotPsycho(results, funName, pFit, logFlag, pS);
xlabel('Stimuli Intensity Levels');
title(sprintf('Final %s Fit\nb = %5.4f, t = %5.4f\nError = %5.4f', ...
    funName, pFit.b, pFit.t, fitErr));