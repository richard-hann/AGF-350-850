function RH_perc=Td2RH(Td_degC,T_degC)
%% function RH_perc=Td2RH(Td_degC,T_degC)
% function to calculate relative humidity [%] from temperature [degC] and 
% dew point temperature [degC] 
% (following Buck (1981))
% for temperatures > 0degC Td_degC is the dew point with respect to liquid water
% for temperatures < 0degC Td_degC is the dew point with respect to ice

% constants
b = [17.368; 17.966];
c = [238.88; 247.15];

gamma=zeros(length(T_degC),1);
RH_perc=zeros(length(T_degC),1);


gamma(T_degC>=0.) = b(1).*Td_degC(T_degC>=0.)./(c(1)+Td_degC(T_degC>=0.)); 
gamma(T_degC< 0.) = b(2).*Td_degC(T_degC< 0.)./(c(2)+Td_degC(T_degC< 0.)); 

RH_perc(T_degC>=0) = exp(gamma(T_degC>=0) - b(1).*T_degC(T_degC>=0.)./(c(1)+T_degC(T_degC>=0.))).*100;
RH_perc(T_degC< 0) = exp(gamma(T_degC< 0) - b(2).*T_degC(T_degC< 0.)./(c(2)+T_degC(T_degC<0. ))).*100;
RH_perc(isnan(Td_degC) | isnan(T_degC)) = NaN;