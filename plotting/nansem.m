function s = nansem(x)

s = nanstd(x)./sqrt(sum(~isnan(x)));

