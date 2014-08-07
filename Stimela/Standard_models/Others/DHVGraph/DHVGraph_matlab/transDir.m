function dirnaam = transDir(dirnaam)
% dirnaam = transDir(dirnaam)
% omzetten directory verwijzing naar relatieve verwijzing als dat mogelijk is
% huidige dir:

direc = [cd '\'];

direc = lower(strrep(direc,'\','/'));
dirnm = lower(strrep(dirnaam,'\','/'));

nd=length(direc);
nm=length(dirnm);
if nd<nm
  direc(nd+1:nm)=32*ones(1,nm-nd);
else
  dirnm(nm+1:nd)=32*ones(1,nd-nm);
end

tt = min(find(direc~=dirnm))-1;

if isempty(tt)
  dirnaam = './';
elseif tt>0
  dt=find(direc=='/');
  mt=find(dirnm=='/');

  nb = max(find(mt<=tt));

  restdir = dirnm(mt(nb)+1:nm);

  prevn = length(find(tt<dt));

  if prevn==0
    dirnaam = './';
  else
    dirnaam = '';
  end

  for i = 1:prevn
    dirnaam = [dirnaam '../'];
  end

  dirnaam = [dirnaam restdir];

end

dirnaam = strrep(dirnaam ,'\','/');



