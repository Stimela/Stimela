function P = invruw_p(invruw_file);
%  P = invruw_p(invruw_file)
%   Parameter initialisation of model invruw
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
invruw_fileEcht = chckFile(invruw_file);
if ~invruw_fileEcht
    error(['Cannot find parameterfile ''' invruw_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(invruw_fileEcht, 'invruw');
  try
    load(invruw_fileEcht,'AdditionalData')
  catch
    AdditionalData = [];
  end
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

U=st_Varia;

j=0;
% oorspronkelijke velden
PF=fieldnames(P);
%nieuwe toevoegen
P.VariabelLoop=[];
for i=1:length(PF)
    if isfield(AdditionalData,[PF{i} 'IsActive'])
        if getfield(AdditionalData,[PF{i} 'IsActive'])==0
            % geen selectie dus altijd waarde 0
            setfield(P,PF{i},0);
        end
    end
  
  PM = getfield(P,PF{i});
  if length(PM)==1
    P.Constant(getfield(U,PF{i})) = PM;
    P.Variabel{getfield(U,PF{i})} = [];
  else
    P.Constant(getfield(U,PF{i}))= NaN;
    P.Variabel{getfield(U,PF{i})} = PM;
    j=j+1;
    P.VariabelLoop(j)=i;
  end
    
end


%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
