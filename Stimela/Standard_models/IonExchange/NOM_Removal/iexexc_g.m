function val = iexexc_g(Option, myTagName, naamfilterfile, naamspoelfile, plotfile)

% 09/09/2003, A. v.d. Berge
%    Adjusted for new regeneration module
% 12/05/2004, A. v.d. Berge
%     Adjusted for StimelaWeb-compatibility (and converted to Stimela 6 structure)

%	Constants
NumLines = 10;		% number of lines in top right graph

if nargin<1
  Option='Init'
end


%	Goto correct procedure (determined by Option)
switch Option
  
  
  
  %============================== Initialisation ======================================
  
  
  
  %------------------------------
case 'Init'
  %			Entry after first call from Stimela; request filename, then build screen
  
  %%	Initialise storage of user data
  %	Simulation data
  UData.SimData.FileName 						= '';
  UData.SimData.Path 								= '';
  %	External data
  UData.ExternData.FileName 				= '';
  UData.ExternData.FileNameTxtHndl	= [];
  UData.ExternData.Path							= '';
  UData.ExternData.PathTxtHndl 			= [];
  UData.ExternData.Column 					= [];
  UData.ExternData.Matrix 					= [];
  % UData.ExternData.Plot		 					=  0;
  UData.ExternData.LoadButtHndl 		= [];
  UData.ExternData.PlotButtHndl 		= [];
  UData.ExternData.HideButtHndl 		= [];
  UData.ExternData.EditButtHndl 		= [];
  UData.ExternData.NewButtHndl 			= [];
  
  %	Get filename (simulation data)
  if nargin<3
  ib = st_findblock(gcs,'iexexc');
  if length(ib)==1
    naamfilterfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the activated carbon filter to be visualized');
     if length(n)
       naamfilterfile = fs{n};
     else
       return;
     end
   end  
  end
  
  % Get filename (backwash data)
  if nargin<4
  ib = st_findblock(gcs,'regena');
  if length(ib)==1
    naamspoelfile = get_pfil(ib{1});
  else
    % meerdere blokken   
     fs = get_pfil(ib);
     n = Radiobox(strvcat(ib),'Select the parameter file of the regeneration module to be visualized');
     if length(n)
       naamspoelfile = fs{n};
     else
       return;
     end
   end  
  end
  % Get backwash parameters
  Ps = st_getPdata(naamspoelfile, 'regena');
  UData.spoelparam.TL= Ps.TL;   %Filter run time [days]
  UData.spoelparam.Tsp= Ps.Tsp;   %Regeneration time [days]
  
  %%	Create figure
  if ~isempty(naamfilterfile) && ~isempty(naamspoelfile),
    
    % Store filenames
    UData.SimData.naamfilterfile = naamfilterfile;
    UData.SimData.naamspoelfile = naamspoelfile;
    
    %	Create figure
    myFigHndl = figure;
    %	Find a unique TagName for the figure
    myTagName = st_UniqTag('GraphActiveCoal');
    set(myFigHndl, 'Tag', myTagName);
    % Kim's graph tools    
    Mdhv;
    
    %	Initialise texts with variable string
    subplot(2,2,4)
    set(gca,'Visible','off')
    UData.ExternData.FileNameTxtHndl = text(0.55, -0.03, '');
    UData.ExternData.PathTxtHndl = text(0.55, -0.11, '');
    
    UData.ExternData.NoButton=0;

    %uitbreiden met gebruikersdata
    Data=[];
    if nargin==5
      Data=st_LoadTxt(plotfile);
      UData.ExternData.NoButton=1;
    end  
    UData.ExternData.Data=Data;

    %	Assign to the figure's memory
    set(myFigHndl, 'UserData', UData);
    
    %	Draw figure
    iexexc_g('Fig_Draw', myTagName);
  end
  
  
  
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
  [Fn,Pn] = uigetfile('*.txt;*.mat;*.prn', 'Stimela');
  
  if Fn ~= 0,
    FileName = [transDir(Pn) Fn];
    UData.ExternData.FileName = Fn;
    UData.ExternData.Path = Pn;
    
    %	Request number of column with external data (default = 2nd column)
    %editbox_result = Editbox('Stimela', 2, 'Number of column with data to be plotted'); 
    
    prompt = cell(2,1);
    prompt(1) = {'Column number of column with influent data to be plotted'};
    prompt(2) = {'Column number of column with effluent data to be plotted'};
    lines = 1;
    defAns = {'2', '3'};
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
      UData.ExternData.FileName		= '';
      UData.ExternData.Path				= '';
      UData.ExternData.Matrix			= [];
      h = errordlg('All entered column numbers are non-numeric', 'Stimela', 'on');
      dlgOnTop(h);
    end
    
    %	Store UData in the figure's memory
    set(myFigHndl,'UserData',UData);
    %	Load external data to the figure's memory
    iexexc_g('ExternData_Load', myTagName);
  end;		% if Fn~= 0
  
  
  
  %------------------------------
