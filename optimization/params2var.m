function [var] = params2var(params, freeList)
% [var] = params2var(params, freeList)
%
% Extracts 'freeList' fields from 'params' structure and outputs into a row
% vector 'var'. 'freeList' values in 'params' can only be length of 1. 
% Support function for 'fit.m'
% 
% Inputs:
%   params      A structure of parameter values with field names that
%               correspond with the parameter names in 'freeList'
% 
%   freeList    Cell array containing list of parameter names (strings)
%               that match the field names in 'params'
%
% Output:
%   var         Values extracted from the 'params' structure with field
%               names (in order) from 'freeList'

% Written by G.M Boynton, Summer of '00
% Edited by Kelly Chang, February 10, 2017

%% Input Control

if ischar(freeList)
    freeList = {freeList};
end

if ~all(ismember(freeList, fieldnames(freeList)))
    errFlds = setdiff(fieldnames(params), freeList);
    error('Unknown ''freeList'' parameters: %s', strjoin(errFlds, ', '));
end

if ~all(structfun(@length, rmfield(params,setdiff(fieldnames(params),freeList))) == 1)
    error('All params.(freeList) values must be a length of 1');
end

%% Extract 'freeList' Fields from 'params'

var = NaN(1, length(freeList));
for i = 1:length(freeList)
  var(i) = params.(freeList{i});
end