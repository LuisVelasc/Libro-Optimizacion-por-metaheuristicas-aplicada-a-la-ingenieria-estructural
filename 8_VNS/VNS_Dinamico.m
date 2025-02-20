% Se limpian variables
clc
clear

% Se definen parámetros del problema
pV=0.40;
Vecindarios=[1,2,3,5,7,10];
IterMax=[50,35,35,25,25,20];

% Se definen intervalos de las variables de decisión
dH=0.1;
rho=(1300:10:2000);
G=(50000:500:100000);
Bulk=(190000:500:420000);
Coh=(20:1:60);
refPress=(5:1:110);

% Matrices con tamaño predefinido
MD=zeros(6,7);
md=zeros(6,7);
VD=zeros(5,size(Bulk,2)+1);
H=zeros(1,size(MD,2));
A=2*ones(size(MD,1),size(MD,2));
Error=[];

% Se carga el modelo inicial y se almacena en MD
% 1)Profundidad; 2)Densidad; 3)G; 4)Bulk; 5)Cohesión; 6)Presión de
% referencia
MD(1,:)=[5.0 8.0 22.0 28.0 31.0 43.0 48.0];
MD(2,:)=[1300 1500 1400 1600 1600 1600 1800];
MD(3,:)=[50000 60000 75000 65000 75000 80000 90000];
MD(4,:)=[190000 210000 220000 200000 250000 350000 400000];
MD(5,:)=[25.0 30.0 35.0 25.0 30.0 45.0 50.0];
MD(6,:)=[10.0 50.0 50.0 50.0 80.0 100.0 100.0];
DespI=load('DespTopInicial.out');

% Agrupamos las variables de decisión en una matriz
VD(1,1:size(rho,2))=rho;
VD(2,1:size(G,2))=G;
VD(3,1:size(Bulk,2))=Bulk;
VD(4,1:size(Coh,2))=Coh;
VD(5,1:size(refPress,2))=refPress;

% Se cargan las desplazamientos reales 
DespR=load('DespTopReal.out');
EC=sum((DespI-DespR).^2);
Error=EC;

for k=1:size(Vecindarios,2)
    n=Vecindarios(1,k);
    for m=1:IterMax(1,k)
        % Matriz con valores a modificar aleatoriamente
        a=round(rand(1,randi(round(pV*size(MD,1)*size(MD,2)))));
        for i=1:size(a,2)
            A(randi(size(MD,1)),randi(size(MD,2)))=a(1,i);
        end
        
        % Creación de nueva solución en vecindad
        md=MD;
        for i=1:size(md,2)
            if i==1
                H(1,i)=md(1,i);
            else
                H(1,i)=md(1,i)-md(1,i-1);
            end
            for j=1:size(md,1)
                if j==1
                    if A(j,i)==0
                        if H(1,i)-n*dH>0
                            md(j,i)=md(j,i)-n*dH;
                        end
                    elseif A(j,i)==1
                        if i==size(md,2)
                            md(j,i)=md(j,i)+n*dH;
                        else
                            if md(j,i)+n*dH<md(j,i+1)
                                md(j,i)=md(j,i)+n*dH;
                            end
                        end
                    end
                else
                    Var=VD(j-1,1:(find(VD(j-1,:)==0)-1));
                    B=find(md(j,i)==Var);
                    if A(j,i)==0
                        B=max(1,B-n);
                        md(j,i)=Var(1,B);
                    elseif A(j,i)==1
                        B=min(size(Var,2),B+n);
                        md(j,i)=Var(1,B);
                    end
                end
            end
        end
        
        % Se genera un nuevo modelo para OpenSees
        VariablesSuelo;
        
        % Se analiza el modelo en OpenSees
        !OpenSees.exe "SueloDinamico.tcl"
        Desp=load('DespTop.out');
        
        % Se determina el Error Cuadrático
        if size(Desp,1)==size(DespR,1)
            ec=sum((Desp-DespR).^2);
        end
        
        if EC>ec
            k=1;
            m=1;
            MD=md;
            EC=ec;
            Error(1,size(Error,2)+1)=EC;
        end
    end
end

% Resultado final
md=MD;
VariablesSuelo;
!OpenSees.exe "SueloDinamico.tcl"