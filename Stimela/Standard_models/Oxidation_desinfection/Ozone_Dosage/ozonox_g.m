function val = ozonox_g(Option, myTagName,filename1,filename2)

if nargin==0
    Option='Init';
end    

AskFile=1;
if nargin==4
    % command-line aanroep
    naamBCfile = Option;
    naamdosagefile = myTagName;
    naamCCfile = filename1;
    plotfile = filename2;
    
    AskFile=0;
    
    Option='Init';
end

%	Goto correct procedure (determined by Option)
switch Option
  


%============================== Initialisation ======================================



%------------------------------
case 'Init'
  %			Entry after first call from Stimela; request filename, then build screen
  
  %%	Initialise storage of user data
  %	Simulation data
  UData.SimData.FileName 				= '';
  UData.SimData.Path 					= '';
  UData.SimData.FileName2               = '';
  UData.SimData.Path2                   = '';
  %	External data
  UData.ExternData.FileName 			= '';
  UData.ExternData.FileNameTxtHndl	    = [];
  UData.ExternData.Path					= '';
  UData.ExternData.PathTxtHndl 			= [];
  UData.ExternData.Column 				= [];
  UData.ExternData.Matrix 				= [];
  % UData.ExternData.Plot				=  0;
  UData.ExternData.LoadButtHndl 		= [];
  UData.ExternData.PlotButtHndl 		= [];
  UData.ExternData.HideButtHndl 		= [];
  UData.ExternData.EditButtHndl 		= [];
  UData.ExternData.NewButtHndl 			= [];
  UData.ExternData.VisOption 			= [];

  if AskFile==1
    VisOption = Radiobox({'Visualize the results for the bubble column (BC)';'Visualize the results for the contact chambers (CC)';'Visualize the results for the BC and the CC'},'Option menu for ozone visualisation',1);
    if VisOption==1
       Choice=['BC'];
    elseif VisOption==2
      Choice=['BCCC'];
    elseif VisOption==3
      Choice=['BCCC'];
    else
    end
   else
      %standaard beiden.
      Choice=['BCCC'];
   end   

   UData.ExternData.VisOption = Choice;
    

  if strcmp(Choice,'BC')==1 | strcmp(Choice,'BCCC')==1
      %	Get filename (simulation data)
      if AskFile==1 
        [F,P]=uigetfile('*.mat','Select the parameter file of the ozone bubble reactor to be visualized');
        if F ~= 0,
         FileName = [transDir(P) F];
         UData.SimData.FileName = F;
         UData.SimData.Path = P;
        end
      else
         UData.SimData.FileName = naamBCfile;
         UData.SimData.Path = [cd '\'];
      end
  
      %=============================START: AvdBerge, 09/09/03=========================================
      % Get ozone dosage module parameters
      if AskFile==1
         [F1,P1]=uigetfile('*.mat','Select the parameter file of the ozone dosage module of the ozone reactor');
         if F1 ~= 0,
            P1 = transDir(P1);
            naamdosagefile=[P1 F1];
         end
      end
      
      %      load (naamdosagefile);       %Het luchtdebiet in Nm3/h (AirFlow), de zuurstof, stikstof en ozon concentratie in de lucht in g/Nm3 (O2air, N2air, O3air)
      P = st_getPdata(naamdosagefile, 'ozodo1');
      %Pr1=eval(Pr1,'error(''Ongeldige Waarde 1'')');
      %Pr2=eval(Pr2,'error(''Ongeldige Waarde 2'')');
      %Pr3=eval(Pr3,'error(''Ongeldige Waarde 3'')');
      %Pr4=eval(Pr4,'error(''Ongeldige Waarde 4'')');

      UData.dosageparam.Qg    = P.AirFlow;
      UData.dosageparam.O2air = P.O2Air;
      UData.dosageparam.N2air = P.N2Air;
      UData.dosageparam.O3air = P.O3Air;
     %=============================STOP : AvdBerge, 09/09/03=========================================

  else
  end
  
  if strcmp(Choice,'CC')==1 | strcmp(Choice,'BCCC')==1
      %	Get filename (simulation data)
      if AskFile==1
        [F2,P2]=uigetfile('*.mat','Select the parameter file of the ozone contact chambers to be visualized');
        if F2 ~= 0,
           FileName = [transDir(P2) F2];
           UData.SimData.FileName2 = F2;
           UData.SimData.Path2 = P2;
        end
      else   
        UData.SimData.FileName2 = naamCCfile;
        UData.SimData.Path2 = [cd '\'];
      end  
          
  else
  end

  
  %%	Create figure

    %	Create figure
    myFigHndl = figure;
    %	Find a unique TagName for the figure
    myTagName = st_UniqTag('Graphozon');
    set(myFigHndl, 'Tag', myTagName);
    % Kim's graph tools    
    Mdhv;
    
    %	Initialise texts with variable string
    subplot(2,2,4)
    set(gca,'Visible','off')
    UData.ExternData.FileNameTxtHndl = text(0.55, -0.03, '');
    UData.ExternData.PathTxtHndl = text(0.55, -0.11, '');
    
    %	Assign to the figure's memory
    set(myFigHndl, 'UserData', UData);
    
    %	Draw figure
    ozonox_g('Fig_Draw', myTagName);
  
  
  %============================== CallBack routines ==================================
  
  
  
  %------------------------------
case 'ExternData_Button_Load'
  %			Button click: load external data from file
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  %	Get filename (external data)
  [F,P] = uigetfile('*.txt;*.mat;*.prn', 'Stimela');
  
  if F ~= 0,
    FileName = [transDir(P) F];
    UData.ExternData.FileName = F;
    UData.ExternData.Path = P;
    
    prompt = cell(2,1);
    prompt(1) = {'Column number of column with reactor heigth data to be plotted'};
    prompt(2) = {'Column number of column with ozone concentration data to be plotted'};
    lines = 1;
    defAns = {'1', '2'};
    ColNums = inputdlg(prompt,'Stimela',lines,defAns);
    
    UData.ExternData.Column = [];
    for cntCN = 1 : length(ColNums)
      coln = str2num(ColNums{cntCN});
      if isnumeric(coln)
        UData.ExternData.Column = [UData.ExternData.Column coln];
      else
        h = warndlg('You entered a non-numeric value for a column number: entry ignored', 'Stimela', 'on');
        dlgOnTop(h);
      end
    end
    
    if isempty(UData.ExternData.Column)
      % Clear external data from UData
      UData.ExternData.FileName		    = '';
      UData.ExternData.Path				= '';
      UData.ExternData.Matrix			= [];
      h = errordlg('All entered column numbers are non-numeric', 'Stimela', 'on');
      dlgOnTop(h);
    end
    
    %	Store UData in the figure's memory
    set(myFigHndl,'UserData',UData);
    %	Load external data to the figure's memory
    ozonox_g('ExternData_Load', myTagName);
  end;		% if F~= 0
  
  
  
  %------------------------------
case 'ExternData_Button_Plot'
  %			Button click: plot external data in same graph as simulation data
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  
  %	Plot external data
  ozonox_g('ExternData_Plot', myTagName);
  
  
  
  %------------------------------
case 'ExternData_Button_Hide'
  %			Button click: remove external data from graph with simulation data
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  
  %	Redraw figure
  ozonox_g('Fig_Draw', myTagName);
  
  
  
  %------------------------------
case 'ExternData_Button_Edit'
  %			Button click: edit external data in file
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  FileName = UData.ExternData.FileName;
  
  if FileName ~= ''
    Extension = lower(FileName(length(FileName)-2:length(FileName)));
    if Extension == 'mat'
      h = errordlg(['*.mat-files can not be edited in Stimela (edit *.mat-files in the Matlab command window)'],...
        'Stimela', 'on'); 
      dlgOnTop(h);
    else
      fid=fopen(FileName);		% open file with external data
      if fid > 0 
        fclose(fid);				%	close file with external data
        
        % Open Notepad with file with external data
        str=['!notepad ',FileName];
        eval((str)); 
        
        %	Find the handle to the figure by means of the unique TagName
        myFigHndl = findobj('Tag', myTagName);
        figure(myFigHndl);		% after Notepad is closed return to the figure
        
        %	Load and plot edited external data (if the filename has changed: too bad, the original file is loaded again)
        ozonox_g('ExternData_Load', myTagName);
        ozonox_g('ExternData_Plot', myTagName);
      else
        h = errordlg(['Can not find file:  ',FileName,' ; or non-existent'],'Stimela', 'on'); 
        dlgOnTop(h);
      end		% if fid > 0
    end		% if Extension == 'mat'
  end		% if FileName ~= ''
  
  
  
  %------------------------------
case 'ExternData_Button_New'
  %			Button click: create new file with external data
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  stdir = stimelaDir;
  str=['!copy ' stdir '\stimela\system\template.txt autocreated.txt'];
  eval(str);
  str=['!notepad ' 'autocreated.txt'];
  eval((str)); 
  
  %------------------------------
case 'SimResults_Button_Export'
  %			Button click: save simulation results to file
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  % Get filter parameters
  simfile = [UData.SimData.Path UData.SimData.FileName];
  load(simfile);
  Pr9=eval(Pr9,'error(''Ongeldige Waarde 9'')');
  NumCel  = Pr9;		% number of simulation cells
  
  %	Get name of export file
  [F,P] = uiputfile([simfile(1:length(simfile)-4) '_results.txt'], 'Stimela');
  if F ~= 0,
    exportfile = [transDir(P) F];
    
    % Load simulation results
    % extra measurements
    eval(['load ' simfile(1:length(simfile)-4) '_EM.sti -mat']);
    % Extract series
    Time   = ozonoxEM(1,:)';
    Time   = Time/3600/24;		%	days
    O3effl = ozonoxEM(4*(NumCel+1)+1, :)';
    
    % ingoing measurements 
    %!![a,Variables] = varia;  
    V = st_Varia;
    eval(['load ' simfile(1:length(simfile)-4) '_in.sti -mat']);
    %!!coO3 = ozonoxin(strmatch('Ozone ',Variables)+1,:)';				% ingoing DOC 
    coO3 = ozonoxin(V.Ozone+1,:)'
    
    % All series in one matrix!!
    exportvar = [Time, coO3, O3effl];
    [r, c] = size(exportvar);
    % Column headers
    colhead = {'Time [days]    ', 'Ozone influent concentrations [mg/l]', 'Ozone effluent concentrations [mg/l]'};
    
    % column width
    width = 6;		% minimal
    for i = 1 : c
      width = max(width, length(colhead{i}));
    end
    
    % Save to ascii file
    fid = fopen(exportfile, 'w');
    % headers
    for i = 1 : (c - 1)
      fprintf(fid, ['%' num2str(width) 's\t'], colhead{i});		% columnwidth, text, tab
    end
    fprintf(fid, ['%' num2str(width) 's\r\n'], colhead{c});		% columnwidth, text, new line
    % data
    format = [];
    for i = 1 : (c - 1)
      format = [format '%' num2str(width) 'd\t '];		% columnwidth, scientific notation, tab
    end
    format = [format '%' num2str(width) 'd\r\n'];		% columnwidth, scientific notation, new line
    fprintf(fid, format, exportvar');
    fclose(fid);
  end
  
  
  
  
  %============================= Support procedures ===================================
  
  
  
  %------------------------------
case 'ExternData_Load'
  %			Load external data from file to the figures memory
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  %	Read external data from file
  FileName = [UData.ExternData.Path UData.ExternData.FileName];
  UData.ExternData.Matrix = loadData(FileName, [1 UData.ExternData.Column]);		% 1st column = horz. axis
  UData.Modif = 1;
  
  %	Show filename and directory path on the figure
  figure(myFigHndl);		% show figure
  if isempty(UData.ExternData.FileName)
    FileNameTxt = '<none>';
    PathTxt			= '<none>';
  else
    FileNameTxt = UData.ExternData.FileName;
    PathTxt = UData.ExternData.Path;
  end
  
  set(UData.ExternData.FileNameTxtHndl, 'String', FileNameTxt);
  set(UData.ExternData.PathTxtHndl, 'String', PathTxt);
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Store UData in the figure's memory
  set(myFigHndl,'UserData',UData);
  ozonox_g('Fig_Draw', myTagName);
  
  dlgOnTop;		% put Stimela dialogue boxes in front
  
  
  
  %------------------------------
case 'ExternData_Plot'
  %			Plot external data in same graph as simulation data
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');
  
  if ~isempty(UData.ExternData.Matrix)
    %	Redraw figure
    ozonox_g('Fig_Draw', myTagName);
 
    %	Plot external data
    grph=Radiobox({'Ozone graph';'UV254 graph';'Bromate graph'},'In which graph should the data be plotted?',1);
    if grph==1
        SubPlt=1;
    elseif grph==2
        SubPlt=2;
     elseif grph==3
        SubPlt=3;
   else
    end

    figure(myFigHndl);		% show figure
    subplot(2,2,SubPlt);		% upper left graph
    %	
    HorzAxLim = get(gca, 'XLim');
    HorzAx = UData.ExternData.Matrix(:, 1);
    indHorzAx = find((HorzAx >= HorzAxLim(1)) & (HorzAx <= HorzAxLim(2)));
    hold on;						% preserve plotted simulation data
    Series = UData.ExternData.Matrix(:, UData.ExternData.Column+1);
    plot(HorzAx(indHorzAx), Series(indHorzAx, 2), 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
    %plot(HorzAx(indHorzAx), Series(indHorzAx, 2), 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
    %plot(HorzAx(indHorzAx), Series(indHorzAx, 3), 'LineStyle', 'none', 'Marker', '+', 'Color', 'g');
    hold off;
    dlgOnTop;		% put Stimela dialogue boxes in front
  end
  
  
  
  
  %------------------------------
case 'Fig_Draw'
  %			Draw figure (graphs, texts, etc.)
  
  %	Collect simulation data
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Get data from the figure's memory
  UData = get(myFigHndl, 'UserData');

  Choice = UData.ExternData.VisOption;

  if strcmp(Choice,'BC')==1 | strcmp(Choice,'BCCC')==1
      FileName  = [UData.SimData.Path UData.SimData.FileName];

      Qg  = UData.dosageparam.Qg;     
      pO2 = UData.dosageparam.O2air;  
      pN2 = UData.dosageparam.N2air;  
      pO3 = UData.dosageparam.O3air;  

  	  % Load and validate the values of the variables
      
	 % load (FileName);
      P = st_getPdata(FileName, 'ozonox');
      
%	  Pr1=eval(Pr1,'error(''Ongeldige Waarde 1'')');
%	  Pr2=eval(Pr2,'error(''Ongeldige Waarde 2'')');
%	  Pr3=eval(Pr3,'error(''Ongeldige Waarde 3'')');
%	  Pr4=eval(Pr4,'error(''Ongeldige Waarde 4'')');
%	  Pr5=eval(Pr5,'error(''Ongeldige Waarde 5'')');
%	  Pr6=eval(Pr6,'error(''Ongeldige Waarde 6'')');
%	  Pr7=eval(Pr7,'error(''Ongeldige Waarde 7'')');
%	  Pr8=eval(Pr8,'error(''Ongeldige Waarde 8'')');
%	  Pr9=eval(Pr9,'error(''Ongeldige Waarde 9'')');

      HreactBC   = P.Hreact;      %hoogte ozon reactor [m]
      AreactBC   = P.Areact;      %oppervlakte ozon reactor [m2]
   %   NumberSPBC = Pr2;
   %   HeigthSPBC = Pr3;
      MeeTeBC    = P.MeeTee;      %mee- of tegenstroom
      kIDBC      = P.kID;      %de instantane ozone vraag coefficient [l/mmol.s]
      YBC        = P.Y;      %yield factor/IDVS
      KafbO3BC   = P.KafbO3;      %afbraakconstante O3  
      ceUV254BC  = P.ceUV254;
      NumCelBC   = P.NumCel;      %aantal volledig gemengde vaten [-]

      NumCelCumBC = cumsum(NumCelBC);
      NumCelTotBC = sum(NumCelBC);
      
      dhBC = HreactBC/NumCelBC*ones(NumCelBC,1);
      hreactBC = [0 ; cumsum(dhBC(:,1))];

      if MeeTeBC==1
        MeeTeBC='Cocurrent';
      elseif MeeTeBC==0
        MeeTeBC='Countercurrent';
      else
        error(['Ongeldige Waarde 2']);
      end
      
      %=============================START: AvdBerge, 13/03/00=========================================
      eval(['load ' FileName(1:length(FileName)-4) '_EM.sti -mat']);
      %=============================STOP : AvdBerge, 13/03/00=========================================

      TaantalBC=size(ozonoxEM,2);
      % Convert time
      TimeBC    = ozonoxEM(1,:);
      TimeBC    = TimeBC';
      TimeNumBC = TimeBC/24/3600;
      %Time   = Time/3600/24;		%	days
      %TimeNum=Time/24/3600+693960; %i.v.m. omrekening vanuit excel

      UV254BC   = ozonoxEM(9*(NumCelTotBC+1)+2:10*(NumCelTotBC+1)+1,:);
      UV254BCce = UV254BC(:,TaantalBC); 
      LUV254BC  = UV254BCce(NumCelCumBC+1);
      OzoneBC   = ozonoxEM(3*(NumCelTotBC+1)+2:4*(NumCelTotBC+1)+1,:);
      OzoneBCce = OzoneBC(:,TaantalBC);
      LOzoneBC  = OzoneBCce(NumCelCumBC+1);
      VLabBC    = hreactBC(NumCelCumBC+1);
      OzoneBCcg  = ozonoxEM(4*(NumCelTotBC+1)+2:5*(NumCelTotBC+1)+1,TaantalBC);
      OzoneBCcgs = ozonoxEM(5*(NumCelTotBC+1)+2:6*(NumCelTotBC+1)+1,TaantalBC);
      OzoneBCcgo = ozonoxEM(4*(NumCelTotBC+1)+2,TaantalBC);
      OzoneBCcge = ozonoxEM(5*(NumCelTotBC+1)+1,TaantalBC);


     % Collect names of the variables
     warning off;
     %!![a,Variables] = varia;
     V=st_Varia;
     %=============================START: AvdBerge, 13/03/00=========================================
     eval(['load ' FileName(1:length(FileName)-4) '_in.sti -mat']);
     %=============================STOP : AvdBerge, 13/03/00=========================================
     LengteIn  = size(ozonoxin,2);
     %!!Ql        = ozonoxin(strmatch('Flow',Variables)+1,LengteIn);
     Ql = ozonoxin(V.Flow+1,LengteIn);
 
     tBC=[0;dhBC]/(Ql/AreactBC);
     CtBC=sum(OzoneBC.*(tBC*ones(1,TaantalBC))*60); %mg.min/l
     ceCtBC=CtBC(1,TaantalBC);

     LOzoneBC  = OzoneBCce(NumCelCumBC+1);
     VLabBC    = hreactBC(NumCelCumBC+1);
     
     kLO3 = 0; %wordt berekend in ozonox_s
     db0BC= 3; %wordt opgegeven in ozonox_s

     %Omzetten van getallen naar strings voor weergave
     pO2T    = sprintf('%.1f',pO2);
     pO3T    = sprintf('%.1f',pO3);
     pN2T    = sprintf('%.1f',pN2);
     HreactT = sprintf('%.2f',HreactBC);
     AreactT = sprintf('%.2f',AreactBC);
     QlT     = sprintf('%.1f',Ql);
     QgT     = sprintf('%.1f',Qg);
     db0T    = sprintf('%.1f',db0BC);
     kIDT    = sprintf('%.1f',kIDBC);
     KafbO3T = sprintf('%.2e',KafbO3BC);
     NumCelT = sprintf('%.0f',NumCelTotBC);
     YT      = sprintf('%.2f',YBC);
     kLO3T   = sprintf('%.2f',kLO3);
     ceUV254T    = sprintf('%.2f',ceUV254BC);
     ceCtBCT     = sprintf('%.2f',ceCtBC);
     OzoneBCcgoT = sprintf('%.2f',OzoneBCcgo);
     OzoneBCcgeT = sprintf('%.2f',OzoneBCcge);
  else
  end
  
  if strcmp(Choice,'CC')==1 | strcmp(Choice,'BCCC')==1
      FileName2 = [UData.SimData.Path2 UData.SimData.FileName2];

%  	  load (FileName2);
      P = st_getPdata(FileName2, 'ozoncc');
      
%	  Pr11=eval(Pr1,'error(''Ongeldige Waarde 1'')');
%	  Pr12=eval(Pr2,'error(''Ongeldige Waarde 2'')');
%	  Pr13=eval(Pr3,'error(''Ongeldige Waarde 3'')');
%	  Pr14=eval(Pr4,'error(''Ongeldige Waarde 4'')');
%	  Pr15=eval(Pr5,'error(''Ongeldige Waarde 5'')');
%	  Pr16=eval(Pr6,'error(''Ongeldige Waarde 6'')');
%	  Pr17=eval(Pr7,'error(''Ongeldige Waarde 7'')');
%	  Pr18=eval(Pr8,'error(''Ongeldige Waarde 8'')');
%      Pr19=eval(Pr9,'error(''Ongeldige Waarde 9'')');

      NumberCC  = P.NumberCC;      %hoogte ozon reactor [m]
      VolCC     = P.VolCC;      %mee- of tegenstroom
      kIDCC     = P.kID;      %de instantane ozone vraag coefficient [l/mmol.s]
      YCC       = P.Y;      %yield factor/IDVS
      KafbO3CC  = P.KafbO3;      %afbraakconstante O3  
      ceUV254CC = P.ceUV254;
      NumCelCC  = P.NumCel;      %aantal volledig gemengde vaten [-]

      AfictiefCC  = 1;
      NumCelTotCC = sum(NumCelCC);
      NumCelCumCC = cumsum(NumCelCC);
      dhCC        = [];
      for countCC = 1:NumberCC;
          dhnewCC = (VolCC(1,countCC)*ones(NumCelCC(1,countCC),1)/AfictiefCC)/NumCelCC(1,countCC);
          dhCC    = cat(1,dhCC,dhnewCC);
      end

      AreactCC = AfictiefCC;
      HreactCC = sum(dhCC);
      %hreact   = [0;Hreact/NumCelTot*cumsum([0.5;ones(NumCelTot-1,1)])];
      hreactCC = [0;cumsum(dhCC)];
      
      %=============================START: AvdBerge, 13/03/00=========================================
      eval(['load ' FileName2(1:length(FileName2)-4) '_EM.sti -mat']);
      %=============================STOP : AvdBerge, 13/03/00=========================================

      %if strcmp(Choice,'CC')==1
         TaantalCC=size(ozonccEM,2);
         % Convert time
         TimeCC    = ozonccEM(1,:);
         TimeCC    = TimeCC';
         TimeCCNum = TimeCC/24/3600;
         %Time   = Time/3600/24;		%	days
         %TimeNum=Time/24/3600+693960; %i.v.m. omrekening vanuit excel
         
         % Collect names of the variables
         warning off;
         %!![a,Variables] = varia;
         V=st_Varia;
         %=============================START: AvdBerge, 13/03/00=========================================
         eval(['load ' FileName2(1:length(FileName2)-4) '_in.sti -mat']);
         %=============================STOP : AvdBerge, 13/03/00=========================================
         LengteIn  = size(ozonccin,2);
         %!!Ql        = ozonccin(strmatch('Flow',Variables)+1,LengteIn);
         Ql        = ozonccin(V.Flow+1,LengteIn);
      %else
      %end

      UV254CC   = ozonccEM(9*(NumCelTotCC+1)+2:10*(NumCelTotCC+1)+1,:);
      UV254CCce = UV254CC(:,TaantalCC);
      LUV254CC  = UV254CCce(NumCelCumCC+1);
      OzoneCC   = ozonccEM(3*(NumCelTotCC+1)+2:4*(NumCelTotCC+1)+1,:);
      OzoneCCce = OzoneCC(:,TaantalCC);
      LOzoneCC  = OzoneCCce(NumCelCumCC+1);
      VLabCC    = hreactCC(NumCelCumCC+1);
      OzoneCCcgo = ozonccEM(4*(NumCelTotCC+1)+2,TaantalCC);
      OzoneCCcge = ozonccEM(5*(NumCelTotCC+1)+1,TaantalCC);
      
      tCC=[0;dhCC]/(Ql/AreactCC);
      CtCC=sum(OzoneCC.*(tCC*ones(1,TaantalCC))*60); %mg.min/l    %%%%%%%%%%%%%%%%%%%%%
      ceCtCC=CtCC(1,TaantalCC);

      LOzoneCC  = OzoneCCce(NumCelCumCC+1);
      VLabCC    = hreactCC(NumCelCumCC+1);
      
      kLO3 = 0; %wordt berekend in ozoncc_s
      db0CC  = 0; %wordt opgegeven in ozoncc_s
      if strcmp(Choice,'CC')==1 
        pO2  = 0;
        pO3  = 0;
        pN2  = 0;
        Qg   = 0;
      end
      
      %Omzetten van getallen naar strings voor weergave
      pO2T    = sprintf('%.1f',pO2);
      pO3T    = sprintf('%.1f',pO3);
      pN2T    = sprintf('%.1f',pN2);
      HreactT = sprintf('%.2f',HreactCC);
      AreactT = sprintf('%.2f',AreactCC);
      QlT     = sprintf('%.1f',Ql);
      QgT     = sprintf('%.1f',Qg);
      db0CCT  = sprintf('%.1f',db0CC);
      kIDT    = sprintf('%.1f',kIDCC);
      KafbO3T = sprintf('%.2e',KafbO3CC);
      NumCelT = sprintf('%.0f',NumCelTotCC);
      YT      = sprintf('%.2f',YCC);
      kLO3T   = sprintf('%.2f',kLO3);
      ceUV254T= sprintf('%.2f',ceUV254CC);
      ceCtCCT   = sprintf('%.2f',ceCtCC);
      if strcmp(Choice,'BCCC')==1 
        OzoneBCcgoT = sprintf('%.2f',OzoneBCcgo);
        OzoneBCcgeT = sprintf('%.2f',OzoneBCcge);
      else
        OzoneBCcgoT = sprintf('%.2f',-1);
        OzoneBCcgeT = sprintf('%.2f',-1);
      end
  else
  end

  if strcmp(Choice,'BCCC')==1
      NumCelTot= NumCelTotBC+NumCelTotCC;
      VolBC    = hreactBC*AreactBC;
      VolCC    = hreactCC;
      Vol      = [VolBC;VolCC(2:size(hreactCC,1),1)+VolBC(size(VolBC,1))];
      Ozone    = [OzoneBCce;OzoneCCce(2:size(OzoneCCce,1),1)];
      UV254    = [UV254BCce;UV254CCce(2:size(UV254CCce,1),1)];
      LOzone   = [LOzoneBC;LOzoneCC];
      LUV254   = [LUV254BC;LUV254CC];
      VLab     = [VLabBC*AreactBC;VLabCC+VLabBC(size(VLabBC,1))*AreactBC];
 
 
      dVol     = diff(Vol);
      dCgem    = (diff(Ozone)/2)+Ozone(1:size(Ozone,1)-1);
      dCt      = dCgem.*(dVol/Ql)*60;
      dCtBC    = sum(dCt(1:NumCelTotBC+NumCelCC(1,1)));
      dCtCC    = sum(dCt(NumCelTotBC+NumCelCC(1,1)+1:NumCelTotBC+NumCelTotCC));
      dCtTot   = dCtBC+dCtCC;
      
      
      tBC=[0;dhBC]/(Ql/AreactBC);
      CtBC=sum(OzoneBC.*(tBC*ones(1,TaantalBC))*60); %mg.min/l
      ceCtBC=CtBC(1,TaantalBC);

      kLO3CC = 0; %wordt berekend in ozoncc_s
      db0CC  = 0; %wordt opgegeven in ozoncc_s
      
      %Omzetten van getallen naar strings voor weergave
      pO2T    = sprintf('%.1f',pO2);
      pO3T    = sprintf('%.1f',pO3);
      pN2T    = sprintf('%.1f',pN2);
      HreactT = sprintf('%.2f',HreactBC);
      AreactT = sprintf('%.2f',AreactBC);
      QlT     = sprintf('%.1f',Ql);
      QgT     = sprintf('%.1f',Qg);
      db0T    = sprintf('%.1f',db0BC);
      kIDT     = sprintf('%.1f',kIDBC);
      KafbO3T = sprintf('%.2e',KafbO3BC);
      NumCelT = sprintf('%.0f',NumCelTotBC);
      YT      = sprintf('%.2f',YBC);
      kLO3T   = sprintf('%.2f',kLO3);
      ceUV254T= sprintf('%.2f',ceUV254BC);
      dCtBCT   = sprintf('%.2f',dCtBC);
      dCtCCT   = sprintf('%.2f',dCtCC);
  else
  end



s = get(0,'ScreenSize');
if s(3) == 1152
   bottom = 8;
elseif s(3) == 1024
   bottom = 4;
elseif s(3) == 800
   bottom = -5;
else
   bottom = 0;
end
pos =  [1 bottom s(3) 0.94*s(4)];
set(gcf,'Position',pos); 
set(gcf,'NumberTitle','off');
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[0.25 0.25 10.5 8]);

if strcmp(Choice,'BC')==1
   set(gcf,'Name',['Ozone bubble column (',MeeTeBC,')']);
elseif strcmp(Choice,'CC')==1
   set(gcf,'Name',['Ozone contact chambers']);
elseif strcmp(Choice,'BCCC')==1
   set(gcf,'Name',['Ozone bubble column (',MeeTeBC,') and contact chambers']);
else
end

pnt=[NaN NaN  1  NaN NaN  1   1   1  NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN  1  NaN  1  NaN NaN  1  NaN NaN  1  NaN  1   1   1   1  NaN;...
     NaN  1  NaN NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN NaN  1  NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN  1  NaN  1  NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN  1  NaN NaN  1  NaN;...
      1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 ;...
      1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 ;...
     NaN NaN  1   1   1  NaN  1  NaN NaN NaN NaN  1   1  NaN NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1   1  NaN NaN  1  NaN NaN NaN  1   1   1   1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1  NaN NaN NaN  1  NaN NaN NaN  1  NaN NaN  1  NaN NaN;...
     NaN NaN  1   1   1  NaN  1   1   1  NaN  1  NaN NaN  1  NaN NaN];
     set(gcf,'Pointer','custom','PointerShapeCData',pnt);

  if strcmp(Choice,'BC')==1
     subplot(2,2,1)
     plot(hreactBC,OzoneBCce,'k');
     hold on
     plot(VLabBC,LOzoneBC,'*r');
     text(hreactBC(NumCelTotBC,1)/2, max(OzoneBCce)/2, ['Ct = ' ceCtBCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',14)
     title(['Ozone, cgo = ' pO3T ' and cge = ' OzoneBCcgeT ''])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('Concentration ozone in water [mg/l]')
     grid on

     subplot(2,2,2)
     plot(hreactBC,UV254BCce,'k');
     hold on
     plot(VLabBC,LUV254BC,'*r');
     title(['UV254 nm'])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('UV254 nm [1/m]')
     grid on

     subplot(2,2,3)
     plot(hreactBC,OzoneBCce*0,'k');
     hold on
     plot(VLabBC,LOzoneBC*0,'*r');
     title(['Bromate'])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('Concentration bromate in water [mg/l]')
     grid on
  else
  end
  
  if strcmp(Choice,'CC')==1
     subplot(2,2,1)
     plot(hreactCC,OzoneCCce,'k');
     hold on
     plot(VLabCC,LOzoneCC,'*r');
     text(hreactCC(NumCelTotCC,1)/2, max(OzoneCCce)/2, ['Ct = ' ceCtCCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',14)
     title(['Ozone, cgo = ' pO3T ' and cge = ' OzoneBCcgeT ''])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('Concentration ozone in water [mg/l]')
     grid on

     subplot(2,2,2)
     plot(hreactCC,UV254CCce,'k');
     hold on
     plot(VLabCC,LUV254CC,'*r');
     title(['UV254 nm'])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('UV254 nm [1/m]')
     grid on

     subplot(2,2,3)
     plot(hreactCC,OzoneCCce*0,'k');
     hold on
     plot(VLabCC,LOzoneCC*0,'*r');
     title(['Bromate'])
     xlabel('Heigth of the ozone reactor [m]')
     ylabel('Concentration bromate in water [mg/l]')
     grid on
  else
  end

  if strcmp(Choice,'BCCC')==1
     subplot(2,2,1)
     plot(Vol,Ozone,'k');
     hold on
     plot(VLab,LOzone,'*r');
     line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(Ozone)) ceil(max(Ozone)*10)/10],'Color','g','LineWidth',1)
     text(Vol(NumCelTot,1)/2, max(Ozone)/2, ['BC: Ct = ' dCtBCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','FontSize',14)
     text(Vol(NumCelTot,1)/2, max(Ozone)/2, ['CC: Ct = ' dCtCCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top','FontSize',14)
     title(['Ozone, cgo = ' pO3T ' and cge = ' OzoneBCcgeT ''])
     xlabel('Volume of the ozone reactor [m^3]')
     ylabel('Concentration ozone in water [mg/l]')
     grid on

     subplot(2,2,2)
     plot(Vol,UV254,'k');
     hold on
     plot(VLab,LUV254,'*r');
     line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(UV254)) ceil(max(UV254))],'Color','g','LineWidth',1)
     title(['UV254 nm'])
     xlabel('Volume of the ozone reactor [m^3]')
     ylabel('UV254 nm [1/m]')
     grid on

     subplot(2,2,3)
     plot(Vol,Ozone*0,'k');
     hold on
     plot(VLab,LOzone*0,'*r');
     line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(Ozone)) ceil(max(Ozone)*10)/10],'Color','g','LineWidth',1)
     title(['Bromate'])
     xlabel('Volume of the ozone reactor [m^3]')
     ylabel('Concentration bromate in water [ug/l]')
     grid on
  else
  end


  %	Plot: Buttons and filter parameters
  subplot(2,2,4)
  set(gca,'Visible','off')
  
  % Buttons
  buttonwidth = 0.1;
  buttonheight = 0.048;
  x = 0.545;
  
  text(-0.1, 1.05, 'Plot extra data:');
  y = 0.404 : -0.055 : (0.404-0.055*4);
  n = 0;
  
  n = n+1;
  CallbackStr='ozonox_g(''ExternData_Button_Load'')';
  UData.ExternData.LoadButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Load', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='ozonox_g(''ExternData_Button_Plot'')';
  UData.ExternData.PlotButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Plot', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='ozonox_g(''ExternData_Button_Hide'')';
  UData.ExternData.HideButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Hide', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='ozonox_g(''ExternData_Button_Edit'')';
  UData.ExternData.EditButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Edit', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='ozonox_g(''ExternData_Button_New'')';
  UData.ExternData.NewButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','New', ...
    'Callback',CallbackStr);
  
  text(-0.1,0.05, 'Simulation results:');
  y = 0.062;
  CallbackStr='ozonox_g(''SimResults_Button_Export'')';
  UData.ExternData.NewButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y buttonwidth buttonheight], ...
    'String','Export', ...
    'Callback',CallbackStr);
  
  
  dlgOnTop;		% put Stimela dialogue boxes in front
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Store UData in the figure's 'UserData' field
  set(myFigHndl, 'UserData', UData);
  
  
  % Filter parameters
