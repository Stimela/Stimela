function verwrk_f(option,varia1,varia2)
% initialiseren parameter file
% voor verwrk

% start hier je invul applicatie op
% zorg ervoor dat hij de gegevens wegschrijft in verwrk_file
% of laat je applicatie deze naam wijzigen met
% set_pfil(verwrk_naam,[path] filenaam)

% parameters Deze volgorde onthouden voor verwrk_p.m

InitWaarden = [ '[]'
   '[]'
   '[]'
   '[]'
   '[]'
   '[]'
   '[]'
   '[]'
   '[]'];
nWaarde = 1;


% In UData wordt alles opgeslagen (userdata van deze figuur)
% UData.BlokNaam = Bloknaam
% Udata.Filenaam = Filenaam
% UData.handle(1) = FileNAam Handle
% UData.handle(2) = BlokNaam Handle
% UData.modif = Gewijzigd flag
% Udata.edit(1:9) = Editbox waarden Handles


% option switch
switch option

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback van de editvelden
   
case 'waarde1'
   UData.modif = 1
case 'waarde2'
   UData.modif = 1
case 'waarde3'
   UData.modif = 1
case 'waarde4'
   UData.modif = 1
case 'waarde5'
   UData.modif = 1
case 'waarde6'
   UData.modif = 1
case 'waarde7'
   UData.modif = 1
case 'waarde8'
   UData.modif = 1
