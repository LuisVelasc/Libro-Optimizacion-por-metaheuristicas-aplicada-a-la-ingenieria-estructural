function [Posiciones,Simetria,Dy] = Cuadricula(Dx,DyV,Dy)
% Se definen las posiciones de los nodos
Px1=[0,(1:0.5:5),6];
Px2=(1:0.5:5);
Px=horzcat(Px1,Px2);

dy=find(Dy==DyV);

if dy~=1 && dy~=size(DyV,2)
    if rand<0.5
        Dy=DyV(1,dy+1);
    else
        Dy=DyV(1,dy-1);
    end
else
    if dy==1 && rand<0.5
        Dy=DyV(1,dy+1);
    elseif dy==size(DyV,2) && rand<0.5
        Dy=DyV(1,dy-1);
    end
end

Px1=vertcat(Dx*Px1,0*Dy*ones(1,size(Px1,2)));
Px2=vertcat(Dx*Px2,1*Dy*ones(1,size(Px2,2)));

% Matriz que almacena las posiciones de los nodos
Posiciones=(1:1:size(Px,2));
Px=horzcat(Px1,Px2);
Posiciones=transpose(vertcat(Posiciones,Px));

% Se define una matriz para aplicar simetría
A=unique(Posiciones(:,3));
Simetria=[];

for i=1 : size(A,1)
   B=find(Posiciones(:,3)==A(i,1));
   for j=1 : (size(B,1)-1)/2
      Simetria=vertcat(Simetria,[Posiciones(B(j,1),1),...
          Posiciones(max(B)-j+1)]);
   end
end

% Se introducen nodos sin simetria
Simetria=vertcat(Simetria,[setdiff(Posiciones(:,1),Simetria),...
    setdiff(Posiciones(:,1),Simetria)]);
end