function P = dhvgrp_p(dhvgrp_file);
%  P = dhvgrp_p(dhvgrp_file)
%   Parameter initialisation of model dhvgrp
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
dhvgrp_fileEcht = chckFile(dhvgrp_file);
if ~dhvgrp_fileEcht
    error(['Cannot find parameterfile ''' dhvgrp_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(dhvgrp_fileEcht, 'dhvgrp');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

A=st_Variabelen;
maxl=0;
nvar=length(A);
for i=1:nvar
  nm{i}=[A(i).LongName, ' [', A(i).Unit, ']'];
  l = length(nm{i});
  if l>maxl, maxl=l; end
end
Names = [];
for i=1:nvar
  str = [nm{i}, ...
    blanks(maxl-length(nm{i}))];
  Names = [Names; str];
end

Opt=[100,0,0,P.ss];

P.name=gcb;
P.Options=Opt;
P.Names=Names;
P.dt =P.dt*P.ss; % timescale relatief aan gekozen periode.

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
