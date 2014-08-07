function [h,b] = Gct(options)
%  h = Gch(dummy)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

if nargin <1,
  options = 1;
end;

if options == 1, % relative
  fg = gcf;
  af = get(fg,'units');
  set(fg,'units','pixels');
  ps = get(fg,'position');
  set(fg,'units',af);

  h = 20/ps(4);
  b = 60/ps(3);
elseif options ==2, % pixels
  h = 20;
  b = 60;
end;
