function P = bacwa1_p(bacwa1_file);
%  P = bacwa1_p(bacwa1_file)
%   Parameter initialisation of model bacwa1
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
bacwa1_fileEcht = chckFile(bacwa1_file);
if ~bacwa1_fileEcht
    error(['Cannot find parameterfile ''' bacwa1_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(bacwa1_fileEcht, 'bacwa1');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

% all in secs
P.TL  = P.TL*3600;
P.Tsp = P.Tsp*60;
P.Tst = P.Tst*3600;


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
