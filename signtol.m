function s = signtol(x, tol)
% Calculates the sign of x, given tolerance tol

s = (x>tol)-(x<-tol);