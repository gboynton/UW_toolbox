%% 'fit' and 'fitcon' tutorial
%
% Note: the optimization toolbox also has a function named 'fit', so beware
% of this potential conflict and place our 'fit' function higher in the
% path.
%
% 'fit.m' is a wrapper for Matlab's nonlinear optimization routine
% 'fminsearch'.  While fminsearch is a powerful routine, I find it a bit
% clunky to deal with so I wrote 'fit' to handle default settings and allow
% control over which parameters are allowed to be set free.
%
% Nonlinear optimization routines use iterative methods to find the minimum
% of mulivariate functions.  Basically, it takes a set of initial parameter
% values and a function name as an input and returns a new set of values
% for which the function will be minimized.  The routine is complicated,
% but fortunately it's all hidden so you don't need a degree in numerical
% analysis to use it.
%
% Nonlinear search algorithms are brute-force algorithms that find the
% minima of any strangely shaped function.  Because they are general, they
% can be slow and inefficient - especially for large numbers of parameters.
%
% The more you know about your function to be minimized, the more you can
% help the minimization process. For example, you can significantly speed
% things up if you can provide functions that are the partial derivitaves
% of your function for each variable.  (see fminsearch documentation for
% how to do this).
% 
% Certain functions cause trouble for numerical optimization routines.  The
% problem of local minima is discussed below.  Unsmooth (discontinuous
% first derivate) functions cause trouble too.  And anything stochastic
% really screws things up.
% 
% Regression analysis is another example of optimization, but since the
% math is relatively simple has been worked out, you should always use
% regression analysis software (e.g. matlab's 'regress') to fit a linear
% model to data instead of a general nonlinear optimization routine.
%
% Back to 'fit'.  The function is best explained with an example:
%
%% Example 1: 2 parameter function
%
% A classic 2-parameter function used to test nonlinear optimization
% routines is the 'Rosenbrock' function.  It has a shallow curved minimum
% that wreaks havoc on the simplest routines.  It has the form:
%
% f(x, y) = (a-x)^2 + b(y-x^2)^2
%
% Where a = 1 and b = 100 by default. 
% The minimum is zero at x = a, y = a^2 
%
% I've implemented the function so that the parameters x and y are fields
% of a single structure.  This is needed for the 'fit' function later.

p.x = -1;
p.y = 2;
f = rosenbrock(p);

disp(sprintf('f(%g,%g) = %g',p.x,p.y,f));

%%
% Try out some other values to see if you can find a lower value of f.
%
% Let's visualize the function as a surface in 2d

[x,y] = meshgrid(linspace(-1.5,2,201),linspace(-.5,3,201));
psurf.x = x;
psurf.y = y;
f = rosenbrock(psurf);

figure(1)
clf
hold on
surf(psurf.x(1,:),psurf.y(:,1),f);
shading interp
view(-40,20);

xlabel('x')
ylabel('y');

%%
% This builds a color map that roughly matches the image from the Wikipeida
% page:

tmp = hot(400);
cmap = flipud(tmp(1:256,:));
cmap(1,:) = [0,0,1];
colormap(cmap);

%%
% The color map has 256  values and ranges from yellow to red except for
% the lowest value which is set to blue.  You can see from the figure that
% although the color blue occupies the lowest 1/256 of the range, it covers
% the entire valley.  You can imagine walking around on the surface trying
% to find the minimum. It's easy to find the valley but hard to find the
% minimum of the valley.

%%
% Now we'll use 'fit' to find the minimum.  We'll use the initial values
% from before.  First we'll define the parameters 'x' and 'y' in the
% structure that we want to be allowed to vary.  These are listed in a cell
% array of strings:

freeParams = {'x','y'};

pBest = fit('rosenbrock',p,freeParams);
fBest = rosenbrock(pBest);

disp(sprintf('The minimum of the Rosenbrock is %g at (%g,%g)',fBest,pBest.x,pBest.y));

%%
% Within rounding error, the minimum should be zero at (1,1)

% Here's the location of the minimum on the plot of the surface:
plot3(pBest.x,pBest.y,fBest,'ko','MarkerFaceColor','g');

%%
% You could now try out some other initial values and see if you end up in the
% same place.  

%% Example 2, least-squares fit of a model to data
%
% The most common application of optimization in our field is fitting a
% parametric model to data.  Do do this we need a parametric model, some
% data, and a measure of the error between the model and the data. 
%
% For this example let's pretend we've run an experiment where subjects are
% estimating the weights of 10 objects.  Our objects have weights
% in pounds:

w = 1:10;

%%
% Our model is that subject's estimates are a power law of the actual
% weights:  y = aw^p.  As before, we'll define our parameters in a
% structure:
clear p
p.a = 1;
p.p = .5;

%%
% Our model prediction is implemented in the function 'predictWeight',
% which takes in the structure containing the parameters first, and then
% the weights.  

wEst = predictWeight(p,w);


%%
% We need some data.  We'll generate this by taking our model prediction
% and adding noise.  We'll set some seed values so we all get the same
% result:

randn('seed',pi);
rand('seed',pi);

data = wEst+randn(size(wEst));


%%
% Here's a plot of the original model and the data:

figure(2)
clf
hold on
plot(w,data,'ko','MarkerFaceColor','b');
plot(w,wEst,'k-');
xlabel('Weight (lbs)');
ylabel('Estimate (lbs)');
axis equal

%%
% To fit our model to the data we need a function that calculates the error
% between model predictions and the data.  We'll use a least-squared
% measure:

err = fitPredictWeight(p,w,data);

%%
% We're now set to find the parameters 'a' and 'p' that best predict our
% data.  We can start with the parameters that we used to generate our fake
% data.  
%
% First we'll set up our list of free parameters:

freeParams = {'a','p'};

%%
% And then we'll cal the 'fit' function.  The first three arguments in to
% 'fit' are like for the Rosenbrock function - (1) model name, (2) initial
% parameter structure, (3) list of free parameters.  
%
% But this time we'll send in the matrix 'data' as the fourth argument.
% 'fit' is set up so that any arguments sent in after the first three are
% passed in to the function to be optimized in order. The Rosenbrock
% function only took in one argument, but 'fitPredictWeight' takes in two
% additional arguments, 'w' and 'data'.  So these will be sent in to 'fit'
% as the fourth and fifth arguments.

pBest = fit('fitPredictWeight',p,freeParams,w, data);
disp(sprintf('Estimate of parameter ''a'': %g',pBest.a));
disp(sprintf('Estimate of parameter ''p'': %g',pBest.p));

%%
% We can plot the best-fitting curve by obtaining the model predictions
% with the new set of parameters:

wEstBest = predictWeight(pBest,w);
plot(w,wEstBest,'b-');
legend({'data','original model','best fitting model'},'Location','NorthWest');


%%
% You'll probably see that the recovered parameters aren't the same as the
% original parameters used to generate the data.  This is because the added
% noise changed the best fit.  

%% Keeping parameters fixed
%
% Sometimes it's useful to use constrained versions of models where certain
% parameters are held constant.  This is easily done with 'fit' by changing
% which parameters are set free.  Suppose that we want to keep the
% parameter 'p' in our weight estimation model held constant at 0.6, and we
% want to find the best value of 'a'.  All we do is set:

freeParams = {'a'};

p.p = 0.6;
pBest = fit('fitPredictWeight',p,freeParams,w, data);
disp(sprintf('Estimate of parameter ''a'': %g',pBest.a));
disp(sprintf('Estimate of parameter ''p'': %g',pBest.p));

%% Constrained optimization - fitcon
%
% There are times when you want to keep parameters within a certain range.
% If you have the optimization toolbox, Matlab has a function 'fmincon'
% that lets you do this.  I've written a wrapper 'fitcon' that makes it
% easier to use.  
%
% Suppose in our weight example we don't want the exponent to exceed 0.5.
% Note that this is different from fixing it at 0.5.
%
% 'fitcon' is called just like 'fit' except the cell array of free
% parameters can be expressions like:

freeParams = {'a','p<.5'};  

% This will let a be free, but fix p to be below 0.5.

pBest = fitcon('fitPredictWeight',p,freeParams,w, data);
disp(sprintf('Estimate of parameter ''a'': %g',pBest.a));
disp(sprintf('Estimate of parameter ''p'': %g',pBest.p));

%% Local minima
%
% A major issue with optimization is that it's hard to tell if you've found
% the actual minimum of a function or the bottom of a bowl that's not at
% the bottom - a 'local minimum'.  Typically, optimization routines will
% find the closest local minimum to your starting point.  To illustrate
% this, I've created a function 'lotsOminima' that's the sum of an
% egg-carton like surface and a quadratic.  Here's what it looks like with
% a contour plot underneath:

[x,y] = meshgrid(linspace(-1,1,101));

p.x= x;
p.y =y;
z = lots0minima(p);

figure(3)
clf
surf(x(1,:),y(:,1),z);
hold on
contour(x(1,:),y(:,1),z,20)
xlabel('x');
ylabel('y');

%%
% The global minimum is at (0,0).  If we start near there we'll end up in the
% right place:

p.x = 0.25;
p.y = 0.25;
freeParams = {'x','y'};
pBest = fit('lots0minima',p,freeParams);
zBest = lots0minima(pBest);
disp(sprintf('The minimum is %g at (%3.2f,%3.2f)',zBest,pBest.x,pBest.y));

hold on
plot3(pBest.x,pBest.y,zBest,'ko','MarkerFaceColor','g');
plot3(pBest.x,pBest.y,0,'ko','MarkerFaceColor','g');

%%
% But if we start near one of local minima:

p.x = 0.4;
p.y = 0.4;
pBest = fit('lots0minima',p,freeParams);
zBest = lots0minima(pBest);
disp(sprintf('The minimum is %g at (%3.2f,%3.2f)',zBest,pBest.x,pBest.y));

%% 
% We end up stuck in one of those little bowls.

plot3(pBest.x,pBest.y,zBest,'ko','MarkerFaceColor','g');
plot3(pBest.x,pBest.y,0,'ko','MarkerFaceColor','g');

%%
% Just for fun, let's start at a bunch of different initial positions and
% see where they end up:

[xInit,yInit] = meshgrid(linspace(-1,1,6));


figure(4)
clf
hold on
contour(x(1,:),y(:,1),z,100);
xlabel('x');
ylabel('y');
axis equal
axis tight
for i=1:length(xInit(:));
    p.x = xInit(i);
    p.y = yInit(i);
    p.shutup = 1;
    pBest = fit('lots0minima',p,freeParams);
    figure(4)
    plot([p.x,pBest.x],[p.y,pBest.y],'k-');
end

%% Maximizing likelihood fit to proportional data
%
% A least-squares error function is appropriate when you think that the
% variability of the data from the model is distributed normally with equal
% variance for all data points.  This assumption of homogeneity of variance
% is the backbone for regression analyses and for parametric statistical
% models such as t-test and F-tests.
%
% However, certain dependent variables, like proportion correct or
% probabilities, do not satisfy the property of homogeneity of variance.
% You can appreciate why when you consider that the error bars near 99%
% correct cannot possibly be as large as they are for around 50% correct,
% since the range is restricted.  
%
% More specifically, a draw of n trials from a binomial distribution with a
% probability of a 1 is P and a 0 is (1-P) will be distributed with a mean
% of P and standard deviation of sqrt(n*P*(1-P))).  That is, the standard
% deviation depends on P - an obvious violation of homogeneity of variance.
%
% So a least-squares error function is not appropriate for fitting models
% to percent correct data.  
%
% A good example of model fitting to proportional data is Zhang and Luck's
% 'slot' model of visual working memory (Zhang and Luck, Nature 2008).
% Their paper describes a paradigm in which subjects are asked to remember
% the colors of an array of colored squares.  The number of squares is the
% 'set size' which was either 3 or 6. After each array, subjects are
% probed to recall the color of one of the squares. The error between the
% true and recalled color serves as their dependent variable.
%
% Zhang and Luck predict their results with a model that assumes that
% subjects can maintain a small set of discrete, fixed resolution
% representations - or 'slots'. The 'mixture model' predicts that on a
% given trial, the probed stimulus will either be a member of a 'slot' and
% therefore remembered, or will not be remembered at all.  
%
% If the probed item happened to have been placed in a slot, then the
% response will be drawn from a circular Gaussian (called a 'Von
% Mises' distribution) centered at the true color with a standard deviation
% that's a parameter, 'sig'.  The error is presumably due to noise in the
% ability to memorize a color and to response error. The probability that a
% stimulus fell into a slot is the parameter, Pm.
%
% If the item was not remembered, then it the remembered color will be
% drawn from a uniform distribution across the range of colors. 
%
% To set up the model, we'll define the two parameters (sd and Pm) based on
% their experiment with a set size of 3.  
clear p
p.mu =0;
p.sig = 20;  % deg
p.Pm = .84;  

%%
% The following generates a set of fake data, which will be error values in
% the remembered color, centered at zero (and ranging from -180 to 180
% degrees in a circular color space)

nTrials = 100;
response = zeros(nTrials,1);
% determine which trials have probes that were remembered
inSlot = logical(floor(rand(nTrials,1)+p.Pm));

response(inSlot) = randVonMises(p,sum(inSlot));
response(~inSlot) = rand(sum(~inSlot),1)*360-180;

%%
% While responses are from a continuous scale, results are presented as
% proportions binned from -180 to 180 (they call their proportions
% 'frequency' for some reason). We can plot our fake data the same way:

xHist = linspace(-180,180,16);
xHist = xHist;


y = hist(response,xHist);

y = y/nTrials;
figure(5);
clf 
hold on
plot(xHist,y,'bo','MarkerFaceColor','k')
xlabel('Difference from original colour value');
ylabel('Proportion of trials');
set(gca,'XTick',xHist(1:2:end));

%%
% The model prediction on this graph is a weigthted average of a uniform
% distribution and VonMisees distribution, weighted by pM:

xHistSmooth = linspace(-180,180,101);

dxHistSmooth = xHistSmooth(2)-xHistSmooth(1);

dxHist = xHist(2)-xHist(1);


yPred = p.Pm*vonMisesPDF(p,xHistSmooth)*dxHist + (1-p.Pm)/length(xHist);
plot(xHistSmooth,yPred,'k-');

%% 
% You can play with the parameters to see how the results vary.  You'll see
% how the mixture model predicts that as pM ranges from zero to 1, the
% distribution ranges from uniform to a VonMises (Gaussian-like)
% distribution.
%
% Fitting the model to the data requires us to come up with an error
% function that reflects how close the data is to the model prediction.
% You'd think we'd try to fit the frequency data in our plotted figure to
% the model predictions.  But that can't be right because it would depend
% on the number of bins in hour histogram.  
%
% The correct way is to maximize the probability that our data was
% generated by the model for a given set of parameters. This is by treating
% each trial as an independent event and multiplying the probability of
% each event.  The probability of each event is simply:

pResponse = slotModelPDF(p,response);

%%
% Now multiplying all of these small numbers gives you a number very close
% to zero - and often zero as far as machine tolerance is concerned.  To
% remedy this, we take the log of product, which is the sum of the logs:

logProdpResponse = sum(log(pResponse));

%%
% This is a more reasonable (negative) number.  
%
% To fit the model, we need to find the values of sig and Pm that maximize
% the probability of our observed data - which is done by minimizing the
% negative of sum of the logs of the probabilities of each response.  I've
% written the two line function that calculates the number we calculated
% above:

err = fitSlotModel(p,response);

%%
% We're now ready to fit the model using fitcon.  Not how we'll use the
% constraints in 'freeParams' to keep the Pm between zero and 1 (since Pm
% is a probability) and sig>0 (since it's a standard deviataion):

freeParamsSlot = {'0<Pm<1','sig>0'};

pBestSlot = fitcon('fitSlotModel',p,freeParamsSlot,response);

%%
% Let's compare our best fitting parameters to the parameters we used to
% generate the data:

disp('           Original     Best-Fitting');
disp(sprintf('Pm:  %8g           %8g',p.Pm,pBestSlot.Pm));
disp(sprintf('sig: %8g          %8g',p.sig,pBestSlot.sig));

yPredBest = pBestSlot.Pm*vonMisesPDF(pBestSlot,xHistSmooth)*dxHist + (1-pBestSlot.Pm)/length(xHist);
hold on
plot(xHistSmooth,yPredBest,'b-');

legend({'data','original model','best-fitting model'});

%% Comparing model fits
%
% Fitting models to data has two main uses.  The first is to interpret
% something from the best-fitting parameter values, and the second is to
% rule out alternative hypotheses. In our example, if we are to believe the
% model (which we can since we used it to generate our data), we can
% conclude that remembered items are recalled with an error of plus or
% minus 20, and that for a set size of 3, there's an 84% chance that a
% given item will be remembered.  
%
% But more interesting for this example, is whether or not we can believe
% the slot model.  An alternative model is that all items are remembered
% equally well (or poorly).  This can be modeled with a restricted version
% of our slot model with Pm set to one (always remembered) and letting sig
% vary.

freeParamsRestricted = {'sig>0'};
p.Pm = 1;

pBestRestricted = fitcon('fitSlotModel',p,freeParamsRestricted,response);

yPredBestRestricted = pBestRestricted.Pm*vonMisesPDF(pBestRestricted,xHistSmooth)*dxHist + (1-pBestRestricted.Pm)/length(xHist);

% or, since p.Pm = 1:
yPredBestRestricted = vonMisesPDF(pBestRestricted,xHistSmooth)*dxHist;

plot(xHistSmooth,yPredBestRestricted,'r-');

legend({'data','original model','best-fitting slot model','best fitting restricted model'});
%%
% You can see by visual inspection that the slot model fits better.  But
% this is expected - the two models are called 'nested models' in which the
% slot model is a more general version of the restricted model.  Adding
% parameters will always improve the goodness of fit - it can't hurt, since
% you can always start with the restricted parameter values. The question
% is  - does the improvement in goodness of fit justify the use of the
% extra parameters?  
%
% There are a variety of statistical tests for this.  The most common one
% for a least-squares fit is a 'nested model F-test'.  Descriptions for
% this can be found all over the web. 
%
% For maximum likelihood, the most common test is the 'Likelihood Ratio
% Test'.  A good description can be found on Wikipedia:
%
% https://en.wikipedia.org/wiki/Likelihood-ratio_test
% 
% It's an easy test that depends on the difference in the log likelihood of
% the fit to two models.  For our example, the two log likelihoods are
% (note the negative sign, since we flipped the sign in the function to
% minimize instead of maximize):

logLslot = -fitSlotModel(pBestSlot,data);
logLrestricted = -fitSlotModel(pBestRestricted,data);

%%
% The null hypothesis is that the more general model is no better than the
% restricted model (after accounting for the increase in goodness of fit).
% 
% Under certain assumptions under the null hypothesis, two times the
% difference between these two values should be distributed as a
% chi-squared distribution with degrees of freedom equal to the difference
% in the number of parameters (in this case, 1)
%
% If you have the stats toolbox, you can perform the test:

D = 2*(logLslot - logLrestricted);
df = length(freeParamsSlot) - length(freeParamsRestricted);
pValue = 1-chi2cdf(D,df);
disp(sprintf('Chi^2(%d) = %5.2f, p = %5.4f',df,D,pValue));

%%
% In this example, we reject the null hypothesis and conclude that the slot
% model does fit the data better than the simpler model - a central
% conclusion of Zhang and Luck's paper.

%% Exercises
%
% 1) A simpler model for the weight estimation experiment is that perceived
% weight is proportional to the actual weight.  This can be modeled by
% restricting the exponent, p.p, to be 1.  Fit the more restricted model to
% the data and read the Wikipedia page to figure out how to run a nested
% model F-test.  With our fake data set, does allowing the exponent to vary
% significantly improve the fit?
%
% 2) Generate a fake data set for the restricted slot model by setting Pm
% =1.  See if you reject the likelihood-ratio hypothesis test. Run this
% simulation several times in a loop and see how often you reject it.
% Since the null hypothesis is actually true, you should reject it 5% of
% the time if alpha = .05.  
%
% 3) Do the same as #2 for the nested model F-test by generating data with
% p.p = 1.  See if you reject the null hypothesis alpha% of the time.
%
% 4) The power of a hypothesis test is the probability of correctly
% rejecting the null hypothesis.  Calculating the power in model fitting is
% very complicated analytically.  But you can easily calculate power with
% simulations.  For the slot model, re-run the hypothesis test we did by
% regenerating fake data with the parameters we used (pM = .84, sig =20).
% See how often you correctly reject the null hypothesis (choose your
% favorite value of alpha).  Try it again with a smaller number of trials
% to see how few trials you can get away with and still have a power of 0.8
% or more.  You should appreciate how this could be a useful exercise for
% determining how many trials you should run before you start an
% experiment.
%
% 5) A third parameter in the slot model is 'mu', the center of the
% distribution for remembered items.  We generated our data with p.mu = 0.
% Use this data to determine if letting p.mu vary significantly improves
% the fit.  (It shouldn't but it might by chance). 




    
    