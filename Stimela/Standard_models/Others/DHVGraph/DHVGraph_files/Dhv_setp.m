function Dhv_setp(flag);
%  Dhv_setp(flag);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

if flag ==1 | flag ==2,
  hs = get(gco,'userdata');
  val = get(gco,'value');
  str = get(gco,'string');
  set(hs,'string',Delspace(str(val,:)));
elseif flag ==3,
  val = get(gco,'value');
  hs = get(gcf,'userdata');
  if val == 1,
    set(hs(5),'visible','off');
    set(hs(7),'visible','off');
    set(hs(8),'visible','off');
    set(hs(9),'visible','off');
  else
    set(hs(5),'visible','on');
    set(hs(7),'visible','on');
    set(hs(8),'visible','on');
    set(hs(9),'visible','on');
  end

elseif flag ==4,
  set(gco,'userdata',1);
end




