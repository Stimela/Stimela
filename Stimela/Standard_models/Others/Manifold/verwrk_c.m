function  verwrk_c(verwrk_file);
%   verwrk_c(verwrk_file)
%   Parameter conversion for verwrk
%   The file is converted from Stimela V5 to Stimela V6
% 
%   in fact the Pr1..Pr9 values are converted to the P.@@@ parameters
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
verwrk_fileEcht = chckFile(verwrk_file);
if ~verwrk_fileEcht
    error(['Cannot find parameterfile ''' verwrk_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  load(verwrk_fileEcht);
end  

P=[];
%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform data from V5 to V6 style
% eg. P.CalData = Pr1;
% for arrays this more complex
% eg. Pr1E = eval(Pr1); P.E = num2str(Pr1E(1));

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save old Pr, so conversion ca be repeated
save(verwrk_file,'P','Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
