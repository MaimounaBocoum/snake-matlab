function [I,X,Z] = Reconstruct(NbX,NbZ,NUX,NUZ,x,z,Datas,SampleRate,durationWaveform,c,pitch)
% all inputs are in SI units

     %   Origin_Z = 10;
        Origin_Z = 20;

        [NBX,NBZ] = meshgrid(NbX,NbZ);
        Nfrequencymodes = length(NUX(:));
        XLambda = (durationWaveform*1e-6)*1e3*c;

            % each line is the exponential for NBz
            % integrale is performed between 2*XLambda and 5*XLambda
            ExpFunc                          =   exp(2*1i*pi*(NUZ(:)*(z-Origin_Z)));
            ExpFunc( : , z <= (1*XLambda+Origin_Z) )    =   0;
            ExpFunc( : , z > (2*XLambda+Origin_Z)  )    =   0;
            
            %imagesc(z,1:Nfrequencymodes,real( ExpFunc) );
            
            % projection of fourrier composants:
            Cnm = conj(diag(ExpFunc*Datas))' ;
               
        DecalZ  =   0*1.4; % ??
        NtF     =   2^10;
        dF = diff(NUX(:)) ;
        dF = min(dF(dF>0));
        Fmax = (NtF/2)*dF;
        dx = 1e-3/abs(2*Fmax) ;
        
% Variables

NtFs = NtF/2+1; % index of 0 in fourier domain
tF = zeros(NtF);
for nbs = 1:Nfrequencymodes
    
    s = exp(2i*pi*DecalZ*NBZ(nbs));
    
    tF( NtFs+NBZ(nbs), NtFs+NBX(nbs) ) = -conj(1j*s*Cnm(nbs));
    tF( NtFs-NBZ(nbs), NtFs-NBX(nbs) ) = -s*1j*Cnm(nbs);
    
end

%        figure(50);
%        set(gcf,'WindowStyle','docked');
%        %imagesc(abs(tF));
%        surf(angle(tF));
%        %surf(abs(tF));
%        title('fourier transform I')
%        xlabel('Ny')
%        ylabel('Nz')
       
I = ifft2(fftshift(tF));
I = I - ones(NtF,1)*I(1,:);
I = ifftshift(I,2);

X = (-NtF/2:(NtF/2-1))*dx;

Z = (0:NtF-1)*durationWaveform*1.54/NtF;
