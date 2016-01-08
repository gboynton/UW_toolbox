function err = fitSlotModel(p,x)
% err = fitSlotModel(p,x)
%
% -Log likelihood of obtaining x under the Zhang and Luck Slot Model 
%
% Inputs:
%    model parameter structure p with fields
%      p.mu   mean for Von Mises function (degrees)
%      p.sig  standard deviation of Von Mises function 
%      p.Pm   probability of sampling from Von Mises (1-p.Pm is p(Guess)
%
%    x:  observed values from an experiment
%
% Output:
%    -log likelihood of obtaining samples x given parameters p


prob = slotModelPDF(p,x);
err = -sum(log(prob));
