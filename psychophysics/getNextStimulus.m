function data = getNextStimulusDebug(funName,data,modelList,stimList)

% data = getNextStimulus(funName,data,modelList,stimList)
%
% Applies the 'quick' Bayesian and information theory method to select the
% next stimulus in a forced-choiced trial that will maximize the amount of
% information associated with distinguishing possible models.
%
% The function requires you to write a function that is the model of
% subject's performance for a set of model paramers and a set of stimuli.
%
% Here's an example function:
%
% prob = pcWeibull(model,stim)
%
% 'model' is a structure with fields that determine the model paramters.
% For this example, a set of model parameters might be:
% model =
%
%     b: 1.8105  (slope)
%     t: 0.0661  (threshold)
%
% 'stim' is a structure containing stimulus parameters as fields.  Your
% function must be able to take in vectors for each field and it must
% return 'prob' as a vector of the same size as the fields of 'stim'.
%
% Once this function is written, you then choose the parameter space of
% model parameters and stimulus parameters in 'modelList' and 'stimList'.
%
%



% Initialize 'data' structure if needed
if ~exist('data','var')
    data = [];
end
if isempty(data)
    data.stimNum = [];
    data.response = [];
end

% Initialize 'pCorrect' structure if needed.  This is usualy done just
% once, the first time this function is called.
if ~isfield(data,'pCorrect')
    data.pCorrect = [];
end

if isempty(data.pCorrect)
    % Make the table of predicted percent correct for all stimuli and
    % possible model parameters.
    
    % Get the names of the model parameters
    modelParams = fieldnames(modelList);
    
    % Ugly code for making a complete list of models.  This goes in
    % 'data.model'
    str = '[';
    for i=1:length(modelParams)
        str = [str,modelParams{i}];
        if i<length(modelParams)
            str = [str,','];
        else
            str = [str,'] = ndgrid('];
        end
    end
    for i=1:length(modelParams)
        str = [str,'modelList.',modelParams{i}];
        if i<length(modelParams)
            str = [str,','];
        else
            str = [str,');'];
        end
    end
    eval(str)
    
    str = ['nModels = length(',modelParams{1},'(:));'];
    eval(str);
    
    data.model = [];
    for i=1:length(modelParams)
        str = ['data.model.',modelParams{i},' = ',modelParams{i},'(:)'';'];
        eval(str);
    end
    
    % Ugly code to get a complete list of possible stimuli.  This goes in
    % 'data.stim'
    stimParams = fieldnames(stimList);
    str = '[';
    for i=1:length(stimParams)
        str = [str,stimParams{i}];
        if i<length(stimParams)
            str = [str,','];
        else
            str = [str,'] = ndgrid('];
        end
    end
    for i=1:length(stimParams)
        str = [str,'stimList.',stimParams{i}];
        if i<length(stimParams)
            str = [str,','];
        else
            str = [str,');'];
        end
    end
    eval(str)
    
    data.stim = [];
    for i=1:length(stimParams)
        str = ['data.stim.',stimParams{i},' = ',stimParams{i},'(:)'';'];
        eval(str);
    end
    
    % Loop through all of the models and get the probability correct for
    % each possible stimulus.  This requires a call to your model function
    % 'funName' for each set of model parameters.  It is assumed that your
    % model function will return a vector of values associated with the
    % stimulus parameters.
    
    for i=1:nModels
        for j=1:length(modelParams)
            str = ['model.',modelParams{j},' = ',modelParams{j},'(i);'];
            eval(str);
        end
        str = ['data.pCorrect{i} = ',funName,'(model,data.stim);'];
        eval(str);
        data.pCorrect{i} = max(min(data.pCorrect{i},.99),.01);
        
        % Initialize priors, data.L
        
        data.L = ones(1,nModels)/nModels;  % flat prior
    end
else
    nModels = length(data.pCorrect);
end

% Step 0: Calculate the (log) likelihood for each set of model parameters for the
% current data (data.stimNum and data.response)
% data.logL = [];
% for i=1:nModels
%     pi = data.pCorrect{i}(data.stimNum);
%
% %    pi = max(min(pi,.999),.001);  %avoid 0's and 1's
%     data.logL(i) = sum(data.response.*log(pi))+sum((1-data.response).*log(1-pi));
% end



% Step 1: Calculate p(r|x) the probability of getting a correct or incorrect
% response for each possible stimulus on the next trial. This requires
% summing up across models the product of the probability of a correct (or
% incorrect) response and the probability of that model being correct (from
% Step 0)

ptrx1 = zeros(size(data.pCorrect{1}));
ptrx0 = zeros(size(data.pCorrect{1}));

for i=1:nModels
    ptrx1 = ptrx1 + data.L(i)*data.pCorrect{i};
    ptrx0 = ptrx0 + data.L(i)*(1-data.pCorrect{i});
end

% Step 2: Calculate p(model|x,r), Use Bayes rule to calculate, for each model, the
% posterior probabability of each psychometric function.  This is, for each
% model, the likelihood of the model based on the data times the likelihood
% of a correct response for each stimulus for that model divided by the
% overall probability of getting a correct (or incorrect) response for that
% stimulus (from step 1)

for i=1:nModels
    ptlxr1{i} = data.L(i)*data.pCorrect{i}./ptrx1;
    ptlxr0{i} = data.L(i)*(1-data.pCorrect{i})./ptrx0;
end

%%
% update data.L

if ~isempty(data.response)
    for i=1:nModels
        if data.response(end) == 1            
            data.L(i) = ptlxr1{i}(data.stimNum(end));
        else
            data.L(i) = ptlxr0{i}(data.stimNum(end));
        end
    end
end

% Step 3: Calculate the entropy [-p*log(p)], for each stimulus, of the
% distribution of posterior probabilities (from Step 2) across models for
% both correct and incorrect responses.

Ht1 = zeros(size(ptlxr1{1}));
Ht0 = zeros(size(ptlxr0{1}));
tol = 1e-5;
for i=1:nModels
    if sum(ptlxr1{i})>tol        
        Ht1 =Ht1-ptlxr1{i}.*log(ptlxr1{i});
    end
    if sum(ptlxr0{i})>tol
        Ht0 =Ht0-ptlxr0{i}.*log(ptlxr0{i});
    end
end

% Step 4: Calculate the expected entropy for each stimulus.  This is the
% sum of the entropy for a correct response and incorrect response (from
% Step 3), each multlied by the overall probability of a correct or
% incorrect response (from Step 1).

E = Ht1.*ptrx1   + Ht0.*ptrx0;

% Find the index for the next stimulus to be shown. This is the stimulus
% with the most expected entropy.  The response to this stimulus will
% maximize the spread of the distribution of posterior probabilities across
% models. That is, it'll distinguish the likelihood of each model being
% true from eachother as much as possible.

[foo,data.stimNum(end+1)] = min(E(:));
