function Dhv_mdhv(flag)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

hms = get(Gcm,'children');
offon = str2mat('off','on');
if flag ==1
  % kinderen van lijnen
  % disabelen als er geen lijnen zijn
  % anders enabelen
%  h = get(gca,'children');
%  tel =0;
%  OK = 0;
%  while tel <length(h),
%    tel = tel+1;
%    if strcmp(get(h(tel),'type'),'line'),
%      OK = 1;
%      tel = length(h);
%    end
%  end;
%  for i=1:length(hms)
%    set(hms(i),'enable',offon(OK+1,:))
%  end

elseif flag ==2
  % assenstelsel

elseif flag ==3
  % figuren
  % check bij menubar no 5
  set(hms(2),'check',offon(strcmp(get(gcf,'menubar'),'figure')+1,:));


elseif flag ==4
  % Addons
  % check bij legenda
  % check bij colorbar
  % check bij naam-tag

end

