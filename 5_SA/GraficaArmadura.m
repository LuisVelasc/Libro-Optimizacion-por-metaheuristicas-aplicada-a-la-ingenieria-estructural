function [] = GraficaArmadura(Posiciones,Barras,Nodos)
% Se grafica la solución actúal
close(figure(1));

figure(1)
title('Solución actual')
hold on

% Para escalar ejes X y Y
x0=[-2,max(Posiciones(:,2))+2];
y0=[-1,-1];
plot(x0,y0,('w'))

x0=[0,0];
y0=[-1,0.15*max(Posiciones(:,2))];
plot(x0,y0,('w'))

for i=1: size(Barras,1)
    x=[Nodos(find(Nodos==Barras(i,1),1),2),...
        Nodos(find(Nodos==Barras(i,2),1),2)];
    y=[Nodos(find(Nodos==Barras(i,1),1),3);...
        Nodos(find(Nodos==Barras(i,2),1),3)];
    plot(x,y,'color',[1 0.7 0])       
end

hold off
end

