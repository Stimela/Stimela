function  nitfil_c(nitfil_file);
%   nitfil_c(nitfil_file)
%   Parameter conversion for nitfil
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
nitfil_fileEcht = chckFile(nitfil_file);
if ~nitfil_fileEcht
    error(['Cannot find parameterfile ''' nitfil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(nitfil_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
pr1arr = eval(Pr1);
P.Surf    = num2str(pr1arr(1));
P.Lbed   = num2str(pr1arr(2));
pr2arr = eval(Pr2);
P.Diam   = num2str(pr2arr(1));
P.FilPor = num2str(pr2arr(2));
pr3arr = eval(Pr3);
P.X0_Ns  = num2str(pr3arr(1));
P.X0_Nb  = num2str(pr3arr(2));
%Lwater = Pr4(1);
%nmax   = Pr4(2);
%rhoD   = Pr4(3);
pr4arr = eval(Pr4);
P.MuMax15_Ns=num2str(pr4arr(1));
P.MuMax15_Nb=num2str(pr4arr(2)); %9.0e-6;
pr5arr = eval(Pr5);
P.B_Ns=num2str(pr5arr(1));
P.B_Nb=num2str(pr5arr(2));
pr6arr = eval(Pr6);
P.Y_Ns=num2str(pr6arr(1));
P.Y_Nb=num2str(pr6arr(2));%0.02;
%knh4=Pr6(3);
%kno2=Pr6(4);
pr7arr = eval(Pr7);
P.KsPO4_Ns=num2str(pr7arr(1));
P.KsPO4_Nb=num2str(pr7arr(2));
P.KsO2_Ns=num2str(pr7arr(3));
P.KsO2_Nb=num2str(pr7arr(4)); %0.5;
pr8arr = eval(Pr8);
P.AlfaT_Ns=num2str(pr8arr(1));
P.AlfaT_Nb=num2str(pr8arr(2)); %1.06
P.NumCel = Pr9;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(nitfil_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
