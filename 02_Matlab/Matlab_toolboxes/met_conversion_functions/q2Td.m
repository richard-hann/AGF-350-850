function Td_degC=q2Td(q_gkg,p_hPa,T_degC)
%% function Td_degC=q2Td(q_gkg,p_hPa,T_degC)
% calculates the dewpoint temperature (Td_degC) from the specific humidity 
% q_gkg [g/kg], at give air pressure (p_hPa) applying the The 
% Clausius Clapeyron equation for vector of Td
% Td is with respect ot ice/liquid water depending on T_degC

% repeat T_degC if necessary
if length(T_degC)==1
    T_degC = repmat(T_degC,size(q_gkg));
elseif size(T_degC)~=size(q_gkg)
    error('size of T_degC does not match size q_gkg');
end

%constants
a = 6.1121;
b = [17.368; 17.966];
c = [238.88; 247.15];
d = 621.97;

% calculate vp
% vp_hPa = NaN(size(q_gkg)); 
vp_hPa = q_gkg./d.*p_hPa;

% calculate Td
Td_degC = NaN(size(q_gkg));
Td_degC(T_degC>=0) = (c(1).*1./b(1).*log(vp_hPa(T_degC>=0)./a)) ./ ...
    (1 - 1./b(1).*log(vp_hPa(T_degC>=0)./a));
Td_degC(T_degC< 0) = (c(2).*1./b(2).*log(vp_hPa(T_degC< 0)./a)) ./ ...
    (1 - 1./b(2).*log(vp_hPa(T_degC< 0)./a));