case 'ExternData_Button_Plot'
  %			Button click: plot external data in same graph as simulation data
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  
  %	Plot external data
  iexexc_g('ExternData_Plot', myTagName);
  
  
  
  %------------------------------
case 'ExternData_Button_Hide'
  %			Button click: remove external data from graph with simulation data
  
  %	User pressed button: current figure is my figure
  myFigHndl = gcf;
  % Get the figure's TagName to pass it on to other procedures
  myTagName = get(myFigHndl, 'Tag');
  
  %	Redraw figure
  iexexc_g('Fig_Draw', myTagName);
  
  
  
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
  
  if length(FileName) > 0
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
        iexexc_g('ExternData_Load', myTagName);
        iexexc_g('ExternData_Plot', myTagName);
      else
        h = errordlg(['Can not find file:  ',FileName,' ; or non-existent'],'Stimela', 'on'); 
        dlgOnTop(h);
      end		% if fid > 0
    end		% if Extension == 'mat'
  end		% if length(FileName) > 0
  
  
  
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
  naamfilterfile = UData.SimData.naamfilterfile;
  P = st_getPdata(naamfilterfile, 'iexexc');
  NumCel  = P.NumCel;		% number of simulation cells
  
  %	Get name of export file
  [Fn,Pn] = uiputfile([naamfilterfile(1:length(naamfilterfile)-4) '_results.txt'], 'Stimela');
  if Fn ~= 0,
    exportfile = [transDir(Pn) Fn];
    
    % Load simulation results
    % extra measurements
    eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);
    % Extract series
    Time   = iexexcEM(1,:)';
    Time   = Time/3600/24;		%	days
    DOCeffl = iexexcEM(NumCel+2, :)';
    
    % ingoing measurements 
    V = st_Varia;  
    eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);
    coDOC = iexexcin(V.DOC+1,:)';				% ingoing DOC 
    
    % All series in one matrix!!
    exportvar = [Time, coDOC, DOCeffl];
    [r, c] = size(exportvar);
    % Column headers
    colhead = {'Running time [days]', 'DOC influent concentrations [mg/l]', 'DOC effluent concentrations [mg/l]'};
    
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
  if length(UData.ExternData.FileName) == 0
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
  iexexc_g('Fig_Draw', myTagName);
  
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
    iexexc_g('Fig_Draw', myTagName);
    
    %	Plot external data
    figure(myFigHndl);		% show figure
    subplot(2,2,3);		% lower left graph
    %	
    HorzAxLim = get(gca, 'XLim');
    HorzAx = UData.ExternData.Matrix(:, 1);
    indHorzAx = find((HorzAx >= HorzAxLim(1)) & (HorzAx <= HorzAxLim(2)));
    hold on;						% preserve plotted simulation data
    Series = UData.ExternData.Matrix(:, UData.ExternData.Column);
    plot(HorzAx(indHorzAx), Series(indHorzAx, 1), 'LineStyle', 'none', 'Marker', '+', 'Color', 'r');
    plot(HorzAx(indHorzAx), Series(indHorzAx, 2), 'LineStyle', 'none', 'Marker', 'o', 'Color', 'r');
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
  naamfilterfile = UData.SimData.naamfilterfile;

  Data = UData.ExternData.Data;
  
  % Collect names of the variables
  warning off;
  V = st_Varia;
  
  TL  = UData.spoelparam.TL;  %in dagen
  Tsp = UData.spoelparam.Tsp; %in dagen
  
  %Bepalen van de tijd tussen de lijnen in het Lindquist diagram
  TLintervald = TL/NumLines;
  TLintervals = (TL/NumLines)*24*3600;
  
  
  % Load and validate the values of the variables
  P = st_getPdata(naamfilterfile, 'iexexc');
 
  FilSur  = P.Area;		% filter surface
  Lb      = P.Lb;		% bed height
  Diam    = P.Diam;		% grain diameter
  FilPor  = P.FilPor;		% filter porousity
  n_Freun = P.n;		% Freundlich constant n
  rhoK    = P.rhoK;		% density of the active coal
  K_Freun = P.K;		% Freundlich constant K
  M_trans = P.M;		% mass transfers coefficient
  NumCel  = P.NumCel;		% number of simulation cells
  
  % Convert variables
  dy     = Lb/NumCel;		% height of one simulation cell
  BV     = FilSur*Lb;		% bed volume
  
  %	Load simulation data: Extra Measurements
  eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_EM.sti -mat']);
  
  % Convert time
  Time   = iexexcEM(1,:);
  Time   = Time';
  Time   = Time/3600/24;		%	days
  
  Flush  = iexexcEM(2*(NumCel+2)+1,:);
  
  %	Load simulation data: out(out)going variables
  eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_out.sti -mat']);
  %	Load simulation data: INgoing variables
  eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_in.sti -mat']);
  eval(['load ' naamfilterfile(1:length(naamfilterfile)-4) '_ES.sti -mat']);
  
  %	Retrieve variables
  LengthIn  = size(iexexcin,2);																			% number of data points
  Ql        = iexexcin(V.Flow+1,LengthIn);   		% ingoing flow
  Tl        = iexexcin(V.Temperature+1,LengthIn);	% ingoing temperature
  coDOC     = iexexcin(V.DOC+1,LengthIn);				% ingoing DOC
  
  
  %	Retrieve variables
  LengthOut = size(iexexcout,2);																	% number of data points
  ceDOC     = iexexcout(V.DOC+1,LengthOut);		% outgoing DOC
  SSmax  = max(iexexcout(V.DOC+1,:));					% maximum value DOC during simulation run
  RSSmin = (coDOC-SSmax)/coDOC*100;																% maximum removal efficiency during simulation run
  
  
  %	Select first filtration cycle
  
  %	Convert to: filtration = 1 and flush = 0
  FiltrOnOff = ~Flush;
  
  %	Select first cycle from filtration
  noCycle = 1;		% select first cycle
  [Cycle_On, Cycle_Off, Status, ErrStr] = selCycle(FiltrOnOff, noCycle);
  
  % Check result returned by the SelCycle-function
  switch Status
  case -1
    %	FiltrOnOff contains less cycles than noCycle: select all cycles
    Cycle_Start = Flush(1);
    Cycle_Stop  = Flush(length(Flush));
    h = errordlg(['At least ' num2str(noCycle) ' filterruns should be simulated, so extend the stop time for simulation.'],...
      'Stimela', 'on');
    dlgOnTop(h);
  case 1
    %	Desired cycle was selected (OK)
    Cycle_Start = Cycle_On(1);
    Cycle_Stop  = Cycle_On(length(Cycle_On));
  otherwise
    %	Error: slect all cycles
    Cycle_Start = Flush(1);
    Cycle_Stop  = Flush(length(Flush));
    h = errordlg(['Filterrun ' num2str(noCycle) ' could not be selected'], 'Stimela', 'on');
    dlgOnTop(h);
  end		% switch Status
  
  
  %	Fill figure (graphs, texts, buttons etc.)
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  figure(myFigHndl);		% show figure
  
  %	Resize figure
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
  
  % Set appearance of figure
  set(myFigHndl, 'Position', pos, 'NumberTitle', 'off', 'PaperOrientation', 'landscape',...
    'Name', 'Activated carbon filtation');
 %    'PaperPosition', [0.25 0.25 10.5 8], 'Name', 'Activated carbon filtation');
  
  %	Stimela mousepointer
  stimMous(myFigHndl);
  
  %	Convert numbers to string (for displaying them on screen)
  DiamTxt    = sprintf('%.1f',Diam);
  FilPorTxt  = sprintf('%.1f',FilPor);
  LbTxt      = sprintf('%.1f',Lb);
  NumCelTxt  = sprintf('%.0f',NumCel);
  FilSurTxt  = sprintf('%.1f',FilSur);
  n_FreunTxt = sprintf('%.1f',n_Freun);
  K_FreunTxt = sprintf('%.1f',K_Freun);
  rhoKTxt    = sprintf('%.1f',rhoK);
  M_transTxt = sprintf('%.1f',M_trans);
  RSSminTxt  = sprintf('%.1f',RSSmin);
  QlTxt      = sprintf('%.1f',Ql);
  noCycleTxt = sprintf('%.0f',noCycle);
  TLTxt      =  sprintf('%.0f', TL);
  TLintervaldTxt =  sprintf('%.0f', TLintervald);
  
  
  % Plot: Break through curve
  subplot(2,2,1)
  NormEff = iexexcEM(NumCel+2,:)/coDOC;
  plot(Time,NormEff)
  xlabel('Running time [days]')
  ylabel('(DOC effluent concentration)/(DOC influent concentration) [-]')
  title(['Break through curve'])
  grid on
  
  %Bewerken van de tijd
  TpsS=iexexcEM(1,Cycle_Start:Cycle_Stop);
  
  
  SSig=iexexcEM(2:NumCel+2,Cycle_Start:Cycle_Stop);
  grSig=size(SSig);
  eind=grSig(2);
  %===Are the next 2 lines of code still correct for new regenerate module?
  TpsSTemp=(TpsS-TpsS(1,eind)+(TL*24*3600));
  Line1 = min(find(TpsSTemp>(ceil(Tsp)*24*3600+86400))); %de eerste lijn van de reeks
  S(1:(NumCel+1),1)=SSig(1:(NumCel+1),Line1);
  TS(1,1)=TpsS(1,Line1);
  
  tel=0;
  t=1;
  for tel = 2:1:eind
    if rem(TpsS(1,tel),TLintervals)== 0
      t=t+1;
      S(1:(NumCel+1),t)=SSig(1:(NumCel+1),tel);
      TS(1,t)=TpsS(1,tel);
    end
  end
  S(1:(NumCel+1),t+1)=SSig(1:(NumCel+1),eind);
  TS(1,t+1)=TpsS(1,eind);
  S=flipud(S);
  
  
  % Plot: Concentration over bed height
  subplot(2,2,2)
  %	Plot the selected cycle
  plot(S,(0:NumCel)*(Lb/(NumCel)))
  xlabel('Concentration DOC [mg/l]')
  ylabel('Bed height [m]')
  title(['Concentration over the height of the bed for filter run ' noCycleTxt ' (the time interval is ' TLintervaldTxt ' days)'])
  %axis([0 S(NumCel+1,NumLines) 0 Lb])
  grid on
  
  
  % Plot: Effluent concentration
  subplot(2,2,3)
  plot(Time,iexexcEM(NumCel+2,:))
  xlabel('Running time [days]')
  ylabel('DOC effluent concentration [mg/l]')
  title(['DOC effluent concentration'])
  grid on
  
  if size(Data,2)>1
    hold on
    plot(Data(:,1),Data(:,2),'*')
    hold off
  end  
  
  %	Plot: Buttons and filter parameters
  subplot(2,2,4)
  set(gca,'Visible','off')
  
  if UData.ExternData.NoButton==0

  % Buttons
  buttonwidth = 0.1;
  buttonheight = 0.048;
  x = 0.545;
  
  text(-0.1, 1.05, 'Plot extra data:');
  y = 0.404 : -0.055 : (0.404-0.055*4);
  n = 0;
  
  n = n+1;
  CallbackStr='iexexc_g(''ExternData_Button_Load'')';
  UData.ExternData.LoadButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Load', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='iexexc_g(''ExternData_Button_Plot'')';
  UData.ExternData.PlotButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Plot', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='iexexc_g(''ExternData_Button_Hide'')';
  UData.ExternData.HideButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Hide', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='iexexc_g(''ExternData_Button_Edit'')';
  UData.ExternData.EditButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','Edit', ...
    'Callback',CallbackStr);
  
  n = n+1;
  CallbackStr='iexexc_g(''ExternData_Button_New'')';
  UData.ExternData.NewButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y(n) buttonwidth buttonheight], ...
    'String','New', ...
    'Callback',CallbackStr);
  
  text(-0.1,0.05, 'Simulation results:');
  y = 0.062;
  CallbackStr='iexexc_g(''SimResults_Button_Export'')';
  UData.ExternData.NewButtHndl = uicontrol(...
    'Style','pushbutton',...
    'Units','Normalized', ...
    'Position',[x y buttonwidth buttonheight], ...
    'String','Export', ...
    'Callback',CallbackStr);
  
