function str = Delspace(strin);

% © Kim van Schagen, 1-Aug-95

[m,n] = size(strin);
if (n==1|m==1)
  str = strin;
  for tel = m*n:-1:1,
    if strin(tel)==' ' | abs(strin(tel)) ==0,
      str(tel) = [];
    else
      break;
    end;
  end;
end;

