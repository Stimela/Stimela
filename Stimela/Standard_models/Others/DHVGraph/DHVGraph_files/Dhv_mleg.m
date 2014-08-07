function ha = dhvmleg(texten, opties);
%  ha = dhvmleg(texten,opties);
%
%  ha = handle resulterend assenstelsel
%  texten = matrix met bijbehorende texten
%  opties =  'm' -move 's' -overnemen bekende texten
%
%  bij aanroep zonder argument wordt ie verwijdert
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95


% verwijderen oude versie
  ha = gca;
  fig  = gcf;
  posold = [];

  if nargin < 2
    opties = '';
  end
  
  h = get(fig,'children');
  for tel = 1:length(h),
    if strcmp(get(h(tel),'Type'),'axes'),
      user=get(h(tel),'userdata');
      if length(user) == 4,
        if strcmp(user(1:3),'Leg')
          if (abs(user(4))==ha),
              posold = get(h(tel),'position');
              delete(h(tel));
            end;
          end;
        end;
      end;
    end;
    % of is het actuele assenstelselegenda
    user = get(ha,'userdata');
    if length(user)==4,
      if strcmp(user(1:3),'Leg'),
        posold = get(ha,'position');
        delete(ha)
        if ishandle(real(user(4)))
          set(fig,'currentaxes',real(user(4)));
          ha = real(user(4));
        else
          ha = gca;
        end
      end
    end;


toev = 0;

  hs = get(ha,'children');
  allhs = [];
  for tel = length(hs):-1:1,
    if (strcmp(get(hs(tel),'type'),'line')),
      allhs = [allhs hs(tel)];
    end
  end


upd = ~length(findstr(opties,'u')) | length(posold); % update alleen bij oude legenda
if nargin ~= 0 & upd & length(allhs)  % alleen verwijderen
  
  
  hline = allhs;

  %vullen met lege waarden
  Default = setstr(32*ones(length(hline),1));

  if  length(findstr(opties,'s')) | length(findstr(opties,'u'))
    % als optie = set en als niet alles gedefinieerd

    hleg = Gcl;
    user = get(hleg,'userdata');

    if length(user)>1,
      hold = abs(user(2:1+user(1) ));
      old = Transcod(user(1+user(1)+1:length(user) ),1);
      for tel = 1:user(1),
        plek = find(hold(tel)==hline);
        if length(plek),
          Default(plek,1:length(Delspace(old(tel,:)))) = Delspace(old(tel,:));
        end;
      end;
    end;
  end;

  % wat nog leeg is vullen met texten cyclisch
  telt=1;
  offt = [];
  for tel = 1:length(hline)
    if ~length(Delspace(Default(tel,:)))
      if length(Delspace(texten(telt,:)))
        Default(tel,1:length(Delspace(texten(telt,:)))) = Delspace(texten(telt,:));
      else
        offt =[offt tel];
      end
      telt = rem(telt,size(texten,1))+1;
    end
  end

  % wegooienlege plekken
  Default(offt,:) = [];
  hline(offt) = [];    

  % bewaren gegevens
  Dhv_lege(3.1,hline,Default,allhs)

  % aanmaken legende
  if all(size(Default)),
    ha = Dhv_lege(4,ha,fig,hline,Default);
    if length(posold)
      posnu = get(ha,'position');
      posnew = [posold(1)+(posold(3)-posnu(3))/2 posold(2)+(posold(4)-posnu(4))/2 posnu(3) posnu(4)];
      set(ha,'position',posnew);
    end


    if ( length(findstr(opties,'m')))
      if ( length(Gcz) )
        Dhv_move(0)
        Dhv_move(1,1,ha)

        up = get(gcf,'windowbuttonupfcn');
        set(gcf,'windowbuttondownfcn',up)
      end
    end
  end

end

