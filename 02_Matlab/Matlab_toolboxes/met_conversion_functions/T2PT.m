function PT_K=T2PT(T_K,varargin)
%% function PT_K=T2PT(T_K,p_hPa) or PT_K=T2PT(T_K,p0_hPa,z,z0)
% function to calculate potential temperature [K] 
% from temperature [K] and pressure [hPa] or altitude


%%
% constants
R_spec=287.058; % [J/(kg*K)]
cp=1003.5;      % [J/(kg*K)]
ps_hPa=1000.;   % [hPa]


%% conversion
if length(varargin)==1 % from pressure vector
    p_hPa=varargin{1};
elseif length(varargin)==3 % from altitude vector
    p0_hPa=varargin{1}; %if length(p0_hPa)~=1, error('p0_hPa is not a scalar'); end
    z_m=varargin{2};
    z0_m=varargin{3};
    p_hPa=alt2p(z_m,p0_hPa,nanmean(T_K,1)-273.15,z0_m);
end
PT_K=T_K.*(ps_hPa./p_hPa).^(R_spec./cp);
