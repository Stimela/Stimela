function  vlokvo_c(vlokvo_file);
%   vlokvo_c(vlokvo_file)
%   Parameter conversion for vlokvo
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vlokvo_fileEcht = chckFile(vlokvo_file);
if ~vlokvo_fileEcht
    error(['Cannot find parameterfile ''' vlokvo_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(vlokvo_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));
P.Length = Pr1;
P.Surf    = Pr2;
P.G10    = Pr3;
P.Ka     = Pr4;
P.Kb     = Pr5;
P.NumCel = Pr6;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(vlokvo_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
