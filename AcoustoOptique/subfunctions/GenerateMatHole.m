function Mat = GenerateMatHole( f0,fz,nuX,X )

% f0 (en MHz) est la fr�quence de porteuse,  f (en Hz) la fr�quence de modulation de phase

Tmax = 20.1;  % dur�e maximale d'un cycle �l�mentaire (en us)
Fe = 180;     % Fr�quence d'�chantillonnage en MHz

dt = 1e6/fz;  % time step in us

if ( dt  > Tmax ) % si la p�riode de la modulation de phase est plus grande que Tmax --> Manip impossible
   Mat = zeros(size(X));
   return;
end;

N = floor(Tmax/dt);     %   on essaie de se rapprocher au mieux de Tmax
Nech = round(N*dt*Fe);  %   Nombre d'�chantillons effectivement utilis�s

Tot = Nech/Fe; % dur�e totale de la s�quence � r�p�ter 

  if (dt ~= Tot/N)
      d = 999
  end

T = Tot/N; % r�-ajustement de la p�riode
f = 1.0/T; % r�-ajustement de la fr�quence (en MHz)

k = floor(Tot*f0); % nombre de cycles porteuse
 if (f0 ~= k/Tot)
      d = 88888888888
  end
f0 = k/Tot; % r�-ajustement de la fr�quence porteuse

t = (0:Nech-1)/180;         %   Echelle de temps;
        
tT = t'*ones(1,length(X));
tX = nuX*ones(length(t),1)*X/f;

ts0 = sin(2*pi*f0*t)'*ones(1,length(X)); %   porteuse

Mat = sign(ts0).*( sin(2*pi*fz*(tT-tX)) > 0 );


end

