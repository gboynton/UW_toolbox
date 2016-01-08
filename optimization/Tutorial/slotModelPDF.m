function prob = slotModelPDF(p,x)
% prob = slotModelPDF(p,x)
%
% PDF of the Zhang and Luck Slot Model 
%
% Inputs:
%    model parameter structure p with fields
%      p.mu   mean for Von Mises function (degrees)
%      p.sig  standard deviation of Von Mises function 
%      p.Pm   probability of sampling from Von Mises (1-p.Pm is p(Guess)
%
%    x  values for sampling the Von Mises distribution
%
% probVM = VonMisesPDF(p,x);
% prob = p.Pm*probVM + (1-p.Pm)/180; 

if ~isfield(p,'xRange')
    p.xRange = [-180,180];
end

probVM = vonMisesPDF(p,x);
prob = p.Pm*probVM + (1-p.Pm)/diff(p.xRange);