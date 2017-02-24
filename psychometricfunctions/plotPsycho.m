function h=plotPsycho(results, funName, params, logFlag, plotStruct)
% plotPsycho(funName, results, params, [logFlag], [plotStruct])
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
%   plotStruct          Either a simple vector describing the color
%                       [0 0 0] or 'r'
%                        or you can use a structure
%                           pS.LineColor=[0 0 0]; describes the line
%                           pS.MarkerFaceColor=[0 0 0]
%                           pS.MarkerFaceColor=[0 0 0]
%                           pS.ErrorBarColor=[0 0 0]
%                           pS.MarkerSize=1; % controls size
%                           pS.MarkerScale= 0; does marker size scale with number of data points, default is no scaling
%
% Note:
% - Dependencies: logx2raw.m

% Written by G.M. Boynton
% Edited by Kelly Chang - February 17, 2017
% Edited by Ione Fine - February 22, 2017

%% Input Control & Error Control

if strcmp('normcdf', funName)
    funName='normcdfS2P'; % conversion function, changes input from structure to list of parameters
end

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

if exist('params', 'var') && ~isempty(params)
    if ~isfield(params, 't') error('slope parameter t is not defined');end
    if ~isfield(params, 'b') error('slope parameter b is not defined');end
    if ~isfield(params, 'g') params.g=0.5;end% chance performance, only used for Weibill function
    if ~isfield(params, 'e') params.e=(0.5)^(1/3);  end
end% the  performance level which you consider threshold ~80 for (0.5)^(1/3), only used for weibull

if exist('params', 'var') && ~exist('funName', 'var')
    error('''params'' structure specified without ''funName''');
end

if ~exist('logFlag', 'var') || isempty(logFlag)
    logFlag = true;
end

if ~exist('plotStruct', 'var')
    pS.LineColor=[0 0 0];
    pS.MarkerFaceColor=[0 0 0];
    pS.MarkerEdgeColor=[0 0 0];
    pS.ErrorBarColor=[0 0 0];
    pS.MarkerSize=6;
    pS.MarkerScale=0;
elseif ~isstruct(plotStruct)
    pS.LineColor=plotStruct;
    pS.MarkerFaceColor=plotStruct;
    pS.MarkerEdgeColor=plotStruct;
    pS.ErrorBarColor=plotStruct;
    pS.MarkerSize=6;
    pS.MarkerScale=0;
else
    pS=plotStruct;
    if ~isfield(plotStruct,'LineColor'); pS.LineColor=[0 0 0]; end
    if ~isfield(plotStruct,'MarkerFaceColor'); pS.MarkerFaceColor=[0 0 0]; end
    if ~isfield(plotStruct,'MarkerEdgeColor'); pS.MarkerEdgeColor=[0 0 0]; end
    if ~isfield(plotStruct,'ErrorBarColor'); pS.ErrorBarColor=[0 0 0]; end
    if ~isfield(plotStruct,'MarkerSize'); pS.MarkerSize=6; end
    if ~isfield(plotStruct,'MarkerScale'); pS.MarkerScale=0; end
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
if exist('params', 'var') && ~isempty(params) % plot the parametric psychometric function
    x = linspace(min(intensity), max(intensity), 101);
    plot((1-logFlag)*x + logFlag*log(x), feval(funName, params, x), ...
        'Color' ,pS.LineColor, 'LineWidth', 2);
end
if pS.MarkerScale==0 % no scaling by number of trials
    h=errorbar((1-logFlag)*intensity + logFlag*log(intensity), pCorrect, sd, ...
        'o', 'MarkerEdgeColor', pS.MarkerEdgeColor, 'Color', pS.ErrorBarColor, ...
        'MarkerSize', pS.MarkerSize);
else
    for i=1:length(nTrials)
        h(i)=errorbar((1-logFlag)*intensity(i) + logFlag*log(intensity(i)), pCorrect(i), sd(i), ...
            'o', 'MarkerEdgeColor', pS.MarkerEdgeColor, 'Color', pS.ErrorBarColor, ...
            'MarkerSize', sqrt(nTrials(i))*pS.MarkerSize);
        set(h(i), 'MarkerFaceColor', pS.MarkerFaceColor);

    end
end

set(gca, 'YLim', [0 1.05])
ylabel('Proportion Correct');
eval(repmat('logx2raw();', logFlag));