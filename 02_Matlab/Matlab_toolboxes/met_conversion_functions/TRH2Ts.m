function Ts_degC=TRH2Ts(T_degC,RH_perc,p_hPa)
%% function to calculate sonic temperature [degC] from temperature [degC] and relative humidity [%] 

% Td
Td_degC=TRH2Td(T_degC,RH_perc);

% specific humidity
r_gkg=Td2r(Td_degC,p_hPa,T_degC);

% Tv
Ts_degC=(T_degC+273.15).*(1+0.51e-3.*r_gkg)-273.15; % note that r is in g/kg here -> e-3 factor
