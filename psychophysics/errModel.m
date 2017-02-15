function err = errModel(model,funName,data)

stimParams = fieldnames(data.stim);
p = zeros(size(data.response));
stim = [];
for j=1:length(stimParams)
    stim = setfield(stim,stimParams{j},getfield(data.stim,stimParams{j},{data.stimNum}));
end

p = feval(funName,model,stim);

err =  -sum(data.response.*log(p) + (1-data.response).*log(1-p));

