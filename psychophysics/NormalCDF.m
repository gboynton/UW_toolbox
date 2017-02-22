function [y] = NormalCDF(params, x)
% [y] = NormalCDF(params, x)
%
% The Normal Cumulative Function (cdf) based on MATLAB's normcdf.m
% (see NORMCDF.m)
%
% Inputs:
%   params      A structure contain the parameters of the normal cdf:
%       u       Mean
%       s       Standard deviation
%
%   x           Intensity values of the stimuli the Normal CDF is a
%               function of
%
% Output:
%   y           Output of the Normal Cumulative Distribution as a function
%               of x

% Written by G.M. Boynton - 11/13/2007
% Edited by Kelly Chang - February 13, 2017

%% Evaluate Normal Cumulative Distribution

y = normcdf(x, params.u, params.s);