function  koofil_c(koofil_file);
%   koofil_c(koofil_file)
%   Parameter conversion for koofil
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
koofil_fileEcht = chckFile(koofil_file);
if ~koofil_fileEcht
    error(['Cannot find parameterfile ''' koofil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(koofil_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
P.Area    = Pr1;
P.Lb     = Pr2;
P.Diam   = Pr3;
P.FilPor = Pr4;
P.n      = Pr5;
P.rhoK   = Pr6;
P.K      = Pr7;
P.M      = Pr8;
P.NumCel = Pr9;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(koofil_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
