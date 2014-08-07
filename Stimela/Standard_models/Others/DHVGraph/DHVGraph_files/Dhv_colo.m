function Dhv_colo()
%  Dhv_colo()
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

teller = 0;
col = get(gca,'color');
if length(col) ~= 3,
  col = get(gcf,'color');
end;

color = Dhv_defa(2.1);
linew = Dhv_defa(2.8);
n = size(color,1);

blcol = abs([1 1 1] -col)+all((col==[.5 .5 .5]))*[.5 .5 .5];
% kleur is eigen verantwoordilijkheid!
%for tel = 1:n,
%  if all(col == color(tel,:)),
%    disp('line not visible, color changed');
%    color(tel,:) = blcol;
%  end
%end;

h = get(gca,'children');
for tel = length(h):-1:1,
  if strcmp(get(h(tel),'type'),'line')
    cl = get(h(tel),'color');
    if any(cl ~= blcol),
      color = [blcol;blcol];
    end;
    set(h(tel),'color',color(rem(teller,size(color,1))+1,:));
% alleen bij style !
%    if ~strcmp(get(h(tel),'userdata'),'userplot');
%      set(h(tel),'linewidth',linew(1),'markersize',linew(2));
%    end
    teller = teller+1;
  end;
end;



