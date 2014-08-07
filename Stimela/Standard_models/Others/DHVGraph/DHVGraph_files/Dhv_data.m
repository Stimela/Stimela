function [PO1,PO2] = Dhv_data(stage,P1),
%  Dhv_data(stage),
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

ax = gca;
gg = Gcg;

if stage ==1,
  if all(get(ax,'view') == [0 90]),
    OK = Dis_zoom;
    if OK,

      po = Dhv_norm(ax,'position');

      plek = [po(1)+.5*po(3)-.15 po(2)+.5*po(4)-.5*Gch .3 Gch];
      pltxt = plek;
      pltxt(2) = plek(2)+gch;
      hdat = Uitdhv(pltxt,'Data-vars:');
      Uiedhv(gg,'Dhv_datt','x,y',plek,hdat);
    end;
  end;
elseif stage ==2,
  str = P1;

  limx = get(ax,'xlim');
  limy = get(ax,'ylim');

%
  teller=0;
  h = get(ax,'children');
  for tel = length(h):-1:1,
    if strcmp(get(h(tel),'type'),'line');
      x = get(h(tel),'xdata');
      y = get(h(tel),'ydata');
      plek = find(x>=limx(1) & x<=limx(2));
      if (all(y(plek)<=limy(2) & y(plek)>=limy(1))),
        if teller == 0,
          teller = teller+1;
          result(:,1) = x(plek)';
          result(:,teller+1) = y(plek)';
        else
          if length(x(plek)) == length(result(:,1)'),
            if all(x(plek) == result(:,1)'),
              teller = teller +1;
              result(:,teller+1) = y(plek)';
            end;
          end;
        end;
      end;
    end;
  end;

  if nargout ==2,
    [nm1,nm2] = strtok(str,',');
    nm2 = nm2(2:length(nm2));
    if size(result,2)>1,
      x = result(:,1);
      y = result(:,2:size(result,2));
      m = size(y,2);
      n = size(x,1);
      disp([num2str(m) ' lines consisting of ' num2str(n) ...
       ' points saved in x-variable ''' nm1 ''' and y-variable ''' nm2 '''' ]);
    else,
      x = [];
      y = [];
      disp(['no lines inside current axes, variables ''' nm1 ''' and ''' nm2 ''' are empty']);
    end;
  else
    y = [];
    if strcmp(str,'error_tempvar'),
      disp('Error in variable name(s)!, result saved in error_tempvar')
    end
    m = size(result,2)-1;
    n = size(result,1);
    x = result;
    if m<1,
      x = [];
      disp(['no lines inside current axes, variable ''' str ''' is empty']);
    else
      disp([num2str(m) ' lines consisting of ' num2str(n) ...
       ' points saved in variable ''' str '''']);
    end
  end
  PO1 = x;
  PO2 = y;

end


