function Ps = Kimfigps(PosF)
% uitrekenen positie van figuur

% © Kim van Schagen, 1-Aug-95

titlebr=45; % hoogte titelbar

if length(PosF)==3,
  pl = PosF;
  scr = get(0,'screensize');
  [figs,simba_nr] = figflag('Simba-Control',1);
  ss = 1;
  if figs,
    su = get(simba_nr,'units');
    set(simba_nr,'units','pixels');
    sscr = get(simba_nr,'position');
    set(simba_nr,'units',su);
    ss= (scr(4)-(sscr(4)+titlebr))/scr(4);
  end;
  if pl(3)>pl(1)*pl(2),
    error('invalid subplot definition');
  end
  Ps(4)=ss*(scr(4)/pl(1)-(titlebr+5))/scr(4);
  Ps(3)=(scr(3)/pl(2)-2*5)/scr(3);
  Ps(2)=ss-ceil(pl(3)/pl(2))*ss/pl(1)+5/scr(4);
  Ps(1)=(rem(pl(3)+1,pl(2)))*1/pl(2)+5/scr(3);

  % maar wel ervoor zorgen dayt deze gelijk zijn aan pixels
  PsP = Ps.*[scr(3) scr(4) scr(3) scr(4)];
  PsP(1:2) = ceil(PsP(1:2)); % aan de veilige kant blijven
  PsP(3:4) = floor(PsP(3:4)); % aan de veilige kant blijven
  Ps = PsP./[scr(3) scr(4) scr(3) scr(4)]; % en weer omrekenen

elseif length(PosF) == 4
    Ps = PosF;
else
    error ('illegal position')
end


