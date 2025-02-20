function [Barras,Nodos] = MetodoRigidez(R,F,MD,Posiciones,E)
% Se aplica el método de rigidez para resolver la armadura

% Se define el vector de barras por MD
Barras=[];

for i=1 : size(Posiciones,1)
    for j=1 : size(Posiciones,1)
        if MD(i,j)==1
            Barras=cat(1,Barras,[i,j,MD(i,j,2),E]);
        end
    end
end

% Se define el vector de nodos por MD
Nact=transpose(unique(Barras(:,(1:2))));
Nodos=[];

for i=1: size(Nact,2)
    X1=find(Posiciones(:,1)==Nact(1,i));
    Nodos=cat(1,Nodos,[Nact(1,i),Posiciones(X1,(2:3))]);
end

% Se agregan elementos a la matriz nodos
Nodos=horzcat(Nodos,zeros(size(Nodos,1),2));

% Se enumeran los grados de libertad
for i=1:size(Nodos,1)
    % Si el nodo no tiene restricción
    if size(find(Nodos(i,1)==R(:,1)),1)==0
        Nodos(i,1:5)=horzcat(Nodos(i,1:3),...
            1+max(max(Nodos(:,4:5))),2+max(max(Nodos(:,4:5))));
    
    % Si esta parcialmente restringido
    else
        if size(find(0==R(R(:,1)==Nodos(i,1),2:3)),2)==1
            Nodos(i,1:5)=horzcat(Nodos(i,1:3),...
                1+max(max(Nodos(:,4:5))),1+max(max(Nodos(:,4:5))));
            Nodos(i,3+find(1==R(R(:,1)==i,2:3)))=0;
        end
    end
end

% Resto de nodos
z=transpose(find(0==Nodos(:,4:5)));
for i=1:size(z,2)
    Nodos(3*size(Nodos,1)+z(1,i))=1+max(max(Nodos(:,4:5)));
end

% Se crea la matriz de fuerzas en cada nodo
FN=zeros(2*size(Nodos,1),1);

% Se asocian fuerzas a los GDL de los nodos
for i=1:size(F,1)
    FN(Nodos(F(i,1),4))=F(i,2);
    FN(Nodos(F(i,1),5))=F(i,3);
end

Barras=horzcat(Barras,zeros(size(Barras,1),4));

% Matriz que almacena todas la matrices de rigidez
Kb=zeros(5,4,size(Barras,1));

% Se definen las matrices de rigidez de cada barra
for i=1:size(Barras,1)
    X1=find(Nodos(:,1)==Barras(i,1));
    X2=find(Nodos(:,1)==Barras(i,2));
    
    L=((Nodos(X2,2)-Nodos(X1,2))^2+(Nodos(X2,3)-Nodos(X1,3))^2)^(1/2);
    Cx=(Nodos(X2,2)-Nodos(X1,2))/L;
    Sy=(Nodos(X2,3)-Nodos(X1,3))/L;
    
    Barras(i,5)=L;
    Barras(i,6)=Cx;
    Barras(i,7)=Sy;
    
    % Se registran los GDL de cada barra
    for j=1:2
        X3 = find(Nodos(:,1)==Barras(i,j));
        Kb(1,2*j-1,i)=(Nodos(X3,4));
        Kb(1,2*j,i)=(Nodos(X3,5));
    end
    
    % Se introducen resto de datos
    Kb(2:5,:,i)=Barras(i,3)*Barras(i,4)*10^3/L...
        *[Cx^2,Cx*Sy,-(Cx^2),-Cx*Sy;
        Cx*Sy,Sy^2,-Cx*Sy,-(Sy^2);
        -(Cx^2),-Cx*Sy,Cx^2,Cx*Sy;
        -Cx*Sy,-(Sy^2),Cx*Sy,Sy^2];
end

% Se ensambla la matriz de rigidez de la armadura
KG=zeros(2*size(Nodos,1));
for h=1:size(Kb,3)          % Barra
    for i=1:size(Kb,2)      % Filas
       for j=1:size(Kb,2)   % Columnas
           KG(Kb(1,i,h),Kb(1,j,h))=KG(Kb(1,i,h),Kb(1,j,h))+Kb(i+1,j,h);
       end 
    end
end

% Se obtienen los desplazamientos
DLsup=size(KG,1)-size(find(R(:,2:3)==1),1);
DL=pinv(KG(1:DLsup,1:DLsup))*FN(1:DLsup,1);

% Se calculan las reacciones
FRinf=DLsup+1;
FR=KG(FRinf:size(KG,1),1:DLsup)*DL;

% Calculo de fuerzas axiales
DL=vertcat(DL,zeros(size(KG,1)-DLsup,1,1));

% Para asegurar la no singularidad de la matriz
if round(sum(FR(2:3,1)))==round(abs(sum(FN)))
%     Valores negativos indican compresión de la barra
    for h=1:size(Barras,1)
        DNb=[DL(Kb(1,1,h),1);DL(Kb(1,2,h),1);DL(Kb(1,3,h),1);
            DL(Kb(1,4,h),1)];
        Barras(h,8)=Barras(h,3)*Barras(h,4)*10^3/Barras(h,5)*...
            [-Barras(h,6),-Barras(h,7),Barras(h,6),Barras(h,7)]*...
            DNb;
    end
else
    for h=1:size(Barras,1)
        Barras(h,8)=10^10;
    end
end
end