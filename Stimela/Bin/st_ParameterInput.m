function st_ParameterInput(option,varia1,varia2,varia3)
% st_ParameterInput(option,varia1,varia2,varia3)
%   Functie voor afhandelen gedrag in de ParamterInputFigure
%
% Stimela, 2004

% © Kim van Schagen,

% In UData wordt alles opgeslagen (userdata van deze figuur)
% UData.BlokNaam = Bloknaam
% UData.BlokHandle = Simulnk handle naar blok
% Udata.Filenaam = Filenaam
% Udata.Directory = Directory van het systeem
% UData.handle(1) = FileNAam Handle
% UData.handle(2) = BlokNaam Handle
% UData.modif = Gewijzigd flag
% Udata.edit(:) = Editbox waarden Handles

option = upper(option);

% standaardsubdir voor data
DataDir = st_StimelaDataDir;

% Altijd vanuit de directory waar het model staat!
if ~strcmpi(option,'INIT') && ~strcmpi(option,'BUILD')
  CheckRunDir(gcf);
end


% option switch
switch option

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback van de editvelden
   
case 'WAARDE'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');
  hEdit=UData.edit(varia1);
  
  % check op min en max

  %gewijzigd, dus modif
  UData.modif=1;

  set(Invoer_fig,'UserData',UData)
    
  % Block specific userinterfacing
  bfname = [UData.ParameterName  '_f'];
  if exist(bfname)
    eval([bfname '(''' option ''',varia1);']);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opstarten met opgegeven   
case 'INIT'
   
  BlokNaam=varia1;
  FileNaam=varia2;
  ParameterName=varia3;
      
  st_ParameterInput('build',ParameterName);
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');
  
  %vullen BlokNaam
  UData.BlokNaam=BlokNaam;
  UData.BlokHandle = get_param(BlokNaam,'handle');
  set(UData.handle(2),'String',['Block Name : ' BlokNaam]);

  n=findstr(BlokNaam,'/');
  name = BlokNaam(1:n(1)-1);
  fname = get_param(name,'filename');
  curdir=cd;
  cd(fname(1:end-length(name)-5));% .mdl
  UData.Directory = cd; 
  set(Invoer_fig,'UserData',UData);
  cd(curdir);
  
  % check dir
  CheckRunDir(gcf);
  if ~isdir(DataDir)
    mkdir(DataDir);
  end
  
  % vullen Filenaam
  st_ParameterInput('load',FileNaam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aanmaken figuur en assenstelsel
case 'BUILD'

   ParameterName=varia1;
   
   %load model specific data
   PInfo = feval([ParameterName  '_d']);
   
   UData.nWaarde = size(PInfo,1);               % number of parameters
   nRowsMax = 18;                               % maximum number of rows
   nColumn = ceil(UData.nWaarde / nRowsMax);    % number of columns
   nRows = min(UData.nWaarde, nRowsMax);        % number of rows
    
   % laden model
   st_ParameterInputFigure(nColumn);
   
   Invoer_fig=gcf;
   UData.modif=0;
%%!!   set(Invoer_fig,'windowstyle','modal');

   UData.ParameterName = ParameterName;
   UData.handle(1)=st_findtag(Invoer_fig,'FileNaam');
   UData.handle(2)=st_findtag(Invoer_fig,'BlokNaam');

   
   hEdit = findTag(Invoer_fig,['Edit0']);
   hDescription= findTag(Invoer_fig,['Description0']);
   hUnit= findTag(Invoer_fig,['Unit0']);
   
   %positions
   posEdit = get(hEdit,'Position');
   posDescription = get(hDescription,'Position');
   posUnit = get(hUnit,'Position');
   row = 0;
   col = 1;
   for no = 1:UData.nWaarde
     if row == nRowsMax
       row = 1;
       col = col + 1;
     else
      row = row + 1;
    end
    % copy Edit
    h = copyobj(hEdit,Invoer_fig);
    p = posEdit;
    p(1) = p(1) + (col-1)*1/nColumn;
    p(2) = p(2)-(row-1)/nRows*p(2)*0.9;

    %standaard
    set(h, 'Position',p,'Userdata',PInfo(no),'Tag',['Edit' num2str(no)]);
    
    switch PInfo(no).ControlStyle
      case 'select'
        n=find(strcmp(PInfo(no).DefaultValue,PInfo(no).MaxValue));
        if (length(n)==0)
          n=1;
        end    
        set(h, 'Style','popup', 'String', PInfo(no).MinValue, 'Value', n);
      case 'check'
        set(h, 'Style','Checkbox', 'String', '', 'Value', str2num(PInfo(no).DefaultValue));
      case 'edit'
        set(h, 'string', PInfo(no).DefaultValue);
      case 'text'
        set(h, 'string', ['''' PInfo(no).DefaultValue '''']);
      otherwise
        error('Unknown ControlStyle parameter');
    end
    set(h, 'Callback',['st_ParameterInput(''Waarde'',' num2str(no) ');']);
    UData.edit(no)=h;

    % copy Description
    h = copyobj(hDescription,Invoer_fig);
    p = posDescription;
    p(1) = p(1) + (col-1)*1/nColumn;
    p(2) = p(2)-(row-1)/nRows*p(2)*0.9;
    set(h, 'string', PInfo(no).Description,'Position',p);
    UData.Description(no)=h;

    % copy Unit
    h = copyobj(hUnit,Invoer_fig);
    p = posUnit;
    p(1) = p(1) + (col-1)*1/nColumn;
    p(2) = p(2)-(row-1)/nRows*p(2)*0.9;
    set(h, 'string', PInfo(no).Unit,'Position',p);
    
  end
  
  % opruimen
  delete(hEdit);
  delete(hDescription);
  delete(hUnit);
  
  %initflag
  UData.modif=1;

  set(Invoer_fig,'UserData',UData);
  
  % Block specific userinterfacing
  bfname = [UData.ParameterName  '_f'];
  if exist(bfname)
    eval([bfname '(''' option ''');']);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu New
case 'NEW'

  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  % geen Filenaam
  UData.FileNaam = '';
  set(UData.handle(1),'String','File name: <none>');

  % vullen met InitWaarden
  for i=1:UData.nWaarde
    PInfo = get(UData.edit(i),'UserData')
    FillUI(UData.edit(i),PInfo, PInfo.DefaultValue);
  end

  UData.modif=1;

  set(Invoer_fig,'UserData',UData)

  % Block specific userinterfacing
  bfname = [UData.ParameterName  '_f'];
  if exist(bfname)
    eval([bfname '(''' option ''');']);
  end

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu load
case 'LOAD'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  UData.modif=0;
  
  Fn = 0;
  % is geen filenaam opgegeven?
  if nargin ==1
     [Fn,Pn]=uigetfile([DataDir '*.mat'],['Open parameter file ... ']);
     
     if Fn
       Pn = transDir(Pn);
       if ~strcmpi(fullfile(Pn),DataDir)
         copyfile ([Pn Fn],[DataDir Fn]);
       end
       FileNaam=[DataDir Fn];
     else
       FileNaam=0;
     end

     UData.modif=1;
     
  else
    % check opgegeven Filenaam
    FileNaam=chckFile(varia1);
    if FileNaam
      [Pn,Fn,ext]=Fileprop(FileNaam);
      if ~strcmpi(Pn,DataDir)
         copyfile (FileNaam,[DataDir Fn '.mat']);
         FileNaam = [DataDir Fn '.mat'];
         UData.modif=1;
      end
    end
  end

  % bestaat de Filenaam
  
  if FileNaam
    UData.FileNaam=FileNaam;
    dispFileNaam = FileNaam(length(DataDir)+1:end-4); % alleen de naam zonder .mat!
    set(UData.handle(1),'String',['File Name : ' dispFileNaam]);

    % vullen parameters, onbekende parameters vullen
    % met initwaarden, maar dan zijn wel de gegevens gewijzigd
    load (FileNaam);
    
    if exist('P','var')
      for i=1:UData.nWaarde
        PInfo = get(UData.edit(i),'UserData');
        
        % if field existsupdate
        if isfield(P,PInfo.Name)
          FillUI(UData.edit(i),PInfo, getfield(P,PInfo.Name));
        else
           %default value
           % modif
           UData.modif=1;
           FillUI(UData.edit(i),PInfo, PInfo.DefaultValue);
        end
      end
        
    else
      % modif
      UData.modif=1;
    
      % use default values
      for i=1:UData.nWaarde
        PInfo = get(UData.edit(i),'UserData');
        FillUI(UData.edit(i),PInfo, PInfo.DefaultValue);
      end
    end
     
  end

  set(Invoer_fig,'UserData',UData)

  % Block specific userinterfacing
  bfname = [UData.ParameterName  '_f'];
  if exist(bfname)
    if exist('AdditionalData')
      % Extra data was loaded from same file as P
    else 
      AdditionalData = [];
    end
    eval([bfname '(''' option ''', AdditionalData);']);  
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Save
case 'SAVE'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'Userdata');

  % Heb ik al een FileNaam?  
  if length(UData.FileNaam)~=0
     
     P=[];
     for i=1:UData.nWaarde
       PInfo = get(UData.edit(i),'UserData');
       switch PInfo.ControlStyle
         case 'select'
           n=get(UData.edit(i),'Value');
           P=setfield(P,PInfo.Name,PInfo.MaxValue{n});
         case 'check'
           n=get(UData.edit(i),'Value');
           P=setfield(P,PInfo.Name,n);
         case 'edit'
           P=setfield(P,PInfo.Name,get(UData.edit(i),'String'));
         case 'text'
           P=setfield(P,PInfo.Name,['''' get(UData.edit(i),'String') '''']);
       end  
     end
     FileNaam=UData.FileNaam;
     
     % Block specific userinterfacing
     AdditionalData = [];
     bfname = [UData.ParameterName  '_f'];
     if exist(bfname)
       eval(['AdditionalData = ' bfname '(''' option ''');']);
     end
     
 %	======================AvdBerge 13/03/00 START=====================================     
         
     % Stimela-blokjes die de invoerparameters in bestand bewaren zijn van het type
     % SubSystem en hebben een parameter die OpenFcn heet. In de OpenFcn staat een
     % tekst van de vorm: "filenaam='./blok00_p.mat';st_ParameterInput('init',gcb,filenaam,'blok00');". Als er
     % nog een SubSystem bestaat met een OpenFcn die begint met "filenaam='<FileNaam>"
     % dan is FileNaam al in gebruik, wordt een errormelding gegenereerd en wordt er
     % niet gesaved.
     %	Is de bestandsnaam uniek binnen het model
     errstr = st_UniqName(FileNaam,'filenaam=''','SubSystem','OpenFcn');
     
     %	De bestandsnaam wordt nog niet gebruikt
     if isempty(errstr)
        %	Dat wordt saven geblazen
        save(FileNaam,'P', 'AdditionalData');
        
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
     st_ParameterInput('saveas')
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu SaveAs
case 'SAVEAS'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'UserData');

  % Vraag FileNaam
  Title = ['Save parameter file as ... '];
  [Fn,Pn]=uiputfile([DataDir '*.mat'],Title);
  if Fn ~= 0,
     [Pn,Fn,ext]=Fileprop([Pn Fn]);
     FileNaam=[DataDir Fn '.mat'];

     UData.FileNaam = FileNaam;
     dispFileNaam = FileNaam(length(DataDir)+1:end-4); % alleen de naam zonder .mat!
     set(UData.handle(1),'String',['File Name : ' dispFileNaam]);

     UData.modif=0;
     set(Invoer_fig,'UserData',UData)
     st_ParameterInput('save');
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Exit
case 'EXIT'
  Invoer_fig=gcf;
  UData=get(Invoer_fig,'UserData');
  
  try
     % Is er nog wat gewijzigd?   
     if UData.modif==1
       OK=Questbox('Save changed parameter file?','Close parameter file');
       if OK==1
         % Zoek fileNaam
         if length(UData.FileNaam)~=0
           st_ParameterInput('save');
         else
           st_ParameterInput('saveas');
         end

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

  % Block specific userinterfacing
  AdditionalData = [];
  bfname = [UData.ParameterName  '_f'];
  if exist(bfname)
    eval([bfname '(''' option ''');']);
  end

  % Sluiten die hap.  
  delete(Invoer_fig)

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Help 
case 'HELP'
  % helptoets ingedrukt  
  Invoer_fig=gcf;

  winhelp('Stimela.mdl','StimelaHelp/stimela.hlp');
  figure(Invoer_fig)

end


function FillUI(h,PInfo,Value)
% set uicontrol field depending on PInfo

switch PInfo.ControlStyle
 case 'select'
   n=find(strcmp(Value,PInfo.MaxValue));
   if (length(n)==0)
     n=1;
   end    
   set(h,'Value', n);
 case 'edit'  
   set(h,'String',Value);
 case 'check'
   set(h,'Value', Value);
 case 'text'  
   set(h,'String',Value(2:end-1));
end  

function CheckRunDir(Invoer_fig)
% check if current dir is model dir.
  UData=get(Invoer_fig,'Userdata');
  if ~strcmpi(cd,UData.Directory)
    disp(['Changing current directory to model directory : ''' UData.Directory ''''])
    cd (UData.Directory);
  end

  