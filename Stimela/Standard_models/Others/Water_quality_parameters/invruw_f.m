function varargout = invruw_f(option,varia1,varia2,varia3)
% invruw_f(option,varia1,varia2,varia3)
%   Functie voor afhandelen van blokafhankelijk gedrag in de
%   ParamterInputFigure.
%   Wordt aangeroepen door st_ParameterInput.m.
%
% Stimela, 2004

% © A.J.P. van den Berge,

% In UData wordt alles opgeslagen (userdata van deze figuur)
% UData.BlokNaam = Bloknaam
% Udata.Filenaam = Filenaam
% UData.handle(1) = FileNAam Handle
% UData.handle(2) = BlokNaam Handle
% UData.modif = Gewijzigd flag
% Udata.edit(:) = Editbox waarden Handles

option = upper(option);
varargout = [];

% option switch
switch option
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Callback van de editvelden
  case 'WAARDE'
    
    % a plot-button may need to be added/hidden
    invruw_f('update');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Aanmaken figuur en assenstelsel
  case 'BUILD'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    % load pictures
    picImport = imread('dhv_open.bmp');
    picPlot   = imread('Dhv_plot.bmp');
    szImport = size(picImport);
    szPlot = size(picPlot);
    szPic(1) = max(szImport(1), szPlot(1)) + 4;
    szPic(2) = max(szImport(2), szPlot(2)) + 4;
    
    % extra UI-controls for each parameter
    for ParNum = 1 : length(UData.edit)
      % position edit box
      hEdit = UData.edit(ParNum);
      un = get(hEdit,'units');
      set(hEdit,'units','pixel');
      EditPos = get(hEdit,'position');
      set(hEdit,'units',un);
      % position parameter description
      hDesc = UData.Description(ParNum);
      un = get(hDesc,'units');
      set(hDesc,'units','pixel');
      DescPos = get(hDesc,'position');
      set(hDesc,'units',un);
      
      % check boxes
      CheckBoxPos      = [DescPos(1)-szPic(1), DescPos(2), szPic(1), szPic(2)];
      UData.Checkbox(ParNum) = uicontrol(...
        'Style',            'Checkbox', ...
        'Units',            'pixels', ...
        'Position',         CheckBoxPos,    ...
        'Callback',         ['invruw_f(''Checkbox'',' num2str(ParNum) ');'], ...
        'Visible',          'on',  ...
        'Value',            0 ...
        );
      % import buttons
      ImportButtonPos  = [EditPos(1)-szPic(1), EditPos(2), szPic(1), szPic(2)];
      UData.ImportButton(ParNum) = uicontrol(...
        'Style',            'push', ...
        'Units',            'pixels', ...
        'Position',         ImportButtonPos,    ...
        'CData',            picImport,  ....
        'tooltipstring',    'Import time series from file',  ...
        'Callback',         ['invruw_f(''import'',' num2str(ParNum) ')'], ...
        'Visible',          'on'  ...
        );
      % plot buttons
      PlotButtonPos    = [ImportButtonPos(1)-szPic(1), EditPos(2), szPic(1), szPic(2)];
      UData.PlotButton(ParNum) = uicontrol(...
        'Style',            'push', ...
        'Units',            'pixels', ...
        'Position',         PlotButtonPos,    ...
        'CData',            picPlot,  ....
        'tooltipstring',    'Plot time series',  ...
        'Callback',         ['invruw_f(''plot'',' num2str(ParNum) ')'], ...
        'Visible',          'off'  ...
        );
    end % for ParNum
    
    % store userdata in figure
    set(Invoer_fig,'UserData',UData);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Menu New
  case 'NEW'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    for ParNum = 1 : length(UData.Checkbox)
      set(UData.Checkbox(ParNum), 'Value', 1);      % standard for new parameter set: all parameters active
    end
    
    invruw_f('update');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Menu load
  case 'LOAD'
    
    AdditionalData = varia1;
    
    % AdditionalData holds for each parameter wether it is active or not
    % => check-box checked or not
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    for ParNum = 1 : length(UData.Checkbox)
      PInfo = get(UData.edit(ParNum),'UserData');
      fieldname = [PInfo.Name, 'IsActive'];
      if isfield(AdditionalData, fieldname)
        ParIsActive = getfield(AdditionalData, fieldname);
      else
        ParIsActive = 0;
      end
      % set check-box
      set(UData.Checkbox(ParNum), 'Value', ParIsActive);
    end    
      
    invruw_f('update');   % (de-)activate edit-boxes and buttons
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Menu save
  case 'SAVE'
    
    % for each parameter on screen the check-box is either checked or not
    % => this info is returned in AdditionalData to be saved in file by
    % st_ParameterInput
     
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    AdditionalData = [];
    for ParNum = 1 : length(UData.Checkbox)
      PInfo = get(UData.edit(ParNum),'UserData');
      fieldname = [PInfo.Name, 'IsActive'];
      ParIsActive = get(UData.Checkbox(ParNum), 'Value');
      AdditionalData = setfield(AdditionalData, fieldname, ParIsActive);
    end    
   
    varargout{1} = AdditionalData;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update
  case 'UPDATE'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    for ParNum = 1 : length(UData.edit)

      % => Check status
      
      % Parameter activated (check box marked)?
      ParIsActive = get(UData.Checkbox(ParNum), 'Value');
      if ParIsActive;
        % Data series or single value?
        IsTimeSeries = 0;   
        ParVal = eval(get(UData.edit(ParNum), 'String'));
        if isnumeric(ParVal)
          [r, c] = size(ParVal);
          if c==2 && r>1   % time-series
            IsTimeSeries = 1;
          end
        end % if isnum
      end % parameter activated?
      
      % => Set appearances
      
      if ParIsActive
        set(UData.edit(ParNum), 'Enable', 'on');
        set(UData.ImportButton(ParNum), 'Visible', 'on');
        if IsTimeSeries
          set(UData.PlotButton(ParNum), 'Visible', 'on');
        else
          set(UData.PlotButton(ParNum), 'Visible', 'off');
        end
     else
        set(UData.edit(ParNum), 'Enable', 'off');
        set(UData.ImportButton(ParNum), 'Visible', 'off');
        set(UData.PlotButton(ParNum), 'Visible', 'off');
      end
    end % for parnum
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Callbacks: check-boxes
  case 'Checkbox'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    UData.modif=1;
    set(Invoer_fig,'UserData',UData);
      
    invruw_f('update');   % (de-)activate edit-boxes and buttons
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Callbacks: import buttons
  case 'IMPORT'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    ParNum = varia1;   % =button number =edit box number =parameter number
    V = st_Variabelen;
    ParName = V(ParNum).LongName;
    
    % Get file name
    Title = ParName;
    [F,P]=uigetfile('*.txt;*.prn;*.mat',Title);
    if F ~= 0,
      FileNaam=[P F];
      
      % Get column number (of column with time-series of ParNum-th parameter)
      Title=ParName;
      Description = ['Number of column with ' ParName '-values.'];
      Default=2;
      editbox_result=Editbox(Description,Default,Title); 
      if ~isempty(editbox_result)
        % plot time-series as string in edit control
        KolomNum=str2num(editbox_result);
        [T,reeks]=Loadinv(FileNaam,KolomNum);
        str = ['[' num2str(T') '; '  num2str(reeks') ']'''];
        set(UData.edit(ParNum), 'String', str);
        UData.modif=1;
        
        % add plot-buttong
        invruw_f('update');
      end
    end;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Callbacks: plot buttons
  case 'PLOT'
    
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'Userdata');
    
    ParNum = varia1;   % =button number =edit box number =parameter number
    V = st_Variabelen;
    ParName = V(ParNum).LongName;
    ParVal = eval(get(UData.edit(ParNum), 'String'));   % time-series
    
    Plot_fig = figure;
    plot(ParVal(:,1), ParVal(:,2));
    set(get(gca,'XLabel'),  'String', 'time [sec]');
    set(get(gca,'Title'),   'String', ParName);
    set(Plot_fig,           'Name',   ParName);
    
    
    
    
    
end % switch
