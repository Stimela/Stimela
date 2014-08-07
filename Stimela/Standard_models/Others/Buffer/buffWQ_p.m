function P = buffWQ_p(buffWQ_file);
%  P = buffWQ_p(buffWQ_file)
%   Parameter initialisation of model buffWQ
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
buffWQ_fileEcht = chckFile(buffWQ_file);
if ~buffWQ_fileEcht
    error(['Cannot find parameterfile ''' buffWQ_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(buffWQ_fileEcht, 'buffWQ');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
