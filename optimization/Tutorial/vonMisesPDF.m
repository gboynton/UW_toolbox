function prob = VonMisesPDF(p,x)
% prob = VonMises(p,x)
%
% PDF of the VonMises function 
%
% Inputs:
%    model parameter structure p with fields
%      p.mu   mean
%      p.sig  standard deviation
%
%    x  values for sampling the Von Mises distribution
%
% Output:
%    prob  probability of obtaining sample x
%
% k= 1/(pi*p.sig/180)^2;
% prob = pi/90*exp(k*cos(2*pi*(x-p.mu)/180))/(2*pi*besseli(0,k));

if ~isfield(p,'xRange')
    p.xRange = [-180,180];
end


k= 1/(pi*p.sig/180)^2;

prob = 2*pi/diff(p.xRange)*exp(k*cos(2*pi*(x-p.mu)/diff(p.xRange)))/(2*pi*besseli(0,k));

