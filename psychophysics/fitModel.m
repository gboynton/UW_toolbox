function [bestModel,initModel] = fitModel(funName,data,modelList,stimList);

%Get the free parameters

modelParams = fieldnames(modelList);

freeList = {};
for i=1:length(modelParams)
    evalStr = sprintf('isvect = ~isscalar(modelList.%s);',modelParams{i});
    eval(evalStr)
    if isvect
    freeList{end+1} = modelParams{i};
    end
end

[foo,bestModelId] = max(data.L);
initModel = [];
for i=1:length(modelParams)
    initModel = setfield(initModel,modelParams{i},getfield(data.model,modelParams{i},{bestModelId}));
end

bestModel = fit('errModel',initModel,freeList,funName,data);
    
errModel(initModel,funName,data);

