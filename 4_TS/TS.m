% Minimización de una función por medio de TS
clear;
clc,

% Parámetros del problema
D=10;                       % Dimensiones del problema
f_bias=-330;                % Valor del mínimo
V=-5:0.1:5;                 % Valores de las D variables
o=V(randi(size(V,2),1,D));  % Posición del mínimo

% Se definen los parámetros de búsqueda 
A_max=500;      % Reinicios máximos usando memoria larga
B_max=5000;     % Número máximo de soluciones sin obtener mejora
pV=0.15;        % Porcentaje de variables a modificar
Tenure=1;       % Movimientos que dura un tabú activo
p=0.5;          % Porcentaje de soluciones guardadas

% Matrices de ceros
MS=zeros(1,D);                  % Mejor solución encontrada
TL=zeros(Tenure,round(p*pV*D)); % Lista Tabú
LF=ones(size(V,2),D).*0.05;     % Lista de frecuencias

% Generación de solución inicial aleatoria
X=V(randi(size(V,2),1,D));
F=ValorTS(X,o,f_bias);

% Valores para iniciar el while
B=1; C=1; Fs=[];

for A=1:A_max
   while B<=B_max
       [x,T]=MovimientoTS(D,pV,V,X,Tenure,p,TL);
       f=ValorTS(x,o,f_bias);
       
       if(f<F)
          X=x; F=f; B=1;
          Fs=[Fs;F];
          
          % Se activan tabús
          M=T(1,unique(randi(size(T,2),1,ceil(p*size(T,2)))));
          TL(C,:)=0;
          TL(C,1:size(M,2))=M;
          
          if (C==Tenure)
              C=1;
          else
              C=C+1;
          end
          
          % Se guardan frecuencias
          for i=1:D
              LF(find(V==X(1,i)),i)=LF(find(V==X(1,i)),i)+1.05^F;
          end
             
       else
           B=B+1;
       end   
   end
   
   if(A<A_max)
       B=1;
       TL=zeros(Tenure,round(p*pV*D)); % Reinicio de Lista Tabú
       
       for i=1:D
           Ruleta=LF(:,i).^-2;
           Ruleta=cumsum(Ruleta./sum(Ruleta(:,1)));
           X(1,i)=V(1,find(rand<Ruleta,1));
       end
       
       F=ValorTS(X,o,f_bias);
       Fs=[Fs;F];
   end
   
end

min(Fs)