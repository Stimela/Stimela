function P = dubfil_p(dubfil_file);
%  P = dubfil_p(dubfil_file)
%   Parameter initialisation of model dubfil
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
dubfil_fileEcht = chckFile(dubfil_file);
if ~dubfil_fileEcht
    error(['Cannot find parameterfile ''' dubfil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(dubfil_fileEcht, 'dubfil');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;
P.dy1 = P.Lb1/P.NumCel1;
P.dy2 = P.Lb2/P.NumCel2;
P.Diam1 = P.Diam1/1000;
P.Diam2 = P.Diam2/1000;
P.FilPor1 = P.FilPor1/100;
P.FilPor2= P.FilPor2/100;
%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
