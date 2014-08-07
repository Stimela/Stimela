function  dubfil_c(dubfil_file);
%   dubfil_c(dubfil_file)
%   Parameter conversion for dubfil
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
dubfil_fileEcht = chckFile(dubfil_file);
if ~dubfil_fileEcht
    error(['Cannot find parameterfile ''' dubfil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(dubfil_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
P.Surf=Pr1;
P.Ls= Pr2;
Pr3arr = eval(Pr3);
P.Lb1 = num2str(Pr3arr(1));
P.Lb2 = num2str(Pr3arr(2));
Pr4arr = eval(Pr4);
P.Diam1 = num2str(Pr4arr(1));
P.Diam2 = num2str(Pr4arr(2));
Pr5arr = eval(Pr5);
P.FilPor1 = num2str(Pr5arr(1));
P.FilPor2 = num2str(Pr5arr(2));
P.nmax = Pr6;
P.rhoD = Pr7;
P.LaShift = Pr8;
Pr9arr = eval(Pr9);
P.NumCel1 = num2str(Pr9arr(1));
P.NumCel2 = num2str(Pr9arr(2));
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(dubfil_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
