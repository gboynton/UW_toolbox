function out = xls2struct(filename)
[a,b,c] = xlsread(filename);

headers = rmSpaces(b(1,:));
c = c(1:size(b,1),:);
out = [];
for i=1:length(headers)
    if ~isempty(headers{i})
        out =setfield(out,headers{i},c(2:end,strcmp(headers,headers{i})));
    end
end
