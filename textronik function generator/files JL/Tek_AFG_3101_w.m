%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Inrterfa�age g�n�rateur AFG3101 Tek
%%%
%%% Input => signal norm ou pas
%%%         + freq d'�chatillonnage (MHz)
%%%         + Temps r�p�tition (s)
%%%         + amplitude PP (V)
%%%
%%% Je fixe la fr�quence ech du g�n� � 30Ms/s
%%%
%%% on peut la changer de m�me que le nom...
%%% limite la tension d'entr�e � 1 V pour l'ampli de puissance Amplifi
%%% Research
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TeK_AFG_3101_w(AFG,s,F_ech,T_rep,Vpp)

nom_onde = 'USER1';
F_ech_gen = 20;

% si le signal est mieux �chanitllonn� que le g�n�, 
% je prends la f_ech du signal
if F_ech_gen<F_ech
    F_ech_gen = F_ech;
end
    
% arr�t de la voie du g�n�rateur
fprintf(AFG, 'OUTP 0');

% �chantillonnage du signal � F_ech_gen
s = resample(s,F_ech_gen,F_ech);
N_points = length(s);
N_tot = T_rep*F_ech_gen*1e6;
if N_points>N_tot
%     error('Le signal est plus long que le temps de r�p�tition');
    N_tot = N_points;
    T_rep_R = N_tot * 1/F_ech_gen * 1e-6;
else
    T_rep_R = T_rep;
end
N_missing = N_tot - N_points;
s = [s zeros(1,N_missing)];
N_points = N_tot;


% Mise en forme des data en 2*8 bits, elles sont sur 14 sinon
s = s - mean(s);
s = s/max(abs(s));
trace=round(s*(2^13-1)+(2^13-1));
trace8bits=zeros(1,2*length(trace));
trace8bits(1:2:end)=floor(trace/2^8);
trace8bits(2:2:end)=trace - floor(trace/2^8)*2^8;


% d�finition de la taille m�moire
fprintf(AFG,(sprintf('DATA:DEF EMEM,%i',N_tot)));

% chargement de la forme d'onde
str_onde = sprintf('DATA:DATA EMEM,#%i%i',length(num2str(length(trace)*2)),length(trace)*2);
% fprintf(AFG,[str_onde trace8bits]);
fwrite(AFG, [str_onde trace8bits], 'uint8');

% place la forme d'onde dans un fichier interne au g�n�
fprintf(AFG,(sprintf('DATA:COPY %s,EMEM',nom_onde)));

% slectionne la forme d'onde pour la source
fprintf(AFG,(sprintf('SOUR:FUNCTION %s',nom_onde)));

% r�gle la fr�quence de r�p�tition
fprintf(AFG,(sprintf('FREQUENCY %dK',1/T_rep_R/1e3)));

% evite d'entr� une amplitude sup�rieure � 1V
if Vpp <= 1
    %r�gle l'amplitude pp de sortie
    fprintf(AFG,(sprintf('SOUR:VOLT:LEV:IMM:AMPL %dVpp',Vpp)));
else
    %fprintf(AFG,(sprintf('SOUR:VOLT:LEV:IMM:AMPL %dVpp',1)));
    warning ('tension d entr�e sup�rieure � 1 V !')
end

% je rallume la voie 
fprintf(AFG,('OUTP 1'));



