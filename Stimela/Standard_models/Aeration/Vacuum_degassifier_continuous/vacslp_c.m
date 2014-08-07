function  vacslp_c(vacslp_file);
%   vacslp_c(vacslp_file)
%   Parameter conversion for vacslp
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vacslp_fileEcht = chckFile(vacslp_file);
if ~vacslp_fileEcht
    error(['Cannot find parameterfile ''' vacslp_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(vacslp_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
P.Height = Pr1;
P.Diam = Pr2;
P.QgTot = Pr3;
P.QgDrag = Pr4;
P.QgRec   = Pr5;
P.k2      = Pr6;
P.NumCel  = Pr7;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(vacslp_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
