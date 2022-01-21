function Tv_degC=TRH2Tv(T_degC,RH_perc,p_hPa)
% Tv_degC = TRH2Tv(T_degC,RH_perc,p_hPa)
%% function to calculate virtual temperature [degC] from temperature [degC] and relative humidity [%] 

% Td
Td_degC=TRH2Td(T_degC,RH_perc);

% specific humidity
r_gkg=Td2r(Td_degC,p_hPa,T_degC);

% Tv
Tv_degC=(T_degC+273.15).*(1+0.61e-3.*r_gkg)-273.15; % note that r is in g/kg here -> e-3 factor
