function Dhv_text(stage,P1)
%  Dhv_text(stage,P1)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

tb = Gct;

if stage == 1 & length(tb),
  if all(get(gca,'view') == [0 90]);
    OK = Dis_zoom;
    if OK,
      set(gcf,'pointer','arrow');
      set(gcf,'windowbuttondownfcn',['Dhv_text(2)']);
      set(gcf,'windowbuttonmotionfcn','');
      set(gcf,'windowbuttonupfcn','');

      set(Gcq,'label',':Add Text');
    end;
  end;
elseif stage == 2 & length(tb),

  point = get(gca,'currentpoint');
  po = get(gca,'position');
  xlim = get(gca,'xlim');
  ylim = get(gca,'ylim');

  ht = text('position',[point(2,1) point(2,2) 1],'units','data',...
          'verticalalignment','baseline','horizontalalignment','left', ...
          'userdata',['userplot'],'fontsize',Dhv_defa(2.4),'clipping','on');
  plek = [po(1)+po(3)*(point(2,1)-xlim(1))/(xlim(2)-xlim(1)) ...
         po(2)+po(4)*(point(2,2)-ylim(1))/(ylim(2)-ylim(1)) .3 Gch];

  Uiedhv(tb,['Dhv_text(3);'],'',plek,ht);

elseif stage ==3 & length(tb),

  he =gco;
  txt = get(he,'string');
  ht = get(he,'userdata');
  delete(he);
  if ishandle(ht)
    if length(txt)
      set(ht,'string',txt);
    else
      delete(ht);
    end
  end

end;




