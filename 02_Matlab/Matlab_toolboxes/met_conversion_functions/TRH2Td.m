function Td_degC=TRH2Td(T_degC,RH_perc)
%% function to calculate dew point temperature [degC] from temperature [degC] and relative humidity [%] (following Buck (1981))

% constants
b = [17.368; 17.966];
c = [238.88; 247.15];

gamma=NaN(size(T_degC));
Td_degC=NaN(size(T_degC));

% gamma
gamma(T_degC>=0.) = log(RH_perc(T_degC>=0.)./100.) + b(1).*T_degC(T_degC>=0.)./(c(1)+T_degC(T_degC>=0.));
gamma(T_degC< 0.) = log(RH_perc(T_degC< 0.)./100.) + b(2).*T_degC(T_degC< 0.)./(c(2)+T_degC(T_degC< 0.));

% TD
Td_degC(T_degC>=0.) = c(1).*gamma(T_degC>=0.)./(b(1)-gamma(T_degC>=0.));
Td_degC(T_degC< 0.) = c(2).*gamma(T_degC< 0.)./(b(2)-gamma(T_degC< 0.));
