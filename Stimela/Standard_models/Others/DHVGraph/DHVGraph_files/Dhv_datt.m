%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

eval(['[' get(gco,'string') '] = Dhv_data(2,get(gco,''string''));'], ...
   'error_tempvar = Dhv_data(2,''error_tempvar'');');
delete(get(gco,'userdata'));
delete(gco);
Set_zoom;


