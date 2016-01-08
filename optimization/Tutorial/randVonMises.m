function x = randVonMises(p,nSamps)
% x = randVonMises(p,nSamps)
%
% Generates a random sample under the pdf of the Zhang and Luck slot model.
%
% Inputs:
%    model parameter structure p with fields
%      p.mu   mean for Von Mises function (degrees)
%      p.sig  standard deviation of Von Mises function 
%      p.Pm   probability of sampling from Von Mises (1-p.Pm is p(Guess)
%
%    nSamps:  number of random samples to generate
%
% Output:
%    x:  data set drawn from pdf of the Lot Model.

if ~isfield(p,'xRange')
    p.xRange = [-180,180];
end

xList = linspace(p.xRange(1),p.xRange(2),1001);
dx = xList(2)-xList(1);
prob = vonMisesPDF(p,xList);

Y = (cumsum(prob)-prob(1))*dx;

a = rand(1,nSamps);
x = interp1(Y,xList,a);

