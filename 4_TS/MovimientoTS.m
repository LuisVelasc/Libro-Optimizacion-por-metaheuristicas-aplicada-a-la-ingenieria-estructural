function [x,Posiciones] = MovimientoTS(D,pV,V,x,Tenure,p,TL)
% Se genera una solución de la vecindad de X
n=randi(round(D*pV));               % Número de variables a modificar
Cambios=randi(2,1,n);               % Cambios a realizar
Cambios(Cambios==2)=-1;
Posiciones=unique(randi(D,1,n));    % Variables a modificar

% Se eliminan movimientos tabús
for h=1:size(Posiciones,2)
   for i=1:Tenure
      for j=1:round(p*pV*D)
         if(TL(i,j)==Posiciones(1,h))
            Posiciones(1,h)=0; 
         end
      end
   end
end

if(size(find(Posiciones~=0,2)~=0))
    Posiciones(Posiciones==0)=Posiciones(find(Posiciones~=0,1));
    Posiciones=unique(Posiciones);
    
    i=1;
    m=find(x(1,Posiciones(1,i))==V);

    if(m==1)
        if(Cambios(1,i)~=-1)
            m=m+Cambios(1,i);
        end
    elseif(m==size(V,2))
        if(Cambios(1,i)~=1)
            m=m+Cambios(1,i);
        end
    else
        m=m+Cambios(1,i);
    end

    x(1,Posiciones(1,i))=V(1,m);

end

end

