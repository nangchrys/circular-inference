function p = expit(L)
% standard logistic function
% transforms (-Inf, Inf) inputs to (0, 1) outputs

p = 1./(1+exp(-L));