function P = vacslp_p(vacslp_file);
%  P = vacslp_p(vacslp_file)
%   Parameter initialisation of model vacslp
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
vacslp_fileEcht = chckFile(vacslp_file);
if ~vacslp_fileEcht
    error(['Cannot find parameterfile ''' vacslp_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(vacslp_fileEcht, 'vacslp');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

P.PercFe  = 0;
P.PercCa  = 0;
P.PercFe = P.PercFe/100;
P.PercCa = P.PercCa/100;

if ~isempty(P.QgTot)
   if P.QgTot == 0;
      P.QgTot = 0.0000001;
   end
end

if ~isempty(P.QgDrag)
   if P.QgDrag == 0;
      P.QgDrag = 0.0000001;
   end
end

if ~isempty(P.QgRec)
   if P.QgRec == 0;
      P.QgRec = 0.0000001;
   end
end


P.QgFresh  = P.QgTot-P.QgRec;
P.QgTot   = P.QgTot/3600;% m3/s
P.QgDrag = P.QgDrag/3600;
P.QgFresh  = P.QgFresh/3600;
P.QgRec   = P.QgRec/3600;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
