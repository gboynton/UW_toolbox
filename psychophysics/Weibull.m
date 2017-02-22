function [y] = Weibull(params, x)
% [y] = Weibull(params, x)
%
% The Weibull function based on this equation:
%
% k = (-log((1-e)/(1-g)))^(1/b)
% f(x) = 1 - ((1-g) * exp(-(k*x/t).^b))
%
% Where g is performance expected at chance, e is performance level that
% defines the threshold, b is the slope of the Weibull function, and t is
% the threshold
%
% Inputs:
%   params      A structure containing the parameters of the Weibull
%               function:
%       b       Slope
%       t       Stimulus intensity threshold as defined by 'params.e'.
%               When x = 'params.t', then y = 'params.e'
%       g       Performance expected at chance, proportion
%       e       Threshold performance, proportion
%
%   x           Intensity values of the stimuli
%
% Output:
%   y           Output of the Weibull function as a function of the
%               intensity values, x

% Written by G.M. Boynton - 11/13/2007
% Edited by Kelly Chang - February 13, 2017

%% Evaluate Weibull Function

k = (-log((1-params.e)/(1-params.g)))^(1/params.b);
y = 1 - ((1-params.g) * exp(-(k*x/params.t).^params.b));