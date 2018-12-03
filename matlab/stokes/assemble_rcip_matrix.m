function R = assemble_rcip_matrix(dom, nsub)

star_indices = [17 : 80, 113 : 176];
R = zeros(128, 128, nsub + 1);
T = Tinit16;
W = Winit16;

Ib = eye(192);

[IP,IPW]=IPinit(T,W);
Pbc =blkdiag(eye(16),IP ,IP,eye(32), IP, IP, eye(16));
PWbc=blkdiag(eye(16),IPW,IPW,eye(32), IPW, IPW, eye(16));

for i = 0 : nsub
    
    [z, zp, zpp, jac] = geom_local_init(dom, T, W, nsub, i);
    K = assemble_kernel(z, zp, zpp, jac)- eye(192);   
    
    if i == 0
        R(:,:,1) =  PWbc' *((Ib + K) \ Pbc);
    else
        Kcirc = K;
        Kcirc(star_indices, star_indices) = 0;
        
        FR = Ib;        
        
        FR(star_indices, star_indices) = inv(R(:,:,i));
        R(:,:, i + 1) = PWbc' * ((FR + Kcirc) \ Pbc);

    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function K = assemble_kernel(z,zp,zpp,W)

X = eye(2 * length(z));
K = zeros(size(X));

for i = 1 : 2 * length(z)
    K(:,i) = mubie_gmres(X(:,i),z,zp,zpp,W,[],[]);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z, zp, zpp, jac] = ...
                geom_local_init(dom, T, W, nsub, level)
            
denom=2^(nsub-level)*dom.Npanels;

% construct s
s=[T/2 - 1.5; T/4 - 0.75; T/4 - 0.25; ...
    T/4 + 0.25; T/4 + 0.75; T/2 + 1.5]/denom;
W=[W/2; W/4; W/4; W/4; W/4; W/2]/denom;

z = dom.tau(s);
zp = dom.taup(s);
zpp = dom.taupp(s);

%jac = sqrt(real(zp).^2 + imag(zp).^2);

jac = W;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IP,IPW]=IPinit(T,W)
% *** create prolongation matrices ***
A=ones(16);
AA=ones(32,16);
T2=[T-1;T+1]/2;
W2=[W;W]/2;
for k=2:16
    A(:,k)=A(:,k-1).*T;
    AA(:,k)=AA(:,k-1).*T2;
end
IP=AA/A;
IPW=IP.*(W2*(1./W)');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T=Tinit16
% *** 16-point Gauss-Legendre nodes ***
T=zeros(16,1);
T( 1)=-0.989400934991649932596154173450332627;
T( 2)=-0.944575023073232576077988415534608345;
T( 3)=-0.865631202387831743880467897712393132;
T( 4)=-0.755404408355003033895101194847442268;
T( 5)=-0.617876244402643748446671764048791019;
T( 6)=-0.458016777657227386342419442983577574;
T( 7)=-0.281603550779258913230460501460496106;
T( 8)=-0.095012509837637440185319335424958063;
T( 9)= 0.095012509837637440185319335424958063;
T(10)= 0.281603550779258913230460501460496106;
T(11)= 0.458016777657227386342419442983577574;
T(12)= 0.617876244402643748446671764048791019;
T(13)= 0.755404408355003033895101194847442268;
T(14)= 0.865631202387831743880467897712393132;
T(15)= 0.944575023073232576077988415534608345;
T(16)= 0.989400934991649932596154173450332627;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function W=Winit16
% *** 16-point Gauss-Legendre weights ***
W=zeros(16,1);
W( 1)= 0.027152459411754094851780572456018104;
W( 2)= 0.062253523938647892862843836994377694;
W( 3)= 0.095158511682492784809925107602246226;
W( 4)= 0.124628971255533872052476282192016420;
W( 5)= 0.149595988816576732081501730547478549;
W( 6)= 0.169156519395002538189312079030359962;
W( 7)= 0.182603415044923588866763667969219939;
W( 8)= 0.189450610455068496285396723208283105;
W( 9)= 0.189450610455068496285396723208283105;
W(10)= 0.182603415044923588866763667969219939;
W(11)= 0.169156519395002538189312079030359962;
W(12)= 0.149595988816576732081501730547478549;
W(13)= 0.124628971255533872052476282192016420;
W(14)= 0.095158511682492784809925107602246226;
W(15)= 0.062253523938647892862843836994377694;
W(16)= 0.027152459411754094851780572456018104;

end