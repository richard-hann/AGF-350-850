function z_m=p2alt(p_hPa,p0_hPa,T0_degC,z0_m)
% function z_m=p2alt(p_hPa,p0_hPa,T0_degC,z0_m)
% function to convert pressure into altitude based on hypsomatic equation

% constants
R=287.0583;
g=9.81;
T0_K=T0_degC+273.15;

% hypsomatic equation (solved for z)
z_m = z0_m + R.*T0_K./g .* log(p0_hPa./p_hPa);