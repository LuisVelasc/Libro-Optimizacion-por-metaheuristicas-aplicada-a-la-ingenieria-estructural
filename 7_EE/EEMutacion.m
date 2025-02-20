function [Mut] = EEMutacion(Solucion,Vv,i)
% Función que define la variable a mutar y cómo hacerlo
Xx=Vv(i,1:find(Vv(i,:)==0,1)-1); % Valores de la variable

if(size(Xx,2)==0)
    Xx=Vv(i,:);
end

p=find(Solucion(1,i+1)==Xx);    % Posición en el vector
m=randi(2);                     % Dirección del cambio

if(m==1)
    if(p~=1)
        Mut=Xx(1,p-1);  % Nuevo valor
    else
        Mut=Xx(1,p);    % No se altera el valor
    end
else
    if(p~=size(Xx,2))
        Mut=Xx(1,p+1);  % Nuevo valor
    else
        Mut=Xx(1,p);    % No se altera el valor
    end
end

end