% kO3=0.014/s, kL=4e-4 m/s',['change of IDCS (kID=' kIDstr ',Y='Ystr ')' ])
  text(0.25,1.05, 'Input parameters:')
  n = 11;
  x = 0.25*ones(1,n);
  y = 0.97 : -0.08 : (0.97-0.08*(n-1));
  str = { ...
      'Heigth and Surface of the reactor' ...
      'Water flow' ...
      'Air flow' ...
      'Ozone concentration in air flow' ...
      'Inintial bubble diameter' ...
      'Instantaneous ozone demand kID' ...
      'Yield factor Y' ...
      'Decay coefficient of ozone' ...
      '-' ...   %   'kL value of ozone' ...
      'UV extinction 254 nm' ...
      'Completely mixed reactors'};
  text(x,y, str)
  
  x = 0.85*ones(1,n);
  str = { ...
    [HreactT AreactT] ...
    QlT ...
    QgT ...
    pO3T ...
    db0T ...
    kIDT ...
    YT ...
    KafbO3T ...
    kLO3T ...
    ceUV254T ...
    NumCelT};
  text(x,y, str)
  
  x = 1.05*ones(1,n);
  str = { ...
    'm   m^2' ...
    'm^3/h' ...
    'm^3/h' ...
    'g/Nm^3' ...
    'mm' ...
    'l/mmol.s' ...
    '-' ...
    '1/s' ...
    '-' ... %   'm/s' ...
    '1/m' ...
    '-'}; 
   text(x,y, str)
  
  text(0.25,0.05, 'Plot extra data:')
  n = 2;
  x = 0.25*ones(1,n);
  y = -0.03 : -0.08 : (-0.03-0.08*(n-1));
  str = { ...
      'File' ...
      'Path'};
  text(x,y, str)
  if isempty(UData.ExternData.FileName)
    FileNameTxt = '<none>';
    PathTxt			= '<none>';
  else
    FileNameTxt = UData.ExternData.FileName;
    PathTxt = UData.ExternData.Path;
  end
  set(UData.ExternData.FileNameTxtHndl, 'String', FileNameTxt);
  set(UData.ExternData.PathTxtHndl, 'String', PathTxt);
 

