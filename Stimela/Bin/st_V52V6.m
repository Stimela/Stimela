function st_V52V6(SimulinkSystemName)
% st_V52V6(SimulinkSystemName)
%   conversion of Stimela 5 models to Stimela 6 models
%
% Stimela, 2004

% Kim van Schagen

     %	blokken
     testblocks = find_system(SimulinkSystemName, 'BlockType','SubSystem');
     %	Haal van deze blokjes de waarde van parameter OpenFcn op
     %	(leeg als het blokje geen parameter OpenFcn heeft)
     bp = get_param(testblocks, 'OpenFcn');
     %	rows is het aantal gevonden SubSystems
     [rows,dummy]=size(testblocks);
     %	Initialisatie: error is leeg
     foundblckstr=[];
     
     %	Onderzoek alle gevonden SubSystems
     for tel=1:rows
        %	bp is van het type cell-structure > omzetten naar string
        bptext=char(bp(tel,:));
        if length(bptext)>length('filenaam')
            if strcmp('filenaam',bptext(1:length('filenaam')))
              % blok gevonden
              disp(testblocks{tel});
              npk = findstr(bptext,';');
              tp = bptext(npk(1)+1:npk(1)+6);
              if strcmp(tp,[10 'st_Pa']) || strcmp(tp,['      '])
                  disp('V6 model');
              elseif ~exist([ tp '_c.m'],'file')
                  disp(['Warning conversion foor blok: ''' testblocks{tel} ''' ( type: ''' tp ''') not found '])
              else
                  disp(['Starting conversion model type:' tp ]);
                  if strcmp(tp, 'bkwash') || strcmp(tp, 'regena')
                    set_param([testblocks{tel} '/Pulse Generator'], 'Period','P.TL', 'PulseWidth','P.Tsp', 'PhaseDelay','P.Tst');
                  end
                  fn = bptext(length('filenaam')+2:npk(1)-1); % filenaam
                  disp(['Convert parameter file : ' fn ]);
                  eval([tp '_c(' fn ')']);
                  disp(['Converting OpenFcn']);
                  S = bptext(1:npk(1));
                  S = [ S 10 'st_ParameterInput(''init'',gcb,filenaam,''' tp ''');'];
                  set_param(testblocks{tel},'OpenFcn',S);
                  disp(['Converting Mask']);
                  S = bptext(1:npk(1));
                  S = [S 10 'errstr = UniqName(filenaam,''filenaam='''''',''SubSystem'',''OpenFcn'');'];
                  S = [S 10 'if errstr, error([errstr ''The filenaam "'' filenaam ''" is already in use. Choose a different filenaam.'']), end'];
                  S = [S 10 'P = ' tp '_p(filenaam);'];
                  S = [S 10 '[B,x0,U]=' tp '_i(filenaam);'];
                  S = [S 10 'V = st_Varia;'];
                  set_param(testblocks{tel},'MaskInitialization',S); 
                  disp('change blocks');

                  % vervangen naderhand
                 
                  SF = find_system(testblocks{tel},'LookUnderMasks','all', 'FindAll','on', 'BlockType','S-Function');
                  set_param(SF,'Parameters','B,x0,U,P'); 
                  
                  MF = find_system(testblocks{tel}, 'LookUnderMasks','all', 'FindAll','on', 'BlockType','Mux');
                  if length(MF)
                    S = get_param(MF,'Inputs');
                    S=strrep(S,'varia','V.Number');
                    S=strrep(S,'Bl(6)','B.Setpoints');
                    set_param(MF,'Inputs',S); 
                  end  
               
                 MF = find_system(testblocks{tel},'LookUnderMasks','all', 'FindAll','on',  'BlockType','Demux');
                  if length(MF)
                    S = get_param(MF,'Outputs');
                    S=strrep(S,'varia','V.Number');
                    S=strrep(S,'Bl(3)','B.Measurements');
                    set_param(MF,'Outputs',S); 
                  end  
                  
              end
          end
      end
  end
 
