function varargout = stimFigure(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimFigure_' action], varargin{:});
  else
    feval(['stimFigure_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #create
%
function fig = stimFigure_create(tag, title, figSize, varSize)
  
figs = findall(0, 'tag', tag);
if any(figs)
  delete(figs);
end

figPrp				= struct;
figPrp.Color			= [1 1 1] * 0.98;
figPrp.MenuBar			= 'none';
figPrp.Name			= title;
figPrp.Tag			= tag;
figPrp.NumberTitle		= 'off';
figPrp.Resize			= 'off';
figPrp.Toolbar			= 'none';
figPrp.Units			= 'points';
figPrp.Visible			= 'off';
fig				= figure(figPrp);

stimFigure_position(fig, figSize, varSize)

end  % #create
%__________________________________________________________
%% #position
%
function stimFigure_position(fig, figSize, varSize)
  
screenPosPix	= get(0, 'ScreenSize');
screenSizePix	= screenPosPix(3:4);
pixPerInch	= get(0, 'ScreenPixelsPerInch');
screenSize	= screenSizePix*72/pixPerInch; % points

if varSize
  figSize(1)	= min(screenSize(1)*2/3, figSize(1));
  figSize(2)	= min(screenSize(2)*2/3, figSize(2));
end

figPos(1)	= (screenSize(1) - figSize(1))/2;
figPos(2)	= (screenSize(2) - figSize(2))/5*3;
figPos(3:4)	= figSize;

set(fig, 'Position', figPos)

end  % #position
%__________________________________________________________
%% #qqq
%
function stimFigure_qqq
  
end  % #qqq
%__________________________________________________________