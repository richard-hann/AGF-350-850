
function [u,v] = Rotate_uv_components_Arome_Arctic(ur,vr,cordsx,cordsy,longitude)

truelat1 = 77.5; % true latitude
stdlon   = -25;  % standard longitude
cone     = sin(abs(deg2rad(truelat1))); % cone factor

    diffn=stdlon-longitude;
    diffn(diffn>180)=diffn(diffn>180)-360;
    diffn(diffn<-180)=diffn(diffn<-180)+360;
     
 alpha  = deg2rad(diffn).*cone;
 alphan = alpha(cordsx,cordsy);
 
    u = squeeze(ur).*cos(alphan) - squeeze(vr).*sin(alphan);
    v = squeeze(vr).*cos(alphan) + squeeze(ur).*sin(alphan);

