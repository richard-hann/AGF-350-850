function q_gkg=Td2q(Td_degC,p_hPa,T_degC)
%% function q_gkg=Td2q(Td_degC,p_hPa,T_degC)
% calculates the specific humidity q_gkg [g/kg] from the dewpoint 
% temperature (Td_degC), at give air pressure (p_hPa) applying the The 
% Clausius Clapeyron equation for vector of Td
% Td is with respect ot ice/liquid water depending on T_degC

% repeat T_degC if necessary
if length(T_degC)==1
    T_degC = repmat(T_degC,size(Td_degC));
elseif size(T_degC)~=size(Td_degC);
    error('size of T_degC does not match size Td_degC');
end

%constants
a = 6.1121;
b = [17.368; 17.966];
c = [238.88; 247.15];
d = 621.97;

%calculate vp_hPa
vp_hPa = NaN(length(Td_degC),1);
vp_hPa(T_degC>=0) = a.*exp(b(1).*Td_degC(T_degC>=0) ./ (Td_degC(T_degC>=0)+c(1)));
vp_hPa(T_degC< 0) = a.*exp(b(2).*Td_degC(T_degC< 0) ./ (Td_degC(T_degC< 0)+c(2)));

%calculate q_gkg
q_gkg = d.*vp_hPa./p_hPa;


