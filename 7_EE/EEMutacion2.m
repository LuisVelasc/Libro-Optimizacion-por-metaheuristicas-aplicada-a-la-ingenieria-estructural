function [Mut] = EEMutacion2(Vv,i)
% Función que define la variable a mutar y cómo hacerlo
Xx=Vv(i,:);     % Valores de la variable

if(size(find(Xx==0,1),2)==0)
    Mut=Xx(1,randi(size(Xx,2)));   % Mutación aleatoria
else
    Mut=Xx(1,randi(find(Xx==0,1)-1));   % Mutación aleatoria
end