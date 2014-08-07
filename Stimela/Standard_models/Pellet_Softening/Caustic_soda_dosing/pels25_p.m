function P = pels25_p(pels25_file);
%  P = pels25_p(pels25_file)
%   Parameter initialisation of model pels25
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
pels25_fileEcht = chckFile(pels25_file);
if ~pels25_fileEcht
    error(['Cannot find parameterfile ''' pels25_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(pels25_fileEcht, 'pels25');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

% om extra berekeningen te voorkomen
P.Radius = sqrt(P.A/pi);
P.TanAngle = tan(P.Angle*pi/180);


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
