function q_gkg=Td2q(Td_degC,p_hPa,T_degC)
%% calculates the specific humidity q_gkg [g/kg] from the dewpoint temperature (Td_degC) at give air pressure (p_hPa) applying the The Clausius–Clapeyron equation for vector of Td

%constants
a = 6.1121;
b = [17.368; 17.966];
c = [238.88; 247.15];
d = 621.97;

%calculate vp_hPa
vp_hPa(length(Td_degC),1) = 0.;
vp_hPa(T_degC>=0) = a.*exp(b(1).*Td_degC(T_degC>=0) ./ (Td_degC(T_degC>=0)+c(1)));
vp_hPa(T_degC< 0) = a.*exp(b(2).*Td_degC(T_degC< 0) ./ (Td_degC(T_degC< 0)+c(2)));

%calculate q_gkg
q_gkg = d.*vp_hPa./p_hPa;