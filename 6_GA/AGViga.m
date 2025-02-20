% Optimización de una viga por Algoritmos Genéticos
clear

% Se definen los valores de las variables
Vfc=(25:5:70);          % fc = Resistencia del concreto
VH=(0.35:0.05:2.4);     % H = Peralte de la sección
VB=(0.35:0.05:2.4);     % B = Ancho de la sección
Vn=(2:1:30);            % nc,n1,n2 = N barras (compresión, tensión sup, tensión inf)
Vfi=[3,4,5,6,8,10,12];  % fic,fi1,fi2 = Diámetro acero (compresión, tensión sup, tensión inf)
VnE=[1,2];              % nE = N de estribos
VfiE=[2.5,3];           % fiE = Diámetro de los estribos
VsE=(0.075:0.025:0.30); % sE = Separación de los estribos (Apoyos y centro)

% Parámetros del problema
L=12;         % Longitud viga, m
BApoyo=0.30;  % Ancho de los apoyos, m
rec=0.04;     % Recubrimiento, m
w=4.5;        % Carga distribuida servicio, kN/m
Wm=6.25;      % Carga distribuida rotura, kN/m

% Parámetros del algoritmo de búsqueda
TP=450;         % Tamaño de la población inicial
TV=450;         % Tamaño de la poblacion de descendientes
TT=4;           % Tamaño del torneo
GenMax=100;     % Número máximo de generaciones
PCruce=0.9;     % Probabilidad de cruce
PMutacion=0.2;  % Probabilidad de mutación

% Matrices de ceros
Poblacion=zeros(TP,15);
Torneo=zeros(2,TT);
Participantes=zeros(1,TT);
Vv=zeros(14,max([size(Vfc,2),size(VH,2),size(VB,2),size(Vn,2),size(VsE,2)]));
Costos=zeros(TP,1);
Vastagos=zeros(TP,15); 
CostosV=zeros(TV,1);
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
while i<=TP
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
for Generacion=1:GenMax
    % Se aplica estrategia elitista
    Vastagos(1,1:15)=Poblacion(find(CostoMin==Costos,1),1:15);
    CostosV(1,1)=Costos(find(CostoMin==Costos,1),1);

    % Creación de una nueva generacion
    i=2; % Para iniciar el while
    while i<=TV
        % Se escoge pareja 1
        a=0;
        % Se determinan los participantes del torneo
        while a==0
            Participantes=randi(TV,1,TT);
            if size(unique(Participantes),2)==TT
                a=1;
            end
        end
        
        % Se define el torneo
        for j=1:TT
           Torneo(1,j)=Participantes(1,j);
           Torneo(2,j)=Costos(Participantes(1,j),1);
        end
        
        % Primera pareja
        N1=find(Torneo(2,:)==min(Torneo(2,:)),1);
        N1=Torneo(1,N1);
        Pareja1=Poblacion(N1,1:size(Vv,1));
        
        % Se escoge pareja 2
        a=0;
        % Se determinan los participantes del torneo
        while a==0
            Participantes=randi(TV,1,TT);
            if size(find(Participantes==N1),2)==0
                if size(unique(Participantes),2)==TT
                    a=1;
                end
            end
        end
        
        % Se define el torneo
        for j=1:TT
            Torneo(1,j)=Participantes(1,j);
            Torneo(2,j)=Costos(Participantes(1,j),1);
        end
        
        % Segunda pareja
        N2=find(Torneo(2,:)==min(Torneo(2,:)),1);
        N2=Torneo(1,N2);
        Pareja2=Poblacion(N2,1:size(Vv,1));
        
        % Inicia proceso de cruce
        if(rand()<PCruce)
            % Puntos de corte entre variables
            a1=0;
            while a1==0
                Union=sort(randi(size(Vv,1)-1,1,2));
                if size(unique(Union),2)==2
                    a1=1;
                end
            end
            
            % Primera descendencia
            Vastagos(i,1:Union(1,1))=Pareja1(1,1:Union(1,1));
            Vastagos(i,Union(1,1)+1:Union(1,2))=Pareja2(1,Union(1,1)+1:Union(1,2));
            Vastagos(i,Union(1,2)+1:size(Vv,1))=Pareja1(1,Union(1,2)+1:size(Vv,1));
            
            % Proceso de mutación
            if(rand()<PMutacion)
                [Gen,Mut]=Mutacion(Vastagos(i,1:14),Vv);
                Vastagos(i,Gen)=Mut;
            end
            
            % Se revisa la validez de la viga
            [Check,Le,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro]=...
                ComprobacionesAG(Vastagos(i,1:14),L,rec,BApoyo,Wm,w);
            Vastagos(i,1)=Check;
            Vastagos(i,15)=Le;
            
            if(Vastagos(i,1)==0)
                [Costo]=CostoViga(L,Le,rec,BApoyo,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro,Vfc);
                CostosV(i,1)=Costo;
                i=i+1;
            end
            
            % Para no crear soluciones adicionales
            if(i>TV)
                break
            end
            
            % Segunda descendencia
            Vastagos(i,1:Union(1,1))=Pareja2(1,1:Union(1,1));
            Vastagos(i,Union(1,1)+1:Union(1,2))=Pareja1(1,Union(1,1)+1:Union(1,2));
            Vastagos(i,Union(1,2)+1:size(Vv,1))=Pareja2(1,Union(1,2)+1:size(Vv,1));
            
            %  Proceso de mutación
            if(rand()<PMutacion)
                [Gen,Mut]=Mutacion(Vastagos(i,1:14),Vv);
                Vastagos(i,Gen)=Mut;
            end
            
            % Se revisa la validez de la viga
            [Check,Le,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro]=...
                ComprobacionesAG(Vastagos(i,1:14),L,rec,BApoyo,Wm,w);
            Vastagos(i,1)=Check;
            Vastagos(i,15)=Le;
            
            if(Vastagos(i,1)==0)
                [Costo]=CostoViga(L,Le,rec,BApoyo,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro,Vfc);
                CostosV(i,1)=Costo;
                i=i+1;
            end  
        else
            Vastagos(i,1:15)=Poblacion(N1,1:15);
            CostosV(i,1)=Costos(N1,1);
            i=i+1;
            if(i<TV)
                Vastagos(i,1:15)=Poblacion(N2,1:15);
                CostosV(i,1)=Costos(N2,1);
            end
        end
    end
        
    Poblacion=Vastagos(1:TV,:);
    Vastagos=zeros(TV,1);
    Costos=CostosV;
    CostoMin=min(Costos(:,1))
    Cmin(Generacion,1)=CostoMin;
end