function p = expit(L)
    % Standard logistic function.
    % Transforms (-Inf, Inf) inputs to (0, 1) outputs,

    p = 1 ./ (1 + exp(-L));
end
