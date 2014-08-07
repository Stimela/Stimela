function filenaam=get_pfil(bloknaam)
% get the Stimela parameter file of the specified block
%
% Stimela, 2007

% © Kim van Schagen,


% vervangen van de tekst in voor de mask translate
if iscell(bloknaam)
  for i = 1:length(bloknaam)
    filenaam{i} = locfil(bloknaam{i});
  end
else
  filenaam = locfil(bloknaam);
end

    
function f1 = locfil(bloknaam)
    
  % verwijderen lege karakters
  bloknaam=deblank(bloknaam);
  
try
  T = get_param(bloknaam,'Mask Translate');
  Tinit = findstr(T,'filenaam=''');
  nT = size(T,2);
  Tend = Tinit-1+findstr(T(Tinit:nT),''';');
  f1 = T(Tinit+10:Tend(1)-1);
catch
  f1 = 'NotFound';
end

