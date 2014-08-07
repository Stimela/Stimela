function DHV_fig(option),
%  DHV_fig(option)
%
%  option: max -> maximale figure print
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95


if strcmp(lower(option),'max')
  set(gcf,'paperposition',[0 0 get(gcf,'papersize')]);
end

