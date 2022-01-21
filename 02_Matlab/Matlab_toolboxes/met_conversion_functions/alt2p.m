function p_hPa=alt2p(z_m,p0_hPa,T0_degC,z0_m)
% function zp_hPa=alt2p(z_m,p0_hPa,T0_degC,z0_m)
% function to convert altitude to pressure, based on hypsomatic equation
% and standard atmosphere temperature profile for troposphere. 

% constants
R=287.0583;
g=9.81;
T0_K=T0_degC+273.15;
gamma = -6.5e-3; %standard tropospheric lapse rate
if numel(T0_degC)~=numel(z_m)
    T_K = T0_K + (z_m-z0_m).*gamma;
else
    T_K = T0_K;
end
    

% hypsomatic equation (solved for p)
if length(p0_hPa)==1, p0_hPa=repmat(p0_hPa,1,size(T0_K,2));end
p_hPa = repmat(p0_hPa,size(z_m,1),1).*exp(-g.*(repmat(z_m,1,size(T0_K,2))-z0_m)./R./T_K);

%z_m = z0_m + R.*T0_K./g .* log(p0_hPa./p_hPa);