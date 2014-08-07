function P = ws2opc_p(ws2opc_file);
%  P = ws2opc_p(ws2opc_file)
%   Parameter initialisation of model ws2opc
%   P   Parameter list
%
% Stimela, 2004

% © Kim van Schagen,

%Check if given file exists
ws2opc_fileEcht = chckFile(ws2opc_file);
if ~ws2opc_fileEcht
    error(['Cannot find parameterfile ''' ws2opc_file ''' .']);
else
  %Get Parameter data (evaluate entries, and limits) and return real data
  P = st_getPdata(ws2opc_fileEcht, 'ws2opc');
end  

%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill parameter list with precalculated parameters
% eg. P.CalData = P.Ex1*P.Ex2;

%%%%%%%%%%%%%%% ws parameters
if evalin('base','~exist(''WSServerTime'',''var'')')
  assignin('base','WSServerTime',-1);
end

WS = evalin('base','WSServerTime');
P.WSStartTime=WS;
assignin('base','WSStimelaTime',P.WSStartTime);  

assignin('base','WSStopSimulation',0);

%%%%%%%%%%%%%%% ws blokken
%tic
% controle van de config.
[P.WSInputNames,P.WSInputValues,P.WSOutputNames,P.WSOutputValues]=GetWSNames;
% altijd zelfde volgorde!!!
[P.WSInputNames,i]=sort(P.WSInputNames);
P.WSInputValues = P.WSInputValues(i);
[P.WSOutputNames,i]=sort(P.WSOutputNames);
P.WSOutputValues = P.WSOutputValues(i);


%tags aanpassen.
setWSToBlock(P.WSInputNames);
setWSFromBlock(P.WSOutputNames);
%toc

if (~isempty(P.WSReplayData))
  % laden van de replaydata
  state = load(P.WSInitState);
  assignin('base','xFinal',state.xFinal); 
      
  [direc,file,ext]=Fileprop(ws2opc_file);
      
  if exist([P.WSReplayData '/' file '_ES.sti'])
  % Versie 2007a functionaliteit
          sti = load([P.WSReplayData '/' file '_ES.sti'],'-mat');
          P.ReplayTime = sti.ws2opcES(1,:);
          for i = 1:P.nInputs
              P.Inputvalues{i}= sti.ws2opcES(i+1,:);
          end
  else
  % downward compatibility;
      for i=1:P.nInputs
      if exist([P.WSReplayData '/' P.Inputs{i} '_EM.sti'])
          sti = load([P.WSReplayData '/'  P.Inputs{i} '_EM.sti'],'-mat');
          P.Inputvalues{i} = sti.wssetcEM(2,:);
          
          if ~isfield(P,'ReplayTime')
          P.ReplayTime = sti.wssetcEM(1,:);
          end
          
      else if exist([P.WSReplayData '/'  P.Inputs{i} '_out.sti'])
          sti = load([P.WSReplayData '/'  P.Inputs{i} '_out.sti'],'-mat');
          
          if (size(sti.wssetqout,1)>2)
              v=st_Varia;
              pars = load(['./StimelaData/' P.Inputs{i} '.mat'],'-mat');
              index = getfield(v,eval(pars.P.VariaName));
              P.Inputvalues{i} = sti.wssetqout(index+1,:);
          else
               
          P.Inputvalues{i} = sti.wssetqout(2,:);
          end
          if ~isfield(P,'ReplayTime')
          P.ReplayTime = sti.wssetqout(1,:);
          end
          end
      end
      end
      end
end

%%%%%%%%%%%%%%%%%%% functies voor aanmaken van in en output 
function setWSToBlock(WSTags)

  pos=[];
  
  nMuxNu = str2num(get_param([gcb '/WSTo/Demux'],'Outputs'))-1;
  % 1 is altijd dezelfde
  
  if nMuxNu<length(WSTags)
    set_param([gcb '/WSTo/Demux'],'Outputs',num2str(length(WSTags)+1));
    for i = nMuxNu+1:length(WSTags)
      add_block([gcb '/WSTo/Goto'],[gcb '/WSTo/' num2str(i)],'TagVisibility','global');
      add_line([gcb '/WSTo'],['Demux/' num2str(i+1)],[num2str(i) '/1']);
    end
  end

  if nMuxNu>length(WSTags)
    for i = length(WSTags)+1:nMuxNu
      delete_line([gcb '/WSTo'],['Demux/' num2str(i+1)],[num2str(i) '/1']);
      delete_block([gcb '/WSTo/' num2str(i)]);
    end
    set_param([gcb '/WSTo/Demux'],'Outputs',num2str(length(WSTags)+1));
  end
  
  for i=1:length(WSTags)
    ct = get_param([gcb '/WSTo/' num2str(i)],'GotoTag');
    if ~strcmp(ct,['WSTo' WSTags{i}])
     set_param([gcb '/WSTo/' num2str(i)],'GotoTag',['WSTo' WSTags{i}])
    end
  end

function setWSFromBlock(WSTags)

  pos=[];
  
  nMuxNu = str2num(get_param([gcb '/WSFrom/Mux'],'Inputs'))-1;
  % 1 is altijd dezelfde
  
  if nMuxNu<length(WSTags)
    set_param([gcb '/WSFrom/Mux'],'Inputs',num2str(length(WSTags)+1));
    for i = nMuxNu+1:length(WSTags)
      add_block([gcb '/WSFrom/From'],[gcb '/WSFrom/' num2str(i)]);
      add_line([gcb '/WSFrom'],[num2str(i) '/1'],['Mux/' num2str(i+1)]);
    end
  end

  if nMuxNu>length(WSTags)
    for i = length(WSTags)+1:nMuxNu
      delete_line([gcb '/WSFrom'],[num2str(i) '/1'],['Mux/' num2str(i+1)]);
      delete_block([gcb '/WSFrom/' num2str(i)]);
    end
    set_param([gcb '/WSFrom/Mux'],'Inputs',num2str(length(WSTags)+1));
  end
  
  for i=1:length(WSTags)
    ct = get_param([gcb '/WSFrom/' num2str(i)],'GotoTag');
    if ~strcmp(ct,['WSFrom' WSTags{i}])
     set_param([gcb '/WSFrom/' num2str(i)],'GotoTag',['WSFrom' WSTags{i}])
    end
  end

%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [InputTags,InputW,OutputTags,OutputW]=GetWSNames()

ModelName=gcs;
gew=0;
nInputs=0;
InputTags={};
InputW=[];
nOutputs=0;
OutputTags={};
OutputW=[];

sfuns = find_system(ModelName,'BlockType','SubSystem'); %%, 'LookUnderMasks'); %%,'all');
for s=1:length(sfuns)
  % op zoek naar de s-functie met blok 123456_s 
  snm='';

  % zoeken naar blok met systeem
  if strcmp(get_param(sfuns{s},'BlockType'),'SubSystem')
    ini = get_param(sfuns{s},'MaskInitialization');
    n = findstr(ini,'_p(filenaam)');
    if length(n)>0 
      snm = ini(n(1)-6:n(1)-1);
    end
  end
  
  switch snm
    case 'wssetq'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nInputs = nInputs+1;
      InputTags{nInputs}=P.WSTag;

      if ~evalin('base',['exist(''' P.WSTag ''',''var'')'])
        assignin('base',P.WSTag,P.Default);
      end
      InputW(nInputs) = evalin('base',P.WSTag);
      
    case 'wssetc'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nInputs = nInputs+1;
      InputTags{nInputs}=P.WSTag;
  
      if ~evalin('base',['exist(''' P.WSTag ''',''var'')'])
        assignin('base',P.WSTag,P.Default);
      end
      InputW(nInputs) = evalin('base',P.WSTag);
      
    case 'wsgetm'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nOutputs = nOutputs+1;
      OutputTags{nOutputs}=P.WSTag;
  
      if ~evalin('base',['exist(''' P.WSTag ''',''var'')'])
        assignin('base',P.WSTag,P.Default);
      end
      OutputW(nOutputs) = evalin('base',P.WSTag);
      
    case 'wsgetq'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nOutputs = nOutputs+1;
      OutputTags{nOutputs}=P.WSTag;
  
      if ~evalin('base',['exist(''' P.WSTag ''',''var'')'])
        assignin('base',P.WSTag,P.Default);
      end
      OutputW(nOutputs) = evalin('base',P.WSTag);
  end
end


