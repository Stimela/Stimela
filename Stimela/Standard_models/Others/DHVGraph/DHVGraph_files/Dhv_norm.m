function PO1=Dhv_norm(x,P1)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

xu = get(x,'units');
set(x,'units','normalized');
PO1 = get(x,P1);
set(x,'units',xu);


