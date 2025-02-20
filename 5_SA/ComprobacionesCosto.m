function [Check,Peso,Barras] = ComprobacionesCosto(Chi,fy,GammaS,Barras)
% Comprobaciones de la resistencia de las barras
Peso=0; % Por si no cumple comprobaciones

for i=1 : size(Barras,1)
    if Barras(i,8)<0 % A compresión
        if abs(Barras(i,8))<Chi*fy*10^3*Barras(i,3)
            Check=1; % Cumple
            Barras(i,9)=abs(Barras(i,8))/(Chi*fy*10^3*Barras(i,3));
        else
            Check=0; % No cumple
            return
        end
    else % A tensión
        if Barras(i,8)<fy*10^3*Barras(i,3)
            Check=1; % Cumple
            Barras(i,9)=Barras(i,8)/(fy*10^3*Barras(i,3));
        else
            Check=0; % No cumple
            return
        end
    end
end

% Se determina el peso total de la estructura
Peso=zeros(size(Barras,1),1);

for i=1 : size(Barras,1)
   Peso(i,1)=Barras(i,3)*Barras(i,5)*GammaS;
end

Peso=sum(Peso);
end