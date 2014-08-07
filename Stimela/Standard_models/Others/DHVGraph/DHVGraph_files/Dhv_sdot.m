function Dhv_sdot(stage,P1)
%  Dhv_sdot(stage,P1)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

ag = gca;
fg = gcf;
zb = Gcz;

if stage == 1,
  if all(get(ag,'view') == [0 90]);
    OK = Dis_zoom;
    if OK,
      set(fg,'pointer','crosshair');
      set(fg,'windowbuttondownfcn',['Dhv_sdot(2)']);
      set(fg,'windowbuttonmotionfcn','');
      set(fg,'windowbuttonupfcn','');

      set(Gcq,'label',':Add Dot');

    end;
  end;
elseif stage == 2,

  point = get(ag,'currentpoint');

  ht = line('xdata',point(2,1),'ydata',point(2,2),'zdata',.75,'userdata',['userplot'],...
            'linestyle','.','markersize',Dhv_defa(2.5));

end;




