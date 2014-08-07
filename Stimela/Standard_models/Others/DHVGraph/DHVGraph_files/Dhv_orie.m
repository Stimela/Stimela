function Dhv_orie(sori)
%  Dhv_orie sori
%  orientatie omwisselen
%  sori [optie] landscape of portrait voor gedefinieerde orientatie
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95


ori1 = get(gcf,'paperorientation')
ppos1 = get(gcf,'paperposition')
spos1 = get(gcf,'position')
scr = get(0,'screensize')

alpha = scr(3)/scr(4);
ppos = [ppos1(2) ppos1(1) ppos1(4) ppos1(3)];

if strcmp(ori1,'landscape'),
  ori = 'portrait';
  ps = [spos1(3)/alpha spos1(4)*alpha];
  spos = [.5*(scr(3)-ps(1)) 0.5*(scr(4)-ps(2)) ps];
else
  ori = 'landscape';
  ps=[spos1(3)*alpha spos1(4)/alpha];
  spos = [.5*(scr(3)-ps(1)) 0.5*(scr(4)-ps(2)) ps];
end

if nargin ==1,
  if strcmp(sori,ori)
    set(gcf,'paperorientation',ori);
    set(gcf,'paperposition',ppos);
    set(gcf,'position',spos);
  end
else
    set(gcf,'paperorientation',ori);
    set(gcf,'paperposition',ppos);
    set(gcf,'position',spos);
end
