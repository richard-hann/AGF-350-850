function [WB] = windbarb(varargin)
% function WB = windbarb([ax],X,Y,U,V,[scale,PropName,PropVal,...])

% adapted from: WINDBARBM Project wind barbs onto map axes
%
%  WINDBARB(X,Y,U,V) projects two dimensional wind barbs onto the 
%  current axes. The vector components (U,V) are in units of m/s and
%  are specified at the points (X,Y). It handles winds up to 130 knots (66.8778 m/s).
%  Winds exceeding 130 knots will appear as 130 knots. The direction of the
%  barbs indicates the wind direction with the (towards) North direction 
%  pointing upward (positive Y).
%
%  WINDBARB(ax,X,Y,U,V) uses the specified axes, ax. This functionality is 
%  recommended since axes limits and position have to be set before plotting 
%  to  achieve correct directions. This is necessary as X and Y might have
%  different units and scales. Note that e.g. "datetick" changes the limits
%  per default. Use "datetick('x','keeplimits')" instead. The datetime
%  format is supported for X. 

%  WINDBARB([ax],X,Y,U,V,scale) uses the input s to scale the vectors after 
%  they have been automatically scaled to fit within the axes limits. If 
%  omitted, s = 0.9 is assumed.
%  
%  WINDBARB([ax],X,Y,U,V,[scale],PropName,PropVal,...) uses the 
%  windbarb object properties specified to display the windbarb objects.
%  The properties supported by windbarb are the same as the properties
%  supported by line.
% 
%   
%  MFILE:   windbarb.m
%  MATLAB:  9.5.0 (R2018b)
%  VERSION: 1.0 (1 Feb 2020)
%  AUTHOR:  Stephan Kral
%  CONTACT: stephan.kral@uib.no

% Copyright (c) 2011, Nick
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% 

% input output argument checks
nargoutchk(0,1)
narginchk(4,inf)

% functions
axr = @(z) [nanmin(nanmin(z)),nanmax(nanmax(z))]+[-.1 .1]*diff([nanmin(nanmin(z)),nanmax(nanmax(z))]);

% get input data
if isgraphics(varargin{1},'axes')
    ax = varargin{1};
    xl = ax.XLim;
    vn = 1;
    if isdatetime(varargin{vn+1})
        set(ax,'XRuler',matlab.graphics.axis.decorator.DatetimeRuler,'xlim',xl)
    else 
        set(ax,'XRuler',matlab.graphics.axis.decorator.NumericRuler,'xlim',xl)
    end
    
else
    ax = gca;
    vn = 0;
    if isdatetime(varargin{vn+1})
        set(ax,'XRuler',matlab.graphics.axis.decorator.DatetimeRuler)
    else 
        set(ax,'XRuler',matlab.graphics.axis.decorator.NumericRuler)
    end
    try ax.XLim = axr(varargin{1}); catch, end
    try ax.YLim = axr(varargin{2}); catch, end
end
X = varargin{vn+1};
Y = varargin{vn+2};
U = varargin{vn+3}.*1.943844; % convert from m/s to knots
V = varargin{vn+4}.*1.943844; % convert from m/s to knots
varargin(1:vn+4) = [];

% check input dimensions
if isvector(X) && isvector(Y) && isvector(U) && isvector(V) && ...
        length(X) == length(Y) == length(U) == length(V)
elseif size(Y,2) == 1 && size(Y,1) ~= size(U,1)
    error('Y vector input must have row dimension of u.')

elseif size(X,1) == 1 && size(X,2) ~= size(U,2)
    error('X vector input must have column dimension of u.')

elseif ~isvector(X) && ~isvector(Y) && ~isequal(size(Y),size(X),size(U),size(V))
    error('Inconsistent dimensions for inputs.')
end

%check for scale and wind barb property specification
PropName = {}; %'''color'',''b'''; %default wind barb color is blue.
PropVal = {};
switch length(varargin)
    case 1
        if ischar(varargin{1})
            error('Invalid scale factor.')
        end
        scale  = varargin{1};
        
    case 0
        scale  = .9;
        
    otherwise
        %for an odd number of arguments, the first will be the scale factor
        if rem(length(varargin),2)==1 
            if ischar(varargin{1})
                error('Invalid scale factor.')
            end
            scale  = varargin{1};
            varargin(1) =  [];%nn = 2;
        else
            % for an even number of arguments, no scale factor is specified
            scale = .9;
%             nn = 1;
        end
        for ii = 1:2:length(varargin)%nn:length(varargin)
            if ~ischar(varargin{ii}), error('varargin associated with PropertyName must be a string'); end
            PropName = [PropName,varargin(ii)];
            PropVal = [PropVal,varargin(ii+1)];
        end
        
end

% set color
if isempty(PropName) 
    PropName{1} = 'color';
    PropVal{1} = 'b';
elseif ~ismember('color',lower(PropName))
    PropName{1} = 'color';
    PropVal{1} = 'b';
end

% get wind speed (magnitude) and direction (in polar coordiantes)
[theta,umag] = cart2pol(U,V);
[a,b] = size(umag);

