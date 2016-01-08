function E = efficiency(s,n)
% E = efficiency(s,n)
%
%Calculates the efficiency of a stimulus sequence s of length n.
%by creating the design matrix and calculating:
%E = 1/trace(inv(X'*X));
%
%Written by G.M. Boynton in October 2007 for Psych 555C at the University 
%of Washington.
%
%For details see:
%Dale, A.M. 'Optimal Experimental Design for Event-Related fMRI
%Human Brain Mapping 8:109-114 (1999)


%make the event matrix out of the event sequence
X = zeros(length(s),n);
temp = s;
for i=1:n
    X(:,i) = temp;
    temp = [0;temp(1:end-1)];
end

%calculate the efficiency
E = 1/trace(inv(X'*X));