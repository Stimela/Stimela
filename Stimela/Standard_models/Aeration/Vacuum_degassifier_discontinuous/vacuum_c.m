function  vacuum_c(vacuum_file);
%   vacuum_c(vacuum_file)
%   Parameter conversion for vacuum
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vacuum_fileEcht = chckFile(vacuum_file);
if ~vacuum_fileEcht
    error(['Cannot find parameterfile ''' vacuum_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(vacuum_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
P.Height = Pr1;
P.Diam = Pr2;
P.PercOpen = Pr3;
P.Percl    = Pr4;
P.Tvac     = Pr5;
P.Tpump    = Pr6;
P.k2       = Pr7;
P.NumCel   = Pr8;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(vacuum_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
