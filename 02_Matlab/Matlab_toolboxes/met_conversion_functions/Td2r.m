function r_gkg=Td2r(Td_degC,p_hPa,T_degC)
%% function r_gkg=Td2r(Td_degC,p_hPa,T_degC)
% calculates the mixing ratio r_gkg [g/kg] from the dewpoint temperature 
% (Td_degC) at given air pressure (p_hPa), applying the The Clausius–
% Clapeyron equation for vector of Td
% dew point temperatures are with respect to liquid water and ice depending
% on the air temperature.

%constants
a = 6.1121;
b = [17.368; 17.966];
c = [238.88; 247.15];
d = 621.97;

%calculate vp_hPa
vp_hPa = NaN(size(Td_degC));
vp_hPa(T_degC>=0) = a.*exp(b(1).*Td_degC(T_degC>=0)./(Td_degC(T_degC>=0)+c(1)));
vp_hPa(T_degC< 0) = a.*exp(b(2).*Td_degC(T_degC< 0)./(Td_degC(T_degC< 0)+c(2)));

%calculate r_gkg
r_gkg = d.*vp_hPa./(p_hPa-vp_hPa);