function [Costo]=CostoViga(L,Le,rec,BApoyo,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro,Vfc)
% Esta función determina el costo de la viga actual

% Costos de los materiales
Cfc = [1103.2, 1253.7, 1354.8, 1420.3, 1502.5, 1570.1, 1668.2, 1722.9, 1777.6, 1832.3]; % MXN/m3
Cacero = 19.64; % MXN/kg
Ccimbra = 220.0; % MXN/m2

% Costo del concreto
Concreto=(L+BApoyo)*B*H*Cfc(1,find(Vfc==fc));

% Costo del acero longitudinal
Longitudinal=(L+BApoyo+H)*(Asc+As1+As2)*Cacero*7860;

% Costo estribos
if(Le-BApoyo/2-d<0)
    Lc=L-BApoyo;
    EstribosApoyo=2*(1+1)*(B-2*rec+H-2*rec)*Av*Cacero*7860;
    EstribosCentro=(round(Lc/sECentro)-1)*(B-2*rec+H-2*rec)*Av*Cacero*7860;
else
    Lc=L-(2*round((Le-BApoyo/2-d)/sEApoyo)*sEApoyo+d+BApoyo/2);
    EstribosApoyo=2*(round((Le-BApoyo/2)/sEApoyo)+1)*(B-2*rec+H-2*rec)*Av*Cacero*7860;
    EstribosCentro=(round(Lc/sECentro)-1)*(B-2*rec+H-2*rec)*Av*Cacero*7860;
end

% Costo cimbra
Cimbra=(L+BApoyo)*(B+2*H)*Ccimbra;

% Costo total
Costo=Concreto+Longitudinal+EstribosApoyo+EstribosCentro+Cimbra;
end

