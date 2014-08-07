function fig = st_ParameterInputFigure(nColumn)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

if nColumn<=0
  nColumn=1;
end

load st_ParameterInputFigure

h0 = figure('CloseRequestFcn','st_ParameterInput(''exit'')', ...
	'Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'CreateFcn','Mdhv', ...
	'MenuBar','none', ...
	'Name','Input parameters', ...
	'NumberTitle','off', ...
	'PointerShapeCData',mat1, ...
	'Tag','Fig1');

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
pos =  [1 bottom s(3) 0.97*s(4)];
set(gcf,'Position',pos); 
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[0.25 0.25 10.5 8]);


h=dhv_actionbar;
set(h.New,   'callback',' st_ParameterInput(''new'') ');
set(h.Save,  'callback',' st_ParameterInput(''save'') ');
set(h.SaveAs,'callback',' st_ParameterInput(''saveas'') ');
set(h.Open,  'callback',' st_ParameterInput(''load'') ');
set(h.Exit,  'callback',' st_ParameterInput(''exit'') ');
set(h.Help,  'callback',' st_ParameterInput(''help'') ');


h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.05 0.8 .8 .1], ...
	'String','Block name : -unknown-', ...
	'Style','text', ...
	'Tag','BlokNaam');
h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[0.05 .75 .8 .1], ...
	'String','File name : -unknown-', ...
	'Style','text', ...
	'Tag','FileNaam');

h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[.05 .7 .200 .100], ...
	'String','Change values:', ...
	'Style','text', ...
	'Tag','txt');

h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[.55/nColumn .67 .2/nColumn .03], ...
	'String','[]', ...
	'Style','edit', ...
	'Tag','Edit0');

h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[.1/nColumn .67 .45/nColumn .03], ...
	'String','Description0:', ...
	'Style','text', ...
	'Tag','Description0');


h1 = uicontrol('Parent',h0, ...
	'Units','norm', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[.77/nColumn .67 .45/nColumn .03], ...
	'String','m', ...
	'Style','text', ...
	'Tag','Unit0');


if nargout > 0, fig = h0; end
