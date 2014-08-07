function Uiedset(options,saveobj)
%  Uiedhv(obj,uitvoer,initstr)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if nargin <2,
  saveobj = 0;
end

if options ==1, %
  hs = get(gco,'userdata');
  val = get(gco,'value');
  str = get(gco,'string');
  set(hs,'string',Delspace(str(val,:)));
elseif options ==2,
  hs = get(gco,'userdata');
  if length(hs)>2,
    set(gco,'userdata',hs(3:length(hs)));
  end;
  string = get(gco,'string');
  strmen = Transcod(get(hs(2),'userdata'),1);

  OK =1;
  for tel = 1:size(strmen,1),
    menstr =  Delspace(strmen(tel,:));
    if length(string) == length(menstr),
      if string == menstr,
        OK = 0;
      end;
    end;
  end;

  if OK & length(string),
    if all(size(strmen)),
      strmen = str2mat(string,strmen);
    else
      strmen = string;
    end;
  end;

  userstr = Transcod(strmen,1);

  set(hs(2),'userdata',userstr);

  if saveobj==0,
    delete(hs(1));
  end

end;


