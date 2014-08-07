function Dhv_styl()
%  Dhv_styl()
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

teller = 0;
style = Dhv_defa(2.3);
linew = Dhv_defa(2.8);
lno = linew(1);

fig = gcf;
h = get(gca,'children');
for tel = length(h):-1:1,
  if strcmp(get(h(tel),'type'),'line'),
    st = get(h(tel),'linestyle');
    if ~(strcmp(st,'-') | strcmp(st,'- ') | strcmp(st,' -')),
      style = ['- ' ; '- '];
    end;
    styl = style(rem(teller,size(style,1))+1,:);
    ln = lno;
    if findstr(styl,':'),
      ln = 2*lno;
    end
    if ~strcmp(get(h(tel),'userdata'),'userplot');
      set(h(tel),'linestyle',styl,'linewidth',ln,'markersize',linew(2));
      teller = teller+1;
    end
  end;
end;



