function [Check,Le,B,H,fc,d,Asc,As1,As2,Av,sEApoyo,sECentro] = ComprobacionesAG(Viga,L,rec,BApoyo,Wm,w)
% Esta función determina la validez de la viga y define la longitud 
% donde se colocarán los estribos en el apoyo

% Se llaman los valores de la viga
fc   =Viga(1,2);
H    =Viga(1,3);
B    =Viga(1,4);
nc   =Viga(1,5);
fic  =Viga(1,6)*(2.54/800);
ns1  =Viga(1,7);
fis1 =Viga(1,8)*(2.54/800);
ns2  =Viga(1,9);
fis2 =Viga(1,10)*(2.54/800);
nE   =Viga(1,11);
fiE  =Viga(1,12)*(2.54/800);
sEApoyo=Viga(1,13);
sECentro=Viga(1,14);

% Calculos de apoyo
fcc=0.85*fc;    % Es f''c, MPa
if(fc>28)       % Altura efectiva bloque de compresión, m
    beta1=1.05-fc/140;
else
    beta1=0.85;
end
if(fc>=40)      % Módulo elasticidad concreto, MPa
    Ec=2700*fc^(1/2)+11000;
else
    Ec=4400*fc^(1/2);
end

fy=420;     % Esfuerzo de fluencia del acero, MPa
Es=200000;  % Módulo de elásticidad del acero, MPa

Nu=Es/Ec;   % Relación entre módulos

Asc=nc*pi()/4*(fic)^2;      % Área a compresión, m2
As1=ns1*pi()/4*(fis1)^2;    % Área a tensión superior, m2
As2=ns2*pi()/4*(fis2)^2;    % Área a tensión inferior, m2
Av=2*nE*pi()/4*(fiE)^2;     % Área estribos apoyo, m2

ro=(As1+As2)/(B*H); % Cuantía a tensión
roc=Asc/(B*H); % Cuantía a compresión


sepV = 0.04; % Separación entre armaduras verticales, m
BApoyo = 0.30; % Ancho de los apoyos, m

Yg=(As1*(sepV+fis1/2+fis2/2))/(As1+As2); % Centro de gravedad de las armaduras, m
d=H-rec-fiE-As2/2-Yg; % Es d (peralte efectivo), m
dc=rec+fiE+fic/2; % Es d', m
Le=0; 
Check=1;

% Relación geométrica
if(H/B>6)
    Check=1;
    return
end

% Separación entre refuerzos longitudinales
if((B-2*rec-2*fiE-nc*fic)/(nc-1)<0.04)
    Check=2;
    return
end

if((B-2*rec-2*fiE-ns1*fis1)/(ns1-1)<0.04)
    Check=3;
    return
end

if((B-2*rec-2*fiE-ns2*fis2)/(ns2-1)<0.04)
    Check=4;
    return
end

% Revisión flexión
a=(As1+As2-Asc)*fy/(fcc*B); % Profundidad bloque de compresión
Mflex=1.5*Wm*L^2/8+1.3*(25*H*B)*L^2/8;

% Acero a tensión mínimo
if(As1+As2<(0.22*(fc*10^3)^(1/2)*B*d/(fy*10^3)))
    Check=5;
    return
end

% Acero máximo a tensión
if(As1+As2>0.90*(600*beta1/(600+fy)*fcc*B*d/(fy)+Asc))
    Check=6;
    return
end

% Fluencia del acero a compresión
if(As1+As2-Asc<600*beta1*fcc*B*dc/((600-fy)*fy))
    Check=7;
    return
end

% Momento de rotura
if(Mflex>0.90*((As1+As2-Asc)*fy*(d-a/2)+Asc*fy*(d-dc))*10^3)
    Check=8;
    return
end

% Revisión cortante
Vu=1.5*Wm*L/2-1.5*Wm*(BApoyo/2+d)+1.3*(25*B*H)*L/2-1.3*(25*B*H)*(BApoyo/2+d);
if(ro<0.015)
    Vcr=0.75*(0.2+20*ro)*0.3*(fc*10^3)^(1/2)*B*d;
else
    Vcr=0.75*0.16*(fc*10^3)^(1/2)*B*d;
end
VsR=0.75*Av*fy*(10^3)*d/sEApoyo;

% Vcr máximo
if(Vcr>0.75*(0.47)*(fc*10^3)^(1/2)*B*d)
    Check=9;
    return
end

% Vu máximo
if(Vu>0.75*(0.80)*(fc*10^3)^(1/2)*B*d)
    Check=10;
    return
end

% Separaciones máximas estribos
if(Vu>0.75*(0.47)*(fc*10^3)^(1/2)*B*d)
    if(sEApoyo>0.25*d)
        Check=11;
        return
    end
else
    if(Vu>Vcr)
        if(sEApoyo>0.50*d)
            Check=12;
            return
        end
    end
end

% Resistencia a cortante
if(Vcr+VsR<Vu)
    Check=13;
    return
end

% Se define cambio de separación de estribos
VsRc=0.75*Av*fy*(10^3)*d/sECentro/nE;
Le=(1.5*Wm*L/2+1.3*25*B*H*L/2-Vcr-VsRc)/(1.5*Wm+1.3*25*B*H);

% Comprobaciones de deflexión
AFN=B/2;
BFN=Asc*(Nu-1)+(As1+As2)*Nu;
CFN=-Asc*(Nu-1)*dc-(As1+As2)*Nu*d;
FN=(-BFN+(BFN^2-4*AFN*CFN)^(1/2))/(2*AFN);

Iag=B*FN^3/12+B*FN^3/4+(Nu-1)*Asc*(FN-dc)^2+Nu*(As1+As2)*(FN-d)^2;

% Deflexión elástica
Delas=5*w*L^4/(384*Ec*10^3*Iag);

% Deflexión diferida
Ddifer=2/(1+50*roc)*Delas;

% Deflexión total
if(Delas+Ddifer>L/240)
    Check=14;
    return
end

% Comprobaciones de agrietamiento
fsMax=40000;
fsAcero=(w*L^2/8)*(d-FN)*Nu/Iag;
df=rec+fiE+fis2/2;
Afis=B*(Yg+df)*2/((As1+As2)/min(As1/ns1,As2/ns2));
h1=d-FN;
h2=H-FN;

if(fsMax<fsAcero*(df*Afis)^(1/3)*h2/h1)
    Check=15;
    return
end

Check=0;

% Fin de la función
end

