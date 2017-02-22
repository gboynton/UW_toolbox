function plotPsycho(results, funName, params, logFlag)
% plotPsycho(funName, results, params, logFlag)
% 
% Plots the proportion correct of subject's response as given through
% 'results.response' where 1 is a correct response and 0 is an incorrect
% response per trial as a function of the stimuli intensity levels in
% 'results.intensity'.
% 
% Will also plot the psychometric function 'funName' if supplied the 
% parameters in the 'params' structure.
%
% Inputs:
%   results          A structure containing information stimuli intensity
%                    and subject responses for each trial:
%       intensity    Intensity values of stimuli shown for every trial
%       response     Binary response for each trial, where 1 is correct and
%                    0 is incorrect response, for each corresponding trial 
%                    from results.intensity
%
%   funName          Name of psychometric function to be graphed, string.
%                    Should be specified along 'params'.
%
%   params           A structure containing parameters for the 'funName'
%                    function to be fitted
%
%   logFlag          Flag to plot in log or in raw intensity values,
%                    logical (default: true)
%
% Note:
% - Dependencies: logx2raw.m

% Written by G.M. Boynton
% Edited by Kelly Chang - February 17, 2017

%% Input Control & Error Control

if ~exist('results', 'var')
    error('''results'' must be specified');
end

if ~all(ismember({'intensity', 'response'}, fieldnames(results)))
    errFlds = setdiff({'intensity', 'response'}, fieldnames(results));
    error('Missing field in ''results'': %s', strjoin(errFlds, ' & '));
end

if exist('funName', 'var') && ~exist('params', 'var') 
    error('%s function specified without ''params'' structure', funName);
end

if exist('params', 'var') && ~exist('funName', 'var')
    error('''params'' structure specified without ''funName''');
end

if ~exist('logFlag', 'var')
    logFlag = true;
end

%% Calculate Proportion Correct for Each Stimulus Intensity Level

intensity = unique(results.intensity);
id = arrayfun(@(x) results.intensity==x&~isnan(results.response), intensity, 'UniformOutput', false);
nTrials = cellfun(@sum, id);
nCorrect = cellfun(@(x) sum(results.response(x)), id);
pCorrect = nCorrect ./ nTrials;
sd = (pCorrect .* (1-pCorrect)) ./ sqrt(nTrials); % pq/sqrt(n)

%% Plot Psychometric Function

figure();
clf; hold on;
if exist('params', 'var') % plot the parametric psychometric function
    x = linspace(min(intensity), max(intensity), 101);
    plot((1-logFlag)*x + logFlag*log(x), feval(funName, params, x'), ...
        'r-', 'LineWidth', 2);
end
errorbar((1-logFlag)*intensity + logFlag*log(intensity), pCorrect, sd, ...
    'bo', 'MarkerFaceColor', 'b');
ylabel('Proportion Correct');
eval(repmat('logx2raw();', logFlag));