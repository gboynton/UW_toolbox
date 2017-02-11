function [err] = fitFunction(var, funName, params, freeList, origVarargin)
% [err] = fitFunction(var, funName, params, freeList, origVarargin)
%
% Evaluates the error value at minimum for the given 'funName' with 
% 'params' parameters. Support function for 'fit.m' & 'fitcon.m'
%
% Inputs:
%   var               Values used to calculate the error value, stored into
%                     'params' structure under field names (in order) from
%                     'freeList'
% 
%   funName           Name of function to be optimized, string
% 
%   params            Structure of parameter values for 'funName'
% 
%   freeList          Cell array containing list of parameter names,
%                     (strings)
% 
%   origVarargin      Extra variables to be sent into 'funName' after 
%                     'params'
%
% Output:
%   err               Error value at minimum, numeric

% Written by G.M Boynton, Summer of '00
% Edited by Kelly Chang, February 10, 2017

%% Calling Specified Function to be Fitted

% stick values of var into params
params = var2params(var, params, freeList);

% organize evaluation string for origVarargin 
tmp = arrayfun(@(x) sprintf('origVarargin{%d}',x), 1:length(origVarargin), ...
    'UniformOutput', false);

% evaluate the function
err = eval(sprintf('%s(params,%s);', funName, strjoin(tmp, ',')));