function OK = Holdfigr(positie)
% poitie = matrix nx4
% returns
% -1  enter
% -2  esc
% nr waarboven gedrukt is

% © Kim van Schagen, 1-Aug-95

h_fig = gcf;
fu = get(h_fig,'units');
set(h_fig,'units','normal');
OK = 0;
h = get(gcf,'userdata');
for tel = 1:length(h),
  if get(h(tel),'value'),
    nr = tel;
  end;
end;
set(gcf,'currentobject',h(nr) )
while ~OK
  figure(h_fig);
  if any(h==gco),
    set(h,'Value',0);
    set(gco,'Value',1)
  end;

  keydown = waitforbuttonpress;
  figure(h_fig);
  if keydown
    char = get(h_fig, 'CurrentCharacter');
    if char == 13,
      OK = -1;
    elseif char == 27,
      OK = -2;
    end;
  else
     pt = get(h_fig, 'CurrentPoint');
     plek = find( (pt(1)>positie(:,1))& ...
                  (pt(1)<(positie(:,1)+positie(:,3)))& ...
                  (pt(2)>positie(:,2))& ...
                  (pt(2)<(positie(:,2)+positie(:,4))) );
     if length(plek),
       OK = plek;
     end
  end;
end;

set(h_fig,'units',fu);

