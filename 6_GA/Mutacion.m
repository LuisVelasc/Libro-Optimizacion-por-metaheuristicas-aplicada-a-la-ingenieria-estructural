function [Gen,Mut] = Mutacion(Vastago,Vv)
% Función que define la variable a mutar y cómo hacerlo
a=randi(13);    % Variable a mutar
Gen=a+1;        % Posicion en el codigo de la viga
Xx=Vv(a,1:find(Vv(a,:)==0,1)-1); % Valores de la variable

if(size(Xx,2)==0)
    Xx=Vv(a,:);
end

Go=Vastago(1,Gen);  % Valor actual
p=find(Go==Xx);     % Posición en el vector
m=randi(2);         % Dirección del cambio

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

