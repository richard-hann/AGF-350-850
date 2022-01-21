function newmap = bluewhitered(m)
%BLUEWHITERED   Blue, white, and red color map.
%   BLUEWHITERED(M) returns an M-by-3 matrix containing a blue to white
%   to red colormap, with white corresponding to the CAXIS value closest
%   to zero.  This colormap is most useful for images and surface plots
%   with positive and negative values.  BLUEWHITERED, by itself, is the
%   same length as the current colormap.
%
%   Examples:
%   ------------------------------
%   figure
%   imagesc(peaks(250));
%   colormap(bluewhitered(256)), colorbar
%
%   figure
%   imagesc(peaks(250), [0 8])
%   colormap(bluewhitered), colorbar
%
%   figure
%   imagesc(peaks(250), [-6 0])
%   colormap(bluewhitered), colorbar
%
%   figure
%   surf(peaks)
%   colormap(bluewhitered)
%   axis tight
%
%   See also HSV, HOT, COOL, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.


[cmap, lims, ticks, bfncol, ctable] = cptcmap('BlueWhiteOrangeRed');


   m = size(cmap,1);


lims = get(gca, 'CLim');


aa=1;
bb=1;

ma=7;

id11=1:m/2-ma;
% id2=((m/2)+ma+1):m;

id22=((m/2)+ma+1):m;

tt=length(id11);

if lims(1) < 0 && lims(2) <= 0
    newmap = cmap(id11,:); 
elseif lims(1) >= 0 && lims(2) > 0
    newmap = cmap(id22,:);
elseif lims(1) < 0 && lims(2) > 0    
    
    a = abs(lims(1));
    b = abs(lims(2));
    
    if a == b 
            newmap = cmap([id11,id22],:);
    elseif a > b
        f = round(b/a*length(id22));
            newmap = cmap([id11,id22(1:f)],:);
    elseif a < b
        f = round(a/b*length(id11));
            newmap = cmap([id11(length(id22)-f+1:end),id22],:);
    end   
        
            
end
