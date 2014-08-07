function set_pfil(bloknaam,filenaam)
% set the Stimela parameter file of the specified block
%
% Stimela, 2007

% © Kim van Schagen,

% verwijderen lege karakters
bloknaam=deblank(bloknaam);
filenaam=deblank(filenaam);


% vervangen van de tekst in voor de mask translate
T = get_param(bloknaam,'Mask Translate');
Tinit = findstr(T,'filenaam=''');
nT = size(T,2);
Tend = Tinit-1+findstr(T(Tinit:nT),''';');
Tm = [T(1:Tinit+9) filenaam T(Tend(1):nT)];
set_param(bloknaam,'Mask Translate',Tm);

% vervangen van de tekst in voor de mask dialoge
T = get_param(bloknaam,'OpenFcn');
Tinit = findstr(T,'filenaam=''');
nT = size(T,2);
Tend = Tinit-1+findstr(T(Tinit:nT),''';');
Tm = [T(1:Tinit+9) filenaam T(Tend(1):nT)];
set_param(bloknaam,'OpenFcn',Tm);

