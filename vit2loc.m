function [stdt,STLA,STLO]=vit2loc(vitdat,vitlat,vitlon)
% [stdt,STLA,STLO]=vit2loc(vitdat,vitlat,vitlon)
%
% Turns *.vit file location string into a decimal lat/lon
%
% INPUT:
%
% vitdat     A string from the *.vit file with the last known time:
%            e.g. 2018-04-13T00:14:35
% vitlat     A string from the *.vit file with the last known latitude:
%   	     e.g. N33deg35.126mn
% vitlon     A string from the *.vit file with the last known longitude:
%            e.g. E134deg57.367mn
%
% OUTPUT:
%
% stdt        A datetimearray
% STLA        A decimal latitude
% STLO        A decimal longitude
%
% Last modified by fjsimons-at-alum.mit.edu, 05/28/2018

% Replace the T by a space
vitdat(strfind(vitdat,'T'))=32;
stdt=datetime(datestr(vitdat),'TimeZone','UTC');

% Latitude parsing
sv=suf(vitlat,'deg'); sv=str2num(sv(1:length(sv)-2));
pv=pref(vitlat,'deg'); if pv(1)=='S'; ps=-1; else; ps=1; end
pv=ps*str2num(pv(2:end));
STLA=[pv+sv/60];

% Longitude parsing
sv=suf(vitlon,'deg'); sv=str2num(sv(1:length(sv)-2));
pv=pref(vitlon,'deg'); if pv(1)=='W'; ps=-1; else; ps=1; end
pv=ps*str2num(pv(2:end));
STLO=[pv+sv/60];