case 'waarde9'
   UData.modif = 1
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opstarten met opgegeven verwrk-gegevens-naam   
case 'init'
   
  verwrk_f('build');
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  BlokNaam=varia1;
  FileNaam=varia2;
  
  %vullen BlokNaam
  UData.BlokNaam=BlokNaam;
  set(UData.handle(2),'String',StringBuilderCommon('dbname1', BlokNaam));
  set(Invoer_fig,'UserData',UData);

  % vullen Filenaam
  verwrk_f('load',FileNaam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aanmaken figuur en assenstelsel
case 'build'
   
   % laden model
   verwrk_u;
   Invoer_fig=gcf;
   UData.modif=0;
   set(Invoer_fig,'windowstyle','modal');
   set(Invoer_fig,'userdata',UData);
   
    
  UData.handle(1)=findTag(Invoer_fig,'FileNaam');
  UData.handle(2)=findTag(Invoer_fig,'BlokNaam');

  for no = 1:nWaarde
    UData.edit(no)=findTag(Invoer_fig,['Edit' num2str(no)]);
  end

  %initflag
  UData.modif=1;

  set(Invoer_fig,'UserData',UData);
  verwrk_f('update');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update bij wijzigingen waarden
% hier is check van ivoer of plotten van invoer mogelijk
case 'update'
   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Bestand | Nieuw verwrk
% Aanroep routine voor starten van nieuw verwrk
case 'new'

  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  % geen Filenaam
  UData.FileNaam = '';
  set(UData.handle(1),'String','File name: <none>');

  % vullen met InitWaarden
  for i=1:nWaarde
    set(UData.edit(i),'String',InitWaarden(i,:));
  end

  UData.modif=1;

  set(Invoer_fig,'UserData',UData)

  %update
  verwrk_f('update');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Bestand | laad verwrk
% Aanroep routine voor laden van verwrk gegevens
case 'load'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  F = 0;
  % is geen filenaam opgegeven?
  if nargin ==1
     [F,P]=uigetfile('*.mat',['Open parameter file ... ']);
     
     if F
       P = transDir(P);
       FileNaam=[P F];
     else
       FileNaam=0;
     end
     
  else
    % check opgegeven Filenaam
    FileNaam=chckFile(varia1);
    UData.modif=1;
  end

  % bestaat de Filenaam
  
  if FileNaam
    UData.FileNaam=FileNaam;
    set(UData.handle(1),'String',StringBuilderCommon('dfname1', FileNaam));

    % niets gewijzigd
    UData.modif=0;

    % vullen parameters, onbekende parameters vullen
    % met initwaarden, maar dan zijn wel de gegevens gewijzigd
    load (FileNaam);
    for i=1:nWaarde
      if exist(['Pr' num2str(i)])
        P=eval(['Pr' num2str(i)]);
      else
        P=InitWaarden(i,:);
        UData.modif=1;
      end
      
      if isstr(P);
        set(UData.edit(i),'String',P);
      else
        set(UData.edit(i),'String',InitWaarden(i,:));
        UData.modif=1;
      end
    end
  end

  set(Invoer_fig,'UserData',UData)
  %update
  verwrk_f('update')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Bestand | bewaar verwrk
% Aanroep routine voor bewaren van verwrk gegevens
case 'save'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  % Heb ik al een FileNaam?  
  if length(UData.FileNaam)~=0
     for tel=1:nWaarde
       str=['Pr' num2str(tel) ' = get(UData.edit(tel),''string'');'];
       eval(str);
     end
     for tel=nWaarde+1:9
       str=['Pr' num2str(tel) ' = [];'];
       eval(str);
     end

     FileNaam=UData.FileNaam;
     
 %	======================AvdBerge 13/03/00 START=====================================     
         
     % Stimela-blokjes die de invoerparameters in bestand bewaren zijn van het type
     % SubSystem en hebben een parameter die OpenFcn heet. In de OpenFcn staat een
     % tekst van de vorm: "filenaam='./enkfil_p.mat';enkfil_f('init',gcb,fil". Als er
     % nog een SubSystem bestaat met een OpenFcn die begint met "filenaam='<FileNaam>"
     % dan is FileNaam al in gebruik, wordt een errormelding gegenereerd en wordt er
     % niet gesaved.
     %	Is de bestandsnaam uniek binnen het model
     errstr = UniqName(FileNaam,'filenaam=''','SubSystem','OpenFcn');
     
     %	De bestandsnaam wordt nog niet gebruikt
     if isempty(errstr)
        %	Dat wordt saven geblazen
        save(FileNaam,'Pr1','Pr2','Pr3','Pr4','Pr5','Pr6','Pr7','Pr8','Pr9');
        
        % Gegevens zijn bewaard
        UData.modif=0;
        
        % gegevens opslaan
        set(Invoer_fig,'UserData',UData)
        
     %	De bestandsnaam is al door een ander SubSystem in gebruik
     else
        %	Genereer een error en meld netjes welke andere blokken de bestandsnaam al gebruiken
        errstr=[errstr 'File "' FileNaam '" already exists. Enter a new file name.'];
        errordlg(errstr, 'Wrong file name');
     end % if
     
%	======================AvdBerge 13/03/00 END=======================================     
  
  else
     % File Save As
     verwrk_f('saveas')
  end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Bestand | bewaar verwrk als
% Aanroep routine voor bewaren van verwrk gegevens met een andere naam
case 'saveas'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'UserData');

  % Vraag FileNaam
  Title = ['Save parameter file as ... '];
  [F,P]=uiputfile('*.mat',Title);
  if F ~= 0,
     P = transDir(P);
     if length(F)<5
        F=[F '.mat'];
     end
     if F(length(F)-3:length(F))~= '.mat'
        F=[F '.mat'];
     end
     FileNaam=[P F];

     UData.FileNaam = FileNaam;
     set(UData.handle(1),'String',['FileNaam: ' deblank(FileNaam)]);

     UData.modif=0;
     set(Invoer_fig,'UserData',UData)
     verwrk_f('save');
  end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Bestand | Afsluiten
% Routine voor het afsluiten van het invoerscherm
case 'exit'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'UserData');
  
  try
     % Is er nog wat gewijzigd?   
     if UData.modif==1
       OK=Questbox('Save changed parameter file?','Close parameter file');
       if OK==1
         % Zoek fileNAam
         verwrk_f('saveas');

         Invoer_fig=gcf;
         UData=get(Invoer_fig,'UserData');
       end
    end

    % is dat ook echt gebeurd?
    if UData.modif==0
      BlokNaam=UData.BlokNaam;
      FileNaam=UData.FileNaam;
      set_pfil(BlokNaam,FileNaam);  
    end
  
  end

  % Sluiten die hap.  
  delete(gcf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Help 
case 'help'
  % helptoets ingedrukt  
  Invoer_fig=gcf;

  winhelp('Stimela.mdl','StimelaHelp/stimela.hlp');
  figure(Invoer_fig)

end

