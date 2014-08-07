function bloknaam=st_findblock(nm,StimelaModel);
% get the block names with the given StimelaTypes
%
% Stimela, 2007

% © Kim van Schagen,

nbl=0;
bloknaam={};

if length(nm)==0
  return
end

% zoeken vanaf de root naar alle blokken!
nm=bdroot(nm);

sfuns = find_system(nm,'BlockType','SubSystem'); %%, 'LookUnderMasks'); %%,'all');
for s=1:length(sfuns)
  % op zoek naar de s-functie met blok 123456_s 
  snm='';

  % zoeken naar blok met systeem
  if strcmp(get_param(sfuns{s},'BlockType'),'SubSystem')
    ini = get_param(sfuns{s},'MaskInitialization');
    n = findstr(ini,'_p(filenaam)');
    if length(n)>0 
      snm = ini(n(1)-6:n(1)-1);
      if strcmp(snm,StimelaModel)
        nbl=nbl+1;
        bloknaam{nbl}=sfuns{s};
      end
    end
  end
end
