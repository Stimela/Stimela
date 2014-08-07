function h = findTag(figno,tagnaam)
% vinden van handle met opgegeven tag

h = findobj(figno,'tag',tagnaam);
if length(h) >1 
   warning(['meerdere handles met tag: ' tagnaam])
   h=h(1);
elseif length(h)==0
   error(['tag niet gevonden: ' tagnaam])
end


