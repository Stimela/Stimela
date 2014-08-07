function Dhv_filf(fig_nr,Title,nr);
% used by editboxv.m and editboxh.m

% © Kim van Schagen, 1-Aug-95

dwn = get(fig_nr,'windowbuttondownfcn');
mot = get(fig_nr,'windowbuttonmotionfcn');
up  = get(fig_nr,'windowbuttonupfcn');
key = get(fig_nr,'keypressfcn');


set(fig_nr,'windowbuttondownfcn',['Dhv_chfi(''' Title ''',' num2str(nr) ')%' dwn]);
if length(mot),
  set(fig_nr,'windowbuttonmotionfcn',['%' mot]);
end;
if length(up),
  set(fig_nr,'windowbuttonupfcn',['%' up]);
end
set(fig_nr,'keypressfcn',['Dhv_chfi(''' Title ''',' num2str(nr) ')%' key]);


