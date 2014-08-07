function Dhv_seta(flag,P1,P2)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

if flag ==1,
  if nargin <2
    P1 = 0
  end

  str = get(gco,'string');
  M = eval(str,'[]');
  if size(M,1)*size(M,2)~=1,
    M=P1;
  end
  set(gco,'string',num2str(M));
elseif flag ==2,
  onoff = str2mat('on','off');
  hs=get(gco,'userdata');
  vl=get(gco,'value');
  set(hs(1),'enable',onoff(vl+1,:));
  set(hs(2),'enable',onoff(vl+1,:));
elseif flag ==3,
  set(gco,'value',1);
  set(get(gco,'userdata'),'value',0);
end

