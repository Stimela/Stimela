% fig = scrollPanel('build', figPrp, rsd)
% rsd must contain: centerPanel, uiSize, uiOffset
% rsd can further contain: topPanel, bottomPanel, leftPanel, rightPanel
% callback must be outsize calls

function varargout = scrollPanel(action, varargin)
  
  if ~nargin
    action	= 'test'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['scrollPanel_' action], varargin{:});
  else
    feval(['scrollPanel_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #build
%
function fig = scrollPanel_build(figPrp, rsd)

rsd.buildReady		= false;

figPrp.ResizeFcn	= @scrollPanel_resize;
% figPrp.Renderer		= 'painters';
fig			= figure(figPrp);
  
set(rsd.centerPanel, 'Parent', fig)

rsd			= scrollPanel_addPanels(fig, rsd);
set(rsd.centerPanel, 'BackgroundColor', 'r')

pnlPos			= get(rsd.centerPanel, 'Position');

rsd.width		= pnlPos(3);
rsd.height		= pnlPos(4);
rsd.sliderWidth		= 15;

uiPrp			= struct;
uiPrp.Units		= 'points';
uiPrp.Parent		= fig;
uiPrp.Style		= 'slider';
uiPrp.CallBack		= @scrollPanel_scrollVer;
uiPrp.Max		= rsd.height;
uiPrp.Position		= [0 rsd.bpHeight + rsd.sliderWidth rsd.sliderWidth 1];
rsd.verSlider		= uicontrol(uiPrp);

uiPrp.CallBack		= @scrollPanel_scrollHor;
uiPrp.Max		= rsd.width;
uiPrp.Position		= [rsd.lpWidth rsd.bpHeight 1 rsd.sliderWidth];
rsd.horSlider		= uicontrol(uiPrp);

rsd.minSize		= [rsd.tpHeight + rsd.bpHeight + 30 ...
  rsd.lpWidth + rsd.rpWidth + 30];
rsd.maxSize		= [rsd.lpWidth + rsd.rpWidth + rsd.width ...
  rsd.tpHeight + rsd.bpHeight + rsd.height];

rsd.buildReady		= true;
setappdata(fig, 'rsd', rsd)
set(rsd.verSlider, 'Value', get(rsd.verSlider, 'Max'))
scrollPanel_resize(fig)

end  % #build
%__________________________________________________________
%% #resize
%
function scrollPanel_resize(fig, evd)
  
rsd		= getappdata(fig, 'rsd');
figPos		= get(fig, 'Position');

if ~isfield(rsd, 'buildReady') || ~rsd.buildReady
  return;
end

rsd.addVer		= 0;
rsd.addHor		= 0;
rsd.oldHorVal		= get(rsd.horSlider, 'Value');
rsd.oldVerVal		= get(rsd.verSlider, 'Value');

% Check size, correct if smaller than minimum
if figPos(3) < rsd.minSize(1)
  figPos(3)	= rsd.minSize(1);
  set(fig, 'Position', figPos)
end
if figPos(4) < rsd.minSize(2)
  dY		= rsd.minSize(2) - figPos(4);
  figPos(4)	= rsd.minSize(2);
  figPos(2)	= figPos(2) - dY;
  set(fig, 'Position', figPos)
end
% Check size, correct if lager than maximum
if figPos(3) >= rsd.maxSize(1)
%   figPos(3)	= rsd.maxSize(1);  
  set(fig, 'Position', figPos)
  set(rsd.horSlider, 'Visible', 'off')
  set(rsd.horSlider, 'Value', 0)
  rsd.addVer	= rsd.sliderWidth;
end
if figPos(4) >= rsd.maxSize(2)
%   figPos(4)	= rsd.maxSize(2);  
  set(fig, 'Position', figPos)
  set(rsd.verSlider, 'Visible', 'off')  
  set(rsd.verSlider, 'Value', 0)
  rsd.addHor	= rsd.sliderWidth;
end

setappdata(fig, 'rsd', rsd)

% Update positions of normal panels
topPanelPos		= get(rsd.topPanel	, 'Position');
bottomPanelPos		= get(rsd.bottomPanel	, 'Position');
leftPanelPos		= get(rsd.leftPanel	, 'Position');
rightPanelPos		= get(rsd.rightPanel	, 'Position');

topPanelPos([2,3])	= [figPos(4) - rsd.tpHeight figPos(3)];
bottomPanelPos(3)	= figPos(3);
leftPanelPos([2,4])	= [rsd.bpHeight figPos(4) - rsd.tpHeight - rsd.bpHeight];
rightPanelPos([1,2,4])	= [figPos(3) - rsd.rpWidth rsd.bpHeight ...
  figPos(4) - rsd.tpHeight - rsd.bpHeight];

set(rsd.topPanel	, 'Position', topPanelPos)
set(rsd.bottomPanel	, 'Position', bottomPanelPos)
set(rsd.leftPanel	, 'Position', leftPanelPos)
set(rsd.rightPanel	, 'Position', rightPanelPos)

% Update positions of sliders
verSliderPos		= get(rsd.verSlider	, 'Position');
horSliderPos		= get(rsd.horSlider	, 'Position');

verSliderPos([1,2,4])	= [rightPanelPos(1) - rsd.sliderWidth ...
  rsd.bpHeight + rsd.sliderWidth - rsd.addVer rightPanelPos(4) - rsd.sliderWidth + rsd.addVer];
horSliderPos(3)		= bottomPanelPos(3) - rsd.rpWidth ...
  - rsd.lpWidth - rsd.sliderWidth + rsd.addHor;

set(rsd.verSlider	, 'Position', verSliderPos)
set(rsd.horSlider	, 'Position', horSliderPos)

% Update position of center panel
centerPanelPos		= get(rsd.centerPanel, 'Position');
  
[pos, x, xInv]	= scrollPanel_calcX(rsd);
centerPanelPos([1,3])	= [pos(1) rsd.width];
if figPos(3) < rsd.maxSize(1)
  set(rsd.horSlider, 'Visible', 'on')
  set(rsd.horSlider, 'Value', rsd.oldHorVal)
  minStep		= min(.5*(rsd.uiSize(1) + rsd.uiOffset(1))/x, ...
    .5*(rsd.uiSize(1) + rsd.uiOffset(1))/xInv);
  set(rsd.horSlider,'SliderStep', [min(1, minStep) min(1, 2*minStep)])
end

[pos, y, yInv]	= scrollPanel_calcY(rsd);
centerPanelPos([2,4])	= [pos(2) rsd.height];
if get(rsd.verSlider, 'Value') == 0
  set(rsd.verSlider, 'Value', 20)
  set(rsd.verSlider, 'Value', 0)
end

if figPos(4) < rsd.maxSize(2)
  set(rsd.verSlider, 'Visible', 'on') 
  set(rsd.verSlider, 'Value', rsd.oldVerVal)
  minStep		= min(2*(rsd.uiSize(2) + rsd.uiOffset(2))/y, ...
    2*(rsd.uiSize(2) + rsd.uiOffset(2))/yInv);
  set(rsd.verSlider,'SliderStep', [min(1, minStep) min(1, 2*minStep)])
end

set(rsd.centerPanel, 'Position', centerPanelPos);

end  % #resize
%__________________________________________________________
%% #scrollHor
%
function scrollPanel_scrollHor(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');
pos	= scrollPanel_calcX(rsd);

set(rsd.centerPanel, 'Position', pos)

end  % #scrollHor
%__________________________________________________________
%% #calcX
%
function [pos, x, xInv] = scrollPanel_calcX(rsd)

val		= get(rsd.horSlider, 'Value');
sliderPos	= get(rsd.horSlider, 'Position');
posRel		= val/rsd.width;
visRel		= sliderPos(3)/rsd.width;

x		= posRel*(1-visRel)*rsd.width;
xInv		= (1-posRel)*(1-visRel)*rsd.width;

oldPos		= get(rsd.centerPanel, 'Position');
pos		= [-x+rsd.lpWidth oldPos(2) oldPos(3:4)];
% pos		= [-x		  oldPos(2) oldPos(3:4)];

end  % #calcX
%__________________________________________________________
%% #scrollVer
%
function scrollPanel_scrollVer(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');
pos	= scrollPanel_calcY(rsd);

set(rsd.centerPanel, 'Position', pos)

end  % #scrollVer
%__________________________________________________________
%% #calcY
%
function [pos, y, yInv] = scrollPanel_calcY(rsd)
  
val		= get(rsd.verSlider, 'Value');
sliderPos	= get(rsd.verSlider, 'Position');
posRel		= val/rsd.height;
visRel		= sliderPos(4)/rsd.height;

y		= posRel*(1-visRel)*rsd.height;
yInv		= (1-posRel)*(1-visRel)*rsd.height;

oldPos		= get(rsd.centerPanel, 'Position');
pos		= [oldPos(1) -y+rsd.bpHeight+rsd.sliderWidth-rsd.addVer oldPos(3:4)];
% pos		= [oldPos(1) -y				     oldPos(3:4)];

end  % #calcY
%__________________________________________________________
%% #addPanels
%
function rsd = scrollPanel_addPanels(fig, rsd)

panels	= scrollPanel_getPanelData;

for ii = 1:size(panels,1)
  panelNm = panels(ii).name; 
  if isfield(rsd, panelNm)
    set(rsd.(panelNm), 'Parent', fig)
  else
    if strcmpi(panels(ii).type, 'uic')
      rsd.(panelNm) = uicontrol(scrollPanel_createPanelPrp(panels(ii), fig));
    else      
      rsd.(panelNm) = uipanel(scrollPanel_createPanelPrp(panels(ii), fig));
    end
  end  
  if ~isempty(panels(ii).varNm)
    pos_ii			= get(rsd.(panelNm), 'Position');
    rsd.(panels(ii).varNm)	= pos_ii(panels(ii).posNr);
  end
end % for ii
  
end  % #addPanels
%__________________________________________________________
%% #getPanelData
%
function panels = scrollPanel_getPanelData
  
headersC = {'name', 'size', 'varNm', 'posNr', 'type'};

panelC	 = {
  % name	size	'varNm'		posNr	type	
  'topPanel'	[1 10]	'tpHeight'	4	'uic'
  'bottomPanel' [1 10]	'bpHeight'	4	'uic'
  'leftPanel'	[10 1]  'lpWidth'	3	'uic'
  'rightPanel'	[10 1]	'rpWidth'	3	'uic'
};

panels	= cell2struct(panelC', headersC);

end  % #getPanelData
%__________________________________________________________
%% #createPanelPrp
%
function pnlPrp = scrollPanel_createPanelPrp(panel, fig)
  
pnlPrp			= scrollPanel_getDfltPanelPrp(panel.type, get(fig, 'Color'));
pnlPrp.Parent		= fig;
pnlPrp.Position		= [0 0 panel.size];

end  % #createPanelPrp
%__________________________________________________________
%% #getDfltPanelPrp
%
function pnlPrp = scrollPanel_getDfltPanelPrp(type, color)
  
switch type
  case 'uic'
    pnlPrp			= struct;
    pnlPrp.BackgroundColor	= color;
    pnlPrp.BackgroundColor	= 'blue';
    pnlPrp.Units		= 'points';
    pnlPrp.Style		= 'text';
  case 'normal'
    pnlPrp			= struct;
    pnlPrp.BackgroundColor	= color;
    pnlPrp.BorderType		= 'etchedin';
    pnlPrp.BorderWidth		= 1;
    darkFactor			= 0.1;
    ind				= find(color > darkFactor);
    color(ind)			= color(ind) - darkFactor;
    pnlPrp.ForegroundColor	= color;
    pnlPrp.Units		= 'points';
    pnlPrp.Clipping		= 'on';
end

end  % #getDfltPanelPrp
%__________________________________________________________
%% #test
%
function scrollPanel_test
  scrollPanelTest
end  % #test
%__________________________________________________________
%% #qqq
%
function scrollPanel_qqq
  
end  % #qqq
%__________________________________________________________