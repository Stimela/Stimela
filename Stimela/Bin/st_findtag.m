function h = st_findtag(figno,tagnaam)
% h = st_findtag(figno,tagnaam)
%    find single handle with given tag
%
% Stimela, 2004

% © Kim van Schagen,

h = findobj(figno,'tag',tagnaam);
if length(h) >1 
   warning(['multiple handles with tag: ' tagnaam])
   h=h(1);
elseif length(h)==0
   error(['tag not found: ' tagnaam])
end


