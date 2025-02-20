function [MD,Estabilidad] = ArmaduraAleatoria(R,Areas,Posiciones,Simetria)
% Esta función define la solución inicial del proceso de optimización

% Se genera la base de la MD
MD=zeros(size(Posiciones,1),size(Posiciones,1));

% La solicuión inicial no tiene todas las conexiones activas
for i=1 : size(MD,1)
    for j=1 : size(MD,2)
        if j==i+1  
            MD(i,j:size(MD,2))=round(rand(1,size(MD,2)-j+1)); 
        end
        if MD(i,j,1)==1
            MD(i,j,2)=Areas(randi(size(Areas,2)))/10000;
        end
    end
end

% Se impone simetría en la estructura
for i=1 : size(MD,1)
    [a1,b1]=find(Simetria==i);
    X1=Simetria(a1(1,1),:);
    
    if size(find(X1~=i),2)==0
        c1=X1(1,1);
    else
        c1=X1(1,find(X1~=i,1));
    end
    
    for j=1 : size(MD,2)
        if j>=i+1
            [a2,b2]=find(Simetria==j);
            X2=Simetria(a2(1,1),:);
            
            if size(find(X2~=j),2)==0
                c2=X2(1,1);
            else
                c2=X2(1,find(X2~=j,1));
            end
            
            MD(min(c1,c2),max(c1,c2),:)=MD(i,j,:);
        end
    end
end

% Se determina si la armadura es estable
% Para calcular el grado de hiperestaticidad total
% GHT = GHI + GHE

% GHE = N incognitas - N restricciones
GHE=3-sum(sum(R(:,2:3)));

% GHI = Coaxiones internas - GDLI
% GDLI = 3*(Barras totales - 1)
GDLI=3*(sum(sum(MD(:,:,1)))-1);

% Coaxiones internas = 2*Nodos*(Barras que convergen al nodo - 1)
% Se determinan las barras que convergen a cada nodo
Conv=sum(MD(:,:,1),1)+transpose(sum(MD(:,:,1),2));
CI=zeros(1,max(Conv)-1);

% Si el modelo generado tiene un nodo conectado a una única barra
if find(Conv==1,2)~=0
    Estabilidad=0;
    return
else
    % Se calculan las coaxiones internas
    for i=2:max(Conv)
        if size(find(Conv==i),2)~=0
            CI(1,i-1)=2*size(find(Conv==i),2)*(i-1);
        end
    end
    
    % Cálculo de GHT
    CI=sum(CI);
    GHI=CI-GDLI;
    GHT=GHI+GHE;
    
    if GHT<=0
        Estabilidad=0;
    else
        Estabilidad=1;
    end
end

end