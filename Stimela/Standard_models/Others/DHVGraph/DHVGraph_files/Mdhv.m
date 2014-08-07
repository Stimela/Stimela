function Mdhv(nos,reset);
%  Mdhv(nos,reset);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin <1,
  nos =1:8;
end

if nargin <2,
  reset = 0;
end

hm = [];
h = get(gcf,'children');
OK = 1;
ax = 0;
% vinden menu
telm = 1;
while telm <= length(h),
  if strcmp(get(h(telm),'type'),'uimenu'),
    if strcmp(get(h(telm),'label'),'&MenuDHV'),

      %oude Mdhv weggooien
      hm = get(h(telm),'children');
      if length(hm)==7,
        delete(h(telm));
      elseif any(ishandle(get(h(telm),'userdata'))==0)
        delete(h(telm));
      else
        hm = hm(8:-1:1);
        OK = 0;
        telm = length(h);
      end
    end;
  elseif strcmp(get(h(telm),'type'),'axes')
    if strcmp(get(h(telm),'visible'),'on'),
      ax = 1;
    end;
  end;
  telm = telm+1;
end;

menub = get(gcf,'menubar');
if (~strcmp(menub,'none')|ax)&OK,

   set(gcf,'windowbuttondownfcn','Mdhv;')
   set(gcf,'windowbuttonmotionfcn','')
   set(gcf,'windowbuttonupfcn','')

   hDHV = Uimdhv(gcf,'&MenuDHV');
   hm(1) = Uimdhv(hDHV,'&Buttons','Dhv_butt(1);');

   hm(2) = Uimdhv(hDHV,'&Lines','Dhv_mdhv(1);','on');
   hl(1) = Uimdhv(hm(2),'&Color','Dhv_colo');
   hl(2) = Uimdhv(hm(2),'&Style','Dhv_styl');
   hl(3) = Uimdhv(hm(2),'&Erase','Dhv_dell(1);','on');
   hl(4) = Uimdhv(hm(2),'&Move','Dhv_movl(1);');
   hl(6) = Uimdhv(hm(2),'Erase&Points','Dhv_delp(1);');
   hl(5) = Uimdhv(hm(2),'Get&Data...','Dhv_data(1);','on');

   hm(3) = Uimdhv(hDHV,'&Axes','Dhv_mdhv(2)');
   ha(3) = Uimdhv(hm(3),'C&onfigure...','Dhv_maxe(1);');
   ha(8) = Uimdhv(hm(3),'C&urrent','Dhv_chax','on');
   ha(1) = Uimdhv(hm(3),'&Clear','Dhv_clea(2);','on');
   ha(2) = Uimdhv(hm(3),'&Erase','Dhv_clea(3);');
   ha(4) = Uimdhv(hm(3),'&Zoom','Dhv_zoom(0);','on');
   ha(5) = Uimdhv(hm(3),'&Move','Dhv_move(0);');
   ha(6) = Uimdhv(hm(3),'&View','Dhv_view(0);');
   ha(7) = Uimdhv(hm(3),'&No action','Dhv_clea(5);');

   hm(4) = Uimdhv(hDHV,'&Figure','Dhv_mdhv(3)');
   hf(5) = Uimdhv(hm(4),'&Save...','Dhv_figl(2);');
   hf(6) = Uimdhv(hm(4),'&Load...','Dhv_figl(1);');
   hf(7) = Uimdhv(hm(4),'&Print...','Dhv_prin;','on');
   hf(9) = Uimdhv(hm(4),'Set Ma&x Fill','DHV_fig(''max'');');
   hf(4) = Uimdhv(hm(4),'&Orientation','Dhv_orie;','on');
   hf(2) = Uimdhv(hm(4),'&White','whitebg(gcf)','on');
   hf(3) = Uimdhv(hm(4),'&Clear','Dhv_clea(1);');
   hf(8) = Uimdhv(hm(4),'&Menubar','Dhv_clea(4);');
   hf(1) = Uimdhv(hm(4),'&Refresh','Dhv_clea(6)','on');

   hm(5) = Uimdhv(hDHV,'Add&Ons','Dhv_mdhv(4)');
   ho(1) = Uimdhv(hm(5),'Date/&Name-tag','Dhv_naam(1)');
   ho(2) = Uimdhv(hm(5),'Era&se-tag','Dhv_naam(3);');
   ho(3) = Uimdhv(hm(5),'&Legend...','Dhv_lege(1);','on');
   ho(4) = Uimdhv(hm(5),'&Colorbar...','Dhv_colb(1);');
   ho(5) = Uimdhv(hm(5),'&Text','Dhv_text(1);','on');
   ho(6) = Uimdhv(hm(5),'&Dot','Dhv_sdot(1);');
   ho(8) = Uimdhv(hm(5),'L&ine','Dhv_line(1);');
   ho(7) = Uimdhv(hm(5),'&Arrow','Dhv_slin(1);');
   ho(9) = Uimdhv(hm(5),'&Free','Dhv_free(1);');
   ho(10) = Uimdhv(hm(5),'&Hatch','Dhv_arce(1);');
   ho(12) = Uimdhv(hm(5),'&Erase','Dhv_dplo(1);','on');

   hm(6) = Uimdhv(hDHV,'&Configure','','on');
   hc(1) = Uimdhv(hm(6),'&Set...','Dhv_mcfg(1)');
   hc(2) = Uimdhv(hm(6),'&Update All','Dhv_mcfg(4);','on');
   hc(3) = Uimdhv(hm(6),'"    &Color','Dhv_mcfg(4.1);');
   hc(4) = Uimdhv(hm(6),'"    &Style','Dhv_mcfg(4.2);');
   hc(6) = Uimdhv(hm(6),'"    &Legend','Dhv_mcfg(4.3);');
   hc(5) = Uimdhv(hm(6),'"    &Arrow','Dhv_mcfg(4.4);');

   hm(7) = Uimdhv(hDHV,'&Plot...',['eval(''delete tempfile.tmp'','' '');diary tempfile.tmp ; whos ; diary off ; Dhv_plot(1);'],'on');
   hm(8) = Uimdhv(hDHV,'&Subplot...','Dhv_subp;');

   hQuote = Uimdhv(gcf,'','Dhv_quot');
   reset = 1;


   set(hDHV,'userdata',[hm(1) ho(5) ho(3) hl(5) hf(7) ho(4) hQuote]);
   % (Gcz Gct Gcl Gcg Gcp Gcc Gcq)
   set(gcf,'menubar','none');

   %standaard staat zoom aan en buttons aan
   Dhv_zoom(0)

end;

if length(hm)&reset,
  for tel = 1:8,
    if ~any(nos==tel),
      set(hm(tel),'enable','off');
    else
      set(hm(tel),'enable','on');
    end

  end
end


