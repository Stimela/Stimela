function P = ozoncc_p(ozoncc_file);
%  P = ozoncc_p(ozoncc_file)
%   Parameter initialisation of model ozoncc
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
ozoncc_fileEcht = chckFile(ozoncc_file);
if ~ozoncc_fileEcht
    error(['Cannot find parameterfile ''' ozoncc_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(ozoncc_fileEcht, 'ozoncc');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

% NumCelTot = sum(P.NumCel);
% Areact    = P.Areact.*ones(1,NumCelTot);
% Hreact    = P.Hreact;
% dh        = [];
% for count = 1:size(Hreact,2);
%     dhnew = (Hreact(1,count)*ones(P.NumCel(1,count),1))/P.NumCel(1,count);
%     dh    = cat(1,dh,dhnew);
% end
% %KLO3Init  = P.KLO3Init; % als KLO3Init nodig is in _d wijzigen en hier wijzigen
% KLO3Init  = 1;
% KLO3Init  = [ones(NumCelTot-1,1);KLO3Init]; % gedefinieerd voor meestroom
% db0       = P.db0/1000; % beldiameter van mm naar m
% % F_BrO3init= P.F_BrO3init*(MrO3/MrBrO3); % van ug-BrO3/mg-O3 naar mol-BrO3/mol-O3
% % kCt_BrO3  = P.kCt_BrO3*(MrO3/MrBrO3)*1/60; % van (ug-BrO3/mg-O3)*1/min naar (mol-BrO3/mol-O3)*1/s
% % kEc       = P.kEc*MrO3*1/60; % van (l/mg)*min-1 naar (l/mol)*s-1
% % Ct_lagEc  = P.Ct_lagEc*(1/MrO3)*60; % van (mg-O3/l)*min naar (mol/l)*s
% kCt_BrO3  = P.kCt_BrO3*1/60; % van (ug-BrO3/mg-O3)*1/min naar (ug-BrO3/mg-O3)*1/s
% kEc       = P.kEc*1/60; % van (l/mg-O3)*1/min*1/s naar (l/mg-O3)*1/s*1/s
% Ct_lagEc  = P.Ct_lagEc*60; % van (mg-O3/l)*min naar (mg-O3/l)*s
% 
% % voor ozoncc model
% %P.NumCel     = NumCelTot;
% P.Areact     = Areact';
% P.dh         = dh*ones(1,NumCelTot+1);
% P.Short_Circ = P.Short_Circ/100;        % Short circuit wordt ingegeven als percentage en hier omgezet naar deel 
% P.KLO3Init   = KLO3Init;
% P.db0        = db0;
% % P.F_BrO3init = F_BrO3init;
% P.kCt_BrO3   = kCt_BrO3;
% P.kEc        = kEc;
% P.Ct_lagEc   = Ct_lagEc;

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
