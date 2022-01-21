% calculates the air density [kg m-3] as function 
% of pressure [in hPa] and temperature [in°C]
function[c]=rho_dryair_TC_p(T,p);
metcon

c = 100*p./(R*(T+273.15)/m_dryair);