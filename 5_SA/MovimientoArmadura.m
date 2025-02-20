function [MD,Estabilidad] = MovimientoArmadura(pV,Pdism,Pquit,R,Areas,MD,Simetria)
% Se generar una nueva solución en una vecindad de MD actúal
VectorMD=[];

for i=1 : size(MD,1)
    for j=1 : size(MD,2)
        if j==i+1
            VectorMD=horzcat(VectorMD,MD(i,j:size(MD,2),2)*10000);
        end
    end
end

% Se hace que valor de MD sean enteros
VectorMD=fix(VectorMD);

% Vector que selecciona variables a modificar aleatoriamente 
m=unique(randi(size(VectorMD,2),1,round(randi(size(VectorMD,2))*pV)));

% Proceso de modificación
for i=1 : size(m,2)
    if VectorMD(1,m(1,i))~=0 && VectorMD(1,m(1,i))~=5 &&...
            VectorMD(1,m(1,i))~=max(Areas)
        if rand()<Pdism
            VectorMD(1,m(1,i))=Areas(1,find(Areas==VectorMD(1,m(1,i)))-1);
        else
            VectorMD(1,m(1,i))=Areas(1,find(Areas==VectorMD(1,m(1,i)))+1);
        end
    else
        if VectorMD(1,m(1,i))==0 && rand<1-Pdism
            VectorMD(1,m(1,i))=min(Areas);
        elseif VectorMD(1,m(1,i))==5 && rand<Pdism
            VectorMD(1,m(1,i))=0;
        end
    end
end

% Se actualiza MD
a=1;
for i=1 : size(MD,1)
    for j=1 : size(MD,2)
        if j==i+1
            b=size(MD,2)-j+a;
            MD(i,j:size(MD,2),2)=VectorMD(1,a:b)/10000;
            a=b+1;
        end
        if MD(i,j,2)~=0
            MD(i,j,1)=1;
        elseif MD(i,j,2)==0
            MD(i,j,1)=0;
        end
    end
end

% Se elimina una barra con área transversal mínima
if rand()<Pquit
    [a,b]=find(MD(:,:,2)==min(Areas)/10000);
    c=horzcat(a,b);
    if size(c,1)~=0
        Borrar=randi(size(c,1));
        MD(c(Borrar,1),c(Borrar,2),:)=0;
    end
end

% Se determinan las barras que convergen a cada nodo
Conv=sum(MD(:,:,1),1)+transpose(sum(MD(:,:,1),2));

% Se elimina un nodo aleatorio con dos barras
if size(find(Conv==2),2)~=0
    Borrar=find(Conv==2);
    Borrar=Borrar(1,randi(size(Borrar,2)));
    if Borrar>7
        MD(Borrar,:,:)=0;
        MD(:,Borrar,:)=0;
    end
end

% Se impone la existencia del cordon inferior
for h=1:5
    if MD(h,h+1,1)==0
        MD(h,h+1,1)=1;
        MD(h,h+1,2)=Areas(randi(size(Areas,2)))/10000;
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
    
    if GHT<=1
        Estabilidad=0;
    else
        Estabilidad=1;
    end
end
end