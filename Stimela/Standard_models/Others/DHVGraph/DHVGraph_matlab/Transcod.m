function strmat = Transcod(str,code);

% © Kim van Schagen, 1-Aug-95


isorg = isstr(str);

if nargin <2,
  code =10;
end;

[m,n] = size(str);
nc = length(code);
telm = 1;
telc = 1;
if m==1,
  tel =1;
  while tel<=n-nc+1,
    if all(real(str(tel:tel+nc-1))==code),
      telm = telm+1;
      telc = 1;
      tel = tel + nc;
    else
      strmat(telm,telc) = str(tel);
      telc = telc+1;
      tel = tel+1;
    end;
  end;
  for tel2 = tel:n % rest afmaken
      strmat(telm,telc) = str(tel2);
      telc = telc+1;
  end
  % uit voorzorg, altijd laatste getal afmaken
%  strmat(telm,[])=[];

elseif m > 1,
  strmat = deblank(setstr(str(1,:)));
  for tel = 2:m,
    strmat = [strmat code deblank(setstr(str(tel,:)))];
  end;

else
  strmat = [];
end;


if isstr(str)
  strmat=setstr(strmat);
end


