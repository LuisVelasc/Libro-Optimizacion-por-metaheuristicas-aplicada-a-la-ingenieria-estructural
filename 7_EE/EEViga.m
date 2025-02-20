% Optimización de una viga por Estrategias Evolutivas
% clear

% Se definen los valores de las variables
Vfc=(25:5:70); % fc = Resistencia del concreto
VH=(0.35:0.05:2.4); % H = Peralte de la sección
VB=(0.35:0.05:2.4); % B = Ancho de la sección
Vn=(2:1:30); % nc,n1,n2 = N barras (compresión, tensión sup, tensión inf)
Vfi=[3,4,5,6,8,10,12]; % fic,fi1,fi2 = Diámetro acero (compresión, tensión sup, tensión inf)
VnE=[1,2]; % nE = N de estribos
VfiE=[2.5,3]; % fiE = Diámetro de los estribos
VsE=(0.075:0.025:0.30); % sE = Separación de los estribos (Apoyos y centro)

% Parámetros fijos del problema
L=12;         % Longitud viga, m
BApoyo=0.30;  % Ancho de los apoyos, m
rec=0.04;     % Recubrimiento, m
w=4.5;        % Carga distribuida servicio, kN/m
Wm=6.25;      % Carga distribuida rotura, kN/m

% Parámetros del algoritmo de búsqueda
Mu=12;        % Tamaño de la población
GenMax=2500;  % Número máximo de generaciones
PM=0.50;      % Probabilidad mutacion hacia la vecindad

% Matrices de ceros
Poblacion=zeros(Mu,15);
Vv=zeros(13,max([size(Vfc,2),size(VH,2),size(VB,2),size(Vn,2),size(VsE,2)]));
Costos=zeros(Mu,1);
Solucion=zeros(1,15); 
Cmin=zeros(GenMax,1);

% Se determina el espacio de soluciones del problema
EspacioSoluciones = size(Vfc,2)*size(VH,2)*size(VB,2)*size(Vn,2)^3*...
    size(Vfi,2)^3*size(VnE,2)*size(VfiE,2)*size(VsE,2)

% Matriz con todos los valores de las variables
Vv(1,1:size(Vfc,2))=Vfc;
Vv(2,1:size(VH,2))=VH;
Vv(3,1:size(VB,2))=VB;
Vv(4,1:size(Vn,2))=Vn;
Vv(5,1:size(Vfi,2))=Vfi;
Vv(6,1:size(Vn,2))=Vn;
Vv(7,1:size(Vfi,2))=Vfi;
Vv(8,1:size(Vn,2))=Vn;
Vv(9,1:size(Vfi,2))=Vfi;
Vv(10,1:size(VnE,2))=VnE;
Vv(11,1:size(VfiE,2))=VfiE;
Vv(12,1:size(VsE,2))=VsE;
Vv(13,1:size(VsE,2))=VsE;

% Se genera la población inicial
i=1; % Para iniciar el while
while i<=Mu
    Poblacion(i,1)=0;
    Poblacion(i,2)=Vv(1,randi(size(Vfc,2)));
    Poblacion(i,3)=Vv(2,randi(size(VH,2)));
    Poblacion(i,4)=Vv(3,randi(size(VB,2)));
    Poblacion(i,5)=Vv(4,randi(size(Vn,2)));
    Poblacion(i,6)=Vv(5,randi(size(Vfi,2)));
    Poblacion(i,7)=Vv(4,randi(size(Vn,2)));
    Poblacion(i,8)=Vv(5,randi(size(Vfi,2)));
    Poblacion(i,9)=Vv(4,randi(size(Vn,2)));
    Poblacion(i,10)=Vv(5,randi(size(Vfi,2)));
    Poblacion(i,11)=Vv(10,randi(size(VnE,2)));
    Poblacion(i,12)=Vv(11,randi(size(VfiE,2)));
    Poblacion(i,13)=Vv(12,randi(size(VsE,2)));
    Poblacion(i,14)=Vv(12,randi(size(VsE,2)));
    
    % Comprobaciones de la solución
    [Check,Le,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro]=...
        ComprobacionesAG(Poblacion(i,1:14),L,rec,BApoyo,Wm,w);
    Poblacion(i,1)=Check;
    Poblacion(i,15)=Le;
  
    if(Poblacion(i,1)==0)
        [Costo]=CostoViga(L,Le,rec,BApoyo,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro,Vfc);
        Costos(i,1)=Costo;
        i=i+1;
    end
end

CostoMin=min(Costos(:,1))
Cmin(1,1)=CostoMin;

% Repeticion de las generaciones
Generacion=1; % Para iniciar el while
while Generacion<GenMax
    % Creación de una nueva solución
    for i=1 : size(Vv,1)
        Solucion(1,i+1)=Poblacion(randi(Mu),i+1);
        
        if(rand()<=PM)
            [Mut]=EEMutacion(Solucion,Vv,i);
            Solucion(1,i+1)=Mut;
        else
            if(rand()<=1-PM)
                [Mut]=EEMutacion2(Vv,i);
                Solucion(1,i+1)=Mut;
            end
        end
    end
    % Se revisa la validez de la viga
    [Check,Le,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro]=...
        ComprobacionesAG(Solucion,L,rec,BApoyo,Wm,w);
    Solucion(1,15)=Le;
    
    if(Check==0)
        [Costo]=CostoViga(L,Le,rec,BApoyo,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro,Vfc);
        Generacion=Generacion+1;
        
        if(max(Costos)>Costo)
            j=find(max(Costos)==Costos,1);
            Poblacion(j,:)=Solucion;
            Costos(j,1)=Costo;
        end      
        CostoMin=min(Costos(:,1))
        Cmin(Generacion,1)=CostoMin;
        Solucion=zeros(1,15);
    end
end