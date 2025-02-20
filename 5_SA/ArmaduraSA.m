% Se limpia la memoria del programa
clc
clear

% Se definen los parámetros del proceso de optimización
T0=1/4;         % Fracción del costo inicial como temperatura inicial
Alfa=0.90;      % Factor de enfriamiento
pf=0.01;        % Fracción de la temperatura inicial como criterio de parada
LCM=1000;       % Longitud de la cadena de Markov
pV=0.05;        % Porcentaje de variables a modificar en cada movimiento
Pdism=0.80;     % Probabilidad de disminuir áreas transversales
Pquit=0.50;     % Probabilidad de eliminar una barra con área mínima

% Se definen características de las barras
E=200000;       % Módulo de elásticidad, MPa
fy=275;         % Límite de fluencia, MPa
GammaS=7850;    % Peso específico del acero, kg/m3
Chi=0.7;        % Disminución de resistencia por compresión 

% Vectores que definen valores de las variables consideradas
Areas=(5:5:50);     % Áreas en cm2
DyV=(3.0:0.5:5.0);  % Vector con los posibles valores de Dy

% Se definen los incrementos de los nodos
Dx=8;           % Incrementos en x, en m
Dy=max(DyV);    % Incrementos en y, en m

% Se definen los apoyos
% Nodo, Rx, Ry; (1=Restringido, 0=Libre)
R=[1,1,1;
    11, 0, 1];

% Se definen las fuerzas en los nodos, KN
Fx=0;       % Fuerza en X, kN
Fy=-100;    % Fuerza en Y, kN
F=[];

%  Nodo, Fx, Fy
for i=2 : R(2,1)-1
    F=vertcat(F,[i Fx Fy]);
end

% Por el ciclo inicial
Check=0;

TodosPesos=[];
% Creación del diseño inicial
for i=1 : LCM
    if i==1
        while Check==0
            % Se define la distribución inicial de los nodos
            [Posi,Sime,Dy]=Cuadricula(Dx,DyV,Dy);
            
            % Se genera la armadura inicial
            [MD,Estab]=ArmaduraAleatoria(R,Areas,Posi,Sime);
            
            % Solo si es estable se revisa
            if Estab==1
                % Se resuelve la armadura por método de rigidez
                [Barras,Nodos]=MetodoRigidez(R,F,MD,Posi,E);
                
                % Se realizan comprobaciones y se evalúa la función objetivo
                [Check,Peso,Barras]=ComprobacionesCosto(Chi,fy,GammaS,Barras);
                
                % Se registra peso de la solución inicial
                TodosPesos=Peso;
            end
        end
    else
        % Se modifica la distribución de los nodos
        [posi,sime,dy]=Cuadricula(Dx,DyV,Dy);
        
        % Se genera una solución en la vecindad de la MD actual
        [md,Estab]=MovimientoArmadura(pV,Pdism,Pquit,R,Areas,MD,sime);
        
        % Solo si es estable se revisa
        if Estab==1
            % Se resuelve la armadura por método de rigidez
            [barras,nodos]=MetodoRigidez(R,F,md,posi,E);
            
            % Se realizan comprobaciones y se evalúa la función objetivo
            [Check,peso,barras]=ComprobacionesCosto(Chi,fy,GammaS,barras);
            
            % Se comparan funciones objetivos
            if peso<Peso && Check==1
                MD=md;
                Peso=peso;
                Dy=dy;
                Posi=posi;
                Sime=sime;
            end
        end
    end
end

% Se registra peso de la solución antes de SA
TodosPesos(2,1)=Peso;

% Optimización del diseño inicial por SA
Ti=Peso*T0;     % Temperatura inicial del proceso
T=Ti;           % Temperatura actual del proceso

while T>Ti*pf
    for i=1 : LCM
        % Se genera una solución en la vecindad de la MD actual
        [md,Estab]=MovimientoArmadura(pV,Pdism,Pquit,R,Areas,MD,Sime); 
      
        % Solo si es estable se revisa
        if Estab==1
            % Se resuelve la armadura por método de rigidez
            [barras,nodos]=MetodoRigidez(R,F,md,Posi,E);
            
            % Se realizan comprobaciones y se evalúa la función objetivo
            [Check,peso,barras]=ComprobacionesCosto(Chi,fy,GammaS,barras);
            
            % Se comparan funciones objetivos
            if peso<Peso && Check==1
                MD=md;
                Peso=peso;
                Barras=barras;
                Nodos=nodos;
                
                % Se registra peso de la solución actual
                if TodosPesos(size(TodosPesos,1),1)~=Peso
                    TodosPesos(size(TodosPesos,1)+1,1)=Peso;
                end
            else
                % Se revisa criterio de aceptación
                if rand()<exp(-((peso-Peso)/T)) && Check==1
                    MD=md;
                    Peso=peso;
                    Barras=barras;
                    Nodos=nodos;
                    
                    % Se registra peso de la solución actual
                    if TodosPesos(size(TodosPesos,1),1)~=Peso
                        TodosPesos(size(TodosPesos,1)+1,1)=Peso;
                    end
                end
            end
        end
    end
    % Se actualiza la temperatura del proceso
    T=Alfa*T;
end

% Se genera una representación gráfica de la armadura
GraficaArmadura(Posi,Barras,Nodos)