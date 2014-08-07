function Dhv_butt(stage)
%  Dhv_butt(stage)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95


hmen = Gcm;

if stage ==1,

  if strcmp(get(hmen,'checked'),'off')
    set(hmen,'checked','on');
    Dhv_butt(2);
  else
    Dhv_butt(3);
    set(hmen,'checked','off');
  end

elseif stage ==2,
  menuh = .05;
  menuw = .1;
  menut = .015;
  menup = 1;

  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'Refresh','Dhv_clea(6)','Butt');
  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'Update','Dhv_mcfg(4);','Butt');
  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'Current','Dhv_chax;','Butt');
  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'Print...','Dhv_prin;','Butt');
  menup = menup-menuh-menut;
  Uidhv([0 menup menuw menuh],'Axis...','Dhv_maxe(1);','Butt');
  menup = menup-menuh-menut;
  Uidhv([0 menup menuw menuh],'Zoom','Dhv_zoom(0);','Butt');
  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'Move','Dhv_move(0);','Butt');
  menup = menup-menuh;
  Uidhv([0 menup menuw menuh],'View','Dhv_view(0);','Butt');


elseif stage ==3,
  h = get(gcf,'children');
  % vinden menu
  telm = 1;
  while telm <= length(h),
    if strcmp(get(h(telm),'type'),'uicontrol'),
      if length(findstr(get(h(telm),'userdata'),'Butt')),
        delete(h(telm));

      end;
    end;
    telm = telm+1;
  end;
end

