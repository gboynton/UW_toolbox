function  p = normcdfS2P(params, x)
% p = normcdfS2P(params, x)
%
% a function that takes a structure as input then calls normcdf.
% returns the cdf of the normal distribution with
% mean MU and standard deviation SIGMA, evaluated at the values in X.
% The size of P is the common size of X, MU and SIGMA.  A scalar input
% functions as a constant matrix of the same size as the other inputs.
%
% Default values for MU and SIGMA are 0 and 1, respectively.
%
% Inputs:
%   params      A structure containing the parameters of the Weibull
%               function:
%       b       Slope
%       t       Stimulus intensity threshold as defined by 'params.e'.
%               When x = 'params.t', then y = 'params.e'
%
%       x           Intensity values of the stimuli
%
% written Ione Fine 2/24/2017


    p=normcdf(x, params.t, params.b);
end