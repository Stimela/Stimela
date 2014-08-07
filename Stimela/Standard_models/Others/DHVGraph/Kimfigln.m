function Kimfigln()
% zet line visible/invisible
% gebruikt door kimfigm

hm = gcbo

if strcmp(get(hm,'check'),'on')
  set(hm,'check','off')
  us = get(hm,'userdata');
  for i = 1:length(us)
    set(us(i),'visible','off')
  end
else
  set(hm,'check','on')
  us = get(hm,'userdata');
  for i = 1:length(us)
    set(us(i),'visible','on')
  end
end

