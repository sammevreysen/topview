function [Z,Y] = verdeling(A,B,C,xa,xb,ints,ints2)
% A,B,C coeffs van integraal; xa en xb = grenzen waarbinnen je wil werken;
% ints = # intervallen integratie (zoveel
% mogelijk als haalbaar, ordegrootte 1000), ints2 = # gelijke lengte
% parabool intervallen (25 of 26-tal)
INTS = (xb-xa)/(ints);
t = transpose(xa:INTS:xb);
for i = 1:1:ints
M(i) = sqrt(((2*A*t(i)+B)*(t(i+1)-t(i)))^2+(t(i+1)-t(i))^2);
T(i) = t(i+1)-t(1);
end
I(1) = M(1);
for i = 2:1:ints
    I(i) = M(i) + I(i-1);
end
J = transpose(I);
D = transpose(T);

jj(1,1)=0;
for i = 1:1:ints2
    jj(i+1,1) = jj(i,1) + J(ints)/ints2;
end
Z = spline(J,D,jj) + xa;
for i = 1:1:(ints2+1)
    Y(i) = A*Z(i)^2+B*Z(i)+C;
end

Y = Y';
%control plots
% y = polyval([A B C],t);
% figure();
% axis ij;
% axis equal;
% plot(t,y,'b-');
% hold on;
% plot(Z,Y,'ro');

end