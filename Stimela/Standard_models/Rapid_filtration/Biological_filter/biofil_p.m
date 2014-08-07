function P = biofil_p(biofil_file);
%  P = biofil_p(biofil_file)
%   Parameter initialisation of model biofil
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
biofil_fileEcht = chckFile(biofil_file);
if ~biofil_fileEcht
    error(['Cannot find parameterfile ''' biofil_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(biofil_fileEcht, 'biofil');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

% P.dy     = P.Lbed/P.NumCel;
% P.Diam   = P.Diam/1000;
% P.FilPor = P.FilPor/100;
% %nmax   = nmax/100;
% 
% %Por=Por/100;
% %Diam=Diam/1000;
% 
% P.D1_Ns=0;
% P.D1_Nb=0;
% P.D2_Ns=0;
% P.D2_Nb=0;
% 
% EGV = 80;
% I = 0.165/1000*EGV;
% P.Fi = 10^(-((0.5*sqrt(I))/(1+sqrt(I))-0.2*I));

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
