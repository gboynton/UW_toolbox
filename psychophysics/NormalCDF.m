function y = NormalCDF(p,x)
%y = Normal(p,x)
%
%Parameters:  p.s standard deviation
%             p.u mean
%             x   intensity values.

%y = NormalCumulative(x,p.u,p.s^2);
y = normcdf(x,p.u,p.s);

