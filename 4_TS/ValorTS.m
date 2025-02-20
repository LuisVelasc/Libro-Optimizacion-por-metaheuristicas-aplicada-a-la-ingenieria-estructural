function [f] = ValorTS(x,o,f_bias)
% Esta función valora la solución propuesta por TS
x=x-o;
f = sum(x.^2-10.*cos(2.*pi.*x)+10,2)+f_bias;
end