if strcmp(Choice,'BCCC')==1
figure
subplot(2,2,1)
plot(hreactBC,OzoneBCce,'k');
hold on
plot(VLabBC,LOzoneBC,'*r');
text(hreactBC(NumCelTotBC,1)/2, max(OzoneBCce)/2, ['Ct = ' ceCtBCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',14)
title(['Ozone'])
%title(['Ozone  (Efficiency = 'RO3T ' %)'])
xlabel('Heigth of the ozone reactor [m]')
ylabel('Concentration ozone in water [mg/l]')
grid on

subplot(2,2,2)
plot(hreactBC,UV254BCce,'k');
hold on
plot(VLabBC,LUV254BC,'*r');
title(['UV254 nm'])
xlabel('Heigth of the ozone reactor [m]')
ylabel('UV254 nm [1/m]')
grid on

subplot(2,2,3)
plot(hreactCC,OzoneCCce,'k');
hold on
plot(VLabCC,LOzoneCC,'*r');
text(hreactCC(NumCelTotCC,1)/2, max(OzoneCCce)/2, ['Ct = ' ceCtCCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','FontSize',14)
title(['Ozone'])
%title(['Ozone  (Efficiency = 'RO3T ' %)'])
xlabel('Heigth of the ozone reactor [m]')
ylabel('Concentration ozone in water [mg/l]')
grid on

subplot(2,2,4)
plot(hreactCC,UV254CCce,'k');
hold on
plot(VLabCC,LUV254CC,'*r');
title(['UV254 nm'])
xlabel('Heigth of the ozone reactor [m]')
ylabel('UV254 nm [1/m]')
grid on

  
  figure
  subplot(4,1,1)
  plot(Vol,Ozone)
  hold on
  plot(VLab,LOzone,'*r');
  line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(Ozone)) ceil(max(Ozone)*10)/10],'Color','g','LineWidth',1)
  text(Vol(NumCelTot,1)/2, max(Ozone)/2, ['BC: Ct = ' dCtBCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','FontSize',14)
  text(Vol(NumCelTot,1)/2, max(Ozone)/2, ['CC: Ct = ' dCtCCT ' mg*min/l'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top','FontSize',14)
  title(['Ozone'])
  %xlabel('Volume of the ozone reactor [m^3]')
  ylabel('Concentration ozone in water [mg/l]')
  grid on
  
  subplot(4,1,2)
  plot(Vol,UV254)
  hold on
  plot(VLab,LUV254,'*r');
  line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(UV254)) ceil(max(UV254))],'Color','g','LineWidth',1)
  title(['UV254 nm'])
  %xlabel('Volume of the ozone reactor [m^3]')
  ylabel('UV254 nm [1/m]')
  grid on
  
  subplot(4,1,3)
  plot(Vol,Ozone*0)
  hold on
  plot(VLab,LOzone*0,'*r');
  line([Vol(NumCelTotBC+NumCelCC(1,1)+1) Vol(NumCelTotBC+NumCelCC(1,1)+1)],[floor(min(Ozone)) ceil(max(Ozone)*10)/10],'Color','g','LineWidth',1)
  title(['Bromate'])
  xlabel('Volume of the ozone reactor [m^3]')
  ylabel('Concentration bromate in water [ug/l]')
  grid on

  subplot(4,1,4)
%plot(TimeNumBC,ozonoxEM);%      ozon in
%plot(TimeNum,Ct,'k')
%hold on
%plot(TimeNum,ozonoxEM(3*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(4*(NumCelTot+1)+1,:),'b');%      ozon uit
%hold on
%plot(TimeNum,ozonoxEM(9*(NumCelTot+1)+2,:),'m');%      UV in
%hold on
%plot(TimeNum,ozonoxEM(10*(NumCelTot+1)+1,:),'r');%     UV uit
%hold on
%plot(TimeNum,ozonoxEM(0*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(1*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(2*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(5*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(6*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(7*(NumCelTot+1)+2,:),'g');%      ozon in
%hold on
%plot(TimeNum,ozonoxEM(8*(NumCelTot+1)+2,:),'g');%      ozon in
%xlabel('Running time [days]')
%ylabel('Ct [mg.min/l]')
%title(['Ct desinfection capacity'])

figure
plot(OzoneBCce)%[1:1:NumCelTotBC]'
hold on
plot(flipud(OzoneBCcgs))%[1:1:NumCelTotBC]',

else
end
  
otherwise
  %			This function was called with an unkown value for option
  
  
  
end		% switch Option

