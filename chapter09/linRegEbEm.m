function [model, llh] = linRegEbEm(X, t, alpha, beta)
% Fit empirical Bayesian linear model with EM (p.448 chapter 9.3.4)
%   X: d x n data
%   t: 1 x n response
% Written by Mo Chen (sth4nth@gmail.com).
if nargin < 3
    alpha = 0.02;
    beta = 0.5;
end
[d,n] = size(X);

xbar = mean(X,2);
tbar = mean(t,2);

X = bsxfun(@minus,X,xbar);
t = bsxfun(@minus,t,tbar);

C = X*X';
Xt = X*t';
idx = (1:d)';
dg = sub2ind([d,d],idx,idx);
I = eye(d);
tol = 1e-4;
maxiter = 100;
llh = -inf(1,maxiter+1);
for iter = 2:maxiter
    A = beta*C;
    A(dg) = A(dg)+alpha;  % 3.81 3.54
    U = chol(A);
    V = U\I;            % A=inv(S)

    w = beta*(V*(V'*Xt));  % 3.84
    w2 = dot(w,w);
    err = sum((t-w'*X).^2);
    
    logdetA = 2*sum(log(diag(U)));    
    llh(iter) = 0.5*(d*log(alpha)+n*log(beta)-alpha*w2-beta*err-logdetA-n*log(2*pi));  % 3.86
    if abs(llh(iter)-llh(iter-1)) < tol*abs(llh(iter-1)); break; end
    
    trS = dot(V(:),V(:));    % A=inv(S)
    alpha = d/(w2+trS);   % 9.63
    
    gamma = d-alpha*trS;   % 9.64
    beta = n/(err+gamma/beta);  % 9.68
end
w0 = tbar-dot(w,xbar);

llh = llh(2:iter);
model.w0 = w0;
model.w = w;
%% optional for bayesian probabilistic inference purpose
model.alpha = alpha;
model.beta = beta;
model.xbar = xbar;
model.U = U;