end

  dlgOnTop;		% put Stimela dialogue boxes in front
  
  %	Find the handle to the figure by means of the unique TagName
  myFigHndl = findobj('Tag', myTagName);
  %	Store UData in the figure's 'UserData' field
  set(myFigHndl, 'UserData', UData);
  
  
  % Filter parameters
  text(0.35,1.05, 'Input parameters:')
  n = 11;
  x = 0.35*ones(1,n);
  y = 0.97 : -0.08 : (0.97-0.08*(n-1));
  str = { ...
      'Filter run time' ...
      'Filter surface area' ...
      'Bed height' ...
      'Water flow' ...
      'Grainsize' ...
      'Filter porosity' ...
      'Massdensity activated carbon' ...
      'Freundlich constant n' ...
      'Freundlich constant K' ...
      'Mass transfer coëfficiënt' ...
      'Completely mixed reactors'};
  text(x,y, str)
  
  x = 0.85*ones(1,n);
  str = { ...
      TLTxt ...
    FilSurTxt ...
    LbTxt ...
    QlTxt ...
    DiamTxt ...
    FilPorTxt ...
    rhoKTxt ...
    n_FreunTxt ...
    K_FreunTxt ...
    M_transTxt ...
    NumCelTxt};
  text(x,y, str)
  
  x = 1.05*ones(1,n);
  str = { ...
      'days' ...
      'm^2' ...
      'm' ...
      'm^3/h' ...
      'mm' ...
      '%' ...
      'kg/m^3' ...
      '-' ...
      '(g/kg)*(m^3/g)^n' ...
      '1/h' ...
      '-'};
  text(x,y, str)
  
  text(0.35,0.05, 'Plot extra data:')
  n = 2;
  x = 0.35*ones(1,n);
  y = -0.03 : -0.08 : (-0.03-0.08*(n-1));
  str = { ...
      'File' ...
      'Path'};
  text(x,y, str)
  if length(UData.ExternData.FileName) == 0
    FileNameTxt = '<none>';
    PathTxt			= '<none>';
  else
    FileNameTxt = UData.ExternData.FileName;
    PathTxt = UData.ExternData.Path;
  end
  set(UData.ExternData.FileNameTxtHndl, 'String', FileNameTxt);
  set(UData.ExternData.PathTxtHndl, 'String', PathTxt);
  
  
otherwise
  %			This function was called with an unkown value for option
  
  
  
end		% switch Option