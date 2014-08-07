function h = Uimdhv(par,opschrift,uitvoer,sep,acc)
%  h = Uimdhv(par,opschrift,uitvoer,sep,acc)
% 
%  Kimtools for figures 1993-1995
% 
 
% © Kim van Schagen, 1-Aug-95 
 
if nargin <5,
  acc = '';
end;
if nargin <4,
  sep = 'off';
end;
if nargin <3,
  uitvoer = '';
end;

h = uimenu(par,'label',opschrift,'Callback',uitvoer, ...
       'separator',sep,'accelerator',acc);


