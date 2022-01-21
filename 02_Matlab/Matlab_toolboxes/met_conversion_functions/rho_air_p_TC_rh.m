% [c]=rho_air_p_TC_rh(p,T,rh)
% calculates the air density [kg m-3] as function 
% of pressure [in hPa], temperature [in�C] and
% relative humidity [in %]
function[c]=rho_air_p_TC_rh(p,T,rh)
addpath ~/Documents/MATLAB/Jochens_functions/
metcon

e=e_sat_TC(T).*rh/100;
TK=T+T0;
c = (m_dryair.*p*100-(m_dryair-m_h2o).*e*100)./(R.*TK);