% get scaling factor for aspect ratio
axu = ax.Units;
ax.Units = 'centimeters';
% yscale = diff(ax.YLim) ./ diff(ax.Position([2,4]));         % in y-unit/cm (e.g. m/cm for height axis) THIS IS WRONG!!!
yscale = diff(ax.YLim) ./ ax.Position(4);                       % in y-unit/cm (e.g. m/cm for height axis)
if isdatetime(X)
%     xscale = diff(datenum(ax.XLim)) ./ diff(ax.Position([1,3]));% in x-unit/cm (e.g days/cm for time axis) THIS IS WRONG!!!
    xscale = diff(datenum(ax.XLim)) ./ ax.Position(3);          % in x-unit/cm (e.g days/cm for time axis)
else
%     xscale = diff(ax.XLim) ./ diff(ax.Position([1,3]));         % in x-unit/cm (e.g days/cm for time axis) THIS IS WRONG!!!
    xscale = diff(ax.XLim) ./ ax.Position(3);                   % in x-unit/cm (e.g days/cm for time axis)
end
ax.Units = axu;

%create 18 logical matrices for 18 possible barbs. Non-zero when the barb
%is called for at that gridpoint.
g(:,:,1) = umag > 7.5 & umag <= 47.5;
g(:,:,2) = umag > 17.5 & umag <= 47.5;
g(:,:,3) = umag > 27.5;
g(:,:,4) = (umag > 37.5 & umag <= 47.5) | (umag > 57.5 & umag <= 97.5);
g(:,:,5) = umag > 67.5;
g(:,:,6) = (umag > 77.5 & umag < 97.5) | umag > 107.5;
g(:,:,7) = umag > 87.5 & umag < 97.5 | umag > 117.5;
g(:,:,8) = umag > 127.5;
g(:,:,9) = (umag > 2.5 & umag <= 7.5) | (umag > 12.5 & umag <= 17.5);
g(:,:,10) = umag > 22.5 & umag <= 27.5;
g(:,:,11) = (umag > 32.5 & umag <= 37.5) | (umag > 52.5 & umag <= 57.5);
g(:,:,12) = (umag > 42.5 & umag <= 47.5) | (umag > 62.5 & umag <= 67.5);
g(:,:,13) = (umag > 72.5 & umag <= 77.5) | (umag > 102.5 & umag <= 107.5); 
g(:,:,14) = (umag > 82.5 & umag <= 87.5) | (umag > 112.5 & umag <= 117.5);
g(:,:,15) = (umag > 92.5 & umag <= 97.5) | (umag > 122.5 & umag <= 127.5);
g(:,:,16) = umag > 47.5;
g(:,:,17) = umag > 97.5;
g(:,:,18) = true(a,b);


%position of each barb relative to grid point: [x0 y0; x1 y1]
c(:,:,1) = [-1 0;-1.125 .325];
c(:,:,2) = [-.875 0; -1 .325];
c(:,:,3) = [-.75 0; -.875 .325];
c(:,:,4) = [-.625 0; -.75 .325];
c(:,:,5) = [-.5 0; -.625 .325];
c(:,:,6) = [-.375 0; -.5 .325];
c(:,:,7) = [-.25 0; -.375 .325];
c(:,:,8) = [-.125 0; -.25 .325];
c(:,:,9) = [-.875 0; -.9375 .1625];
c(:,:,10) = [-.75 0; -.8125 .1625];
c(:,:,11) = [-.625 0; -.6875 .1625];
c(:,:,12) = [-.5 0; -.5625 .1625];
c(:,:,13) = [-.3750 0; -.4375 .1625];
c(:,:,14) = [-.25 0; -.3125 .1625];
c(:,:,15) = [-.125 0; -.1875 .1625];
c(:,:,16) = [-1 0; -.875 .325];
c(:,:,17) = [-.75 0; -.625 .325];
c(:,:,18) = [0 0; -1 0];


%draw the barbs
WB = gobjects(0);
for nn = 1:18
    dummy = reshape(g(:,:,nn),1,a*b);
    count = sum(dummy); % number of barbs to draw
    if count == 0
        continue
    end
    
    %rotation operations
    x1 = c(1,1,nn)*cos(theta)-c(1,2,nn)*sin(theta);
    y1 = c(1,1,nn)*sin(theta)+c(1,2,nn)*cos(theta);
    x2 = c(2,1,nn)*cos(theta)-c(2,2,nn)*sin(theta);
    y2 = c(2,1,nn)*sin(theta)+c(2,2,nn)*cos(theta);
    
    % scaling
    if isdatetime(X)
        x1 = datetime(x1*xscale*scale+datenum(X),'ConvertFrom','datenum');
        x2 = datetime(x2*xscale*scale+datenum(X),'ConvertFrom','datenum');
    else
        x1 = x1*xscale*scale+X;
        x2 = x2*xscale*scale+X;
    end
    y1 = y1*yscale*scale+Y;
    y2 = y2*yscale*scale+Y;
    
    % reshape
    x = [reshape(x1(dummy),1,count);reshape(x2(dummy),1,count)];
    y = [reshape(y1(dummy),1,count);reshape(y2(dummy),1,count)];
    
    % plot
    wb = line(ax,x,y);
    
    % set line properties
    for pp = 1:length(PropName)
        set(wb,PropName{pp},PropVal{pp})
    end
    
    % gather line object handles for output
    WB = [WB;wb(:)];
end
