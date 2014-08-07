function Dhv_naam(stage),
%  Dhv_naam(stage),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if stage == 1,
  OK = Dis_zoom;
  if OK,
    Dhv_naam(3);
    hh = Ma_naam(Dhv_defa(2.2));
    pox = Dhv_norm(gca,'position');
    poh = Dhv_norm(hh,'position');
    plek = [pox(1)+poh(1)*pox(3)-.1 pox(2)+poh(2)*pox(2) .2 Gch];
    Uiedhv(Gct,'Dhv_naam(2)',Dhv_defa(2.2),plek,hh);
  end;

elseif stage ==2,
  ht = get(gco,'userdata');
  txt = get(gco,'string');
  delete(gco);
  set(ht,'string',[txt ' ' date]);
  Set_zoom;

elseif stage ==3,
  h = get(gca,'children');
  for tel = length(h):-1:1,
    if strcmp(get(h(tel),'type'),'text'),
      if strcmp(get(h(tel),'userdata'),'usernaam'),
        delete(h(tel));
      end;
    end;
  end;
end


