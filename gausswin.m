function [w] = gausswin(M,alpha)
n = -(M-1)/2 : (M-1)/2;
w = exp((-1/2) * (alpha * n/(M/2)) .^ 2);