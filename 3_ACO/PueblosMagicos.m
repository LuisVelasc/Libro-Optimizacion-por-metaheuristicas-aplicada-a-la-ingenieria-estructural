% Se limpian variables
clc
clear

% Se definen parámetros iniciales
alfa=2.0;           % Coef. intensidad
beta=2.5;           % Coef. distancia
ro=0.95;            % Coef. evaporación
Q=10^5;             % Feromonas
a=4;                % Hormigas por pueblo
tao=0.1;            % Intensidad inicial
CiclosTotales=25;   % Iteraciones a realizar
R=6367.5;           % Radio estimado de la Tierra
cRestr=1;           % 1=Sí, 0=No

% Se defien las posiciones de cada pueblo
X=load('PueblosMagicos.txt');
X=transpose(X);

% Restricciones
CRest=[8,43,45,55,96,116,118,17,22,42,72,73,83,101];
CY=[8,43,45,55,96,116,118];

% Se definen dimensiones
n=size(X,2);    % N de pueblos
m=a*n;          % N de hormigas totales

% Matrices de ceros
D=zeros(n,n);           % De distancia
Nu=zeros(n,n);          % De visibilidad
P=zeros(n,n);           % De probabilidad
L=zeros(m,n);           % De longitudes
MResultados=zeros(m,n); % De resultados

% Se define las matrices de intensidad
T=tao*ones(n,n);
DT=zeros(n,n);

% Mejores resultados
MejorL=10^9;
MejorRuta=zeros(1,n);

% Se definen matriz de distancia
for i=1 : n
    for j=1 : n
        D(i,j)=2*R*asin(((sind((X(1,j)-X(1,i))/2))^2+cosd(X(1,i))*cosd(X(1,j))*(sind((X(2,j)-X(2,i))/2))^2)^(1/2));
        
        if cRestr==1
            % Si se entra a Yucatán
            if size(find(j==CY),2)~=0
                if size(find(i==CRest),2)==0
                    D(i,j)=1000*D(i,j);
                end
            end
            
            % Si se sale de Yucatán
            if size(find(i==CY),2)~=0
                if size(find(j==CRest),2)==0
                    D(i,j)=1000*D(i,j);
                end
            end
            
        end
        
    end
end

% Se define la matriz de visibilidad
for i=1 : n
    for j=1 : n
        if i==j
            Nu(i,j)=0;
        else
            Nu(i,j)=1/D(i,j);
        end
    end
end

% Se define la matriz de probabilidad
for i=1 : n
    for j=1 : n
        P(i,j)=(T(i,j)^alfa)*(Nu(i,j)^beta)/(dot(T(i,:).^alfa,Nu(i,:).^beta));
    end
end

% Se define la matriz de ciudades
b=diag(ones(1,n));
Tabu = b;
for i=1 : a-1
    Tabu=[Tabu;b];
end

% Se aplica el algoritmo, actualización de feromonas por ciclo
for Ciclo=1 : CiclosTotales
    for i=1 : m
        Cont=1; % Contador para almacenar resultados
        d=find(1==Tabu(i,:),1);     % Localiza pueblo inicial i de la hormiga
        MResultados(i,Cont)=d;      % Se inicia ruta
        
        for j=1 : n
            % Se obtiene lista de posibles movimientos
            if j==n
                U=Tabu(i,:);
                U(1,MResultados(i,1))=0;
            else
                U=Tabu(i,:);
            end
            
            % Se cambian valores (1=0) y (0=1)
            U(U==0)=2;
            U(U==1)=0;
            U(U==2)=1;
            
            % Se descartan las probabilidades de los no movimientos permitidos
            V=U.*(P(d,:));
            
            % Se crean los intervalos de probabilidad que definen qué movimiento
            % realizar
            for k=1 : n
                W(1,k)=sum(V(1,[1:k]));
            end
            
            % Se normaliza la probabilidad hasta 1
            W=W./W(1,n);
            
            % c es el pueblo de salida
            c=d;
            
            % d es el pueblo destino
            d=find(rand<W,1);
            
            % Se actualiza la matriz de movimientos permitidos
            Tabu(i,d)=1;
            
            % Se actualiza matriz de distancia y resultados
            Cont=Cont+1;
            L(i,Cont)=D(c,d);
            MResultados(i,Cont)=d;
        end
        
        % Se determina distancia total recorrida por la hormiga
        L(i,1)=sum(L(i,[2:n+1]));
                
    end % Se ha completado una iteración
    
    % Se guardar los mejores resultados de la iteración
    if min(L(:,1))<MejorL
        MejorL= min(L(:,1));
        MejorRuta=MResultados(find(L(:,1)==MejorL),:);
        figure(1)
        comet(X(2,MejorRuta(1,:)),X(1,MejorRuta(1,:)),0.05)
    end
    
    min(L(:,1))
    % Se actualizan las feromonas generadas en esta iteración
    for i=1 : m
        for j=1 : n-1
            pinicial=MResultados(i,j);
            pfinal=MResultados(i,j+1);
            
            DT(pinicial,pfinal)=DT(pinicial,pfinal)+Q/L(i,1);
            T(pinicial,pfinal)=ro*T(pinicial,pfinal)+DT(pinicial,pfinal);
        end
    end
    
    % Se actualiza la matriz de probabilidad
    for i=1 : n
        for j=1 : n
            P(i,j)=(T(i,j)^alfa)*(Nu(i,j)^beta)/(dot(T(i,:).^alfa,Nu(i,:).^beta));
        end
    end

    % Se limpia la matriz de ciudades
    b=diag(ones(1,n));
    Tabu = b;
    for i=1 : a-1
        Tabu=[Tabu;b];
    end
end

% Comprobación de la mejor respuesta
for i=1 : n
    MejorD(1,i)=D(MejorRuta(1,i),MejorRuta(1,i+1));
end
sum(MejorD(1,:))

% Regresar resultado final
Y=importdata('ListaPueblos.txt');

for i=1 : n
    CiudadesOrdenadas(1,i)=Y(MejorRuta(1,i),1);
end

CiudadesOrdenadas=transpose(CiudadesOrdenadas);

% Se grafica la mejor solución encontrada
Y=load('Pais.txt');

figure(1)
plot(Y(:,2),Y(:,1),'color',[0.25 0.8 1])
hold on
comet(X(2,MejorRuta(1,:)),X(1,MejorRuta(1,:)),0.05)

xlabel("Longitud, grados","fontSize",16)
ylabel("Latitud, grados","fontSize",16)
get(gca,'fontname')
set(gca,'fontname','Cambria Math')
hold off