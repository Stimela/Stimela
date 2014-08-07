function varargout = scrollFigure(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['scrollFigure_' action], varargin{:});
  else
    feval(['scrollFigure_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #create
%
function rsd = scrollFigure_create(fig, rsd)
  
rsd			= scrollFigure_setSizes(rsd);

uiPrp			= struct;
uiPrp.Parent		= fig;
uiPrp.BackgroundColor	= get(fig, 'Color');
uiPrp.Style		= 'frame';

uiPrp.Position		= [0 0 rsd.sliderWidth 10];
rsd.verFrame		= uicontrol(uiPrp);

uiPrp.Position		= [0 0 10 rsd.sliderWidth];
rsd.horFrame		= uicontrol(uiPrp);

uiPrp			= struct;
uiPrp.Parent		= fig;
uiPrp.Style		= 'slider';

uiPrp.CallBack		= @scrollFigure_scrollVer;
uiPrp.Max		= rsd.height;
uiPrp.Position		= [0 0 rsd.sliderWidth 10];
rsd.verSlider		= uicontrol(uiPrp);

uiPrp.CallBack		= @scrollFigure_scrollHor;
uiPrp.Max		= rsd.width;
uiPrp.Position		= [0 0 10 rsd.sliderWidth];
rsd.horSlider		= uicontrol(uiPrp);

set(fig, 'Resize'   , 'on')
set(fig, 'ResizeFcn', @scrollFigure_resize)

end  % #create
%__________________________________________________________
%% #setSizes
%
function rsd = scrollFigure_setSizes(rsd)
  
rsd.sliderWidth		= 15;

framesConfig		= scrollFigure_getFramesConfig;
for ii = 1:size(framesConfig, 1)
  varNm				= framesConfig(ii).varNm;
  if ~isempty(varNm)
    h		= rsd.(framesConfig(ii).name);
    pos		= get(h, 'Position');
    vis		= get(h, 'Visible');
    if strcmpi(vis, 'off')
      val	= 0;
    else
      val	= pos(framesConfig(ii).posNr);
    end
    rsd.(varNm)	= val;
  end
end % for ii

framePos		= get(rsd.centerFrame, 'Position');
rsd.width		= framePos(3);
rsd.height		= framePos(4);

rsd.minSize		= [rsd.nfHeight + rsd.sfHeight + 40 ...
  rsd.wfWidth + rsd.efWidth + 40];
rsd.maxSize		= [rsd.wfWidth + rsd.efWidth + rsd.width ...
  rsd.nfHeight + rsd.sfHeight + rsd.height];

if ~isfield(rsd, 'uiSize')
  rsd.uiSize		= [200 15];
end
if ~isfield(rsd, 'uiOffset')
  rsd.uiOffset		= [10 10];
end

end  % #setSizes
%__________________________________________________________
%% #resize
%
function scrollFigure_resize(h, evd)
  
fig		= hfigure(h);
rsd		= getappdata(fig, 'rsd');
figPos		= get(fig, 'Position');

rsd.addVer	= 0;
rsd.addHor	= 0;
rsd.oldHorVal	= get(rsd.horSlider, 'Value');
rsd.oldVerVal	= get(rsd.verSlider, 'Value');

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
if figPos(3) >= rsd.maxSize(1)
  set(fig, 'Position', figPos)
  set(rsd.horSlider, 'Visible', 'off')
  set(rsd.horFrame, 'Visible', 'off')
  set(rsd.horSlider, 'Value', 0)
  rsd.addVer	= rsd.sliderWidth;
end
if figPos(4) >= rsd.maxSize(2)
  set(fig, 'Position', figPos)
  set(rsd.verSlider, 'Visible', 'off')
  set(rsd.verFrame, 'Visible', 'off')
  set(rsd.verSlider, 'Value', 0)
  rsd.addHor	= rsd.sliderWidth;
end

setappdata(fig, 'rsd', rsd)

% Update positions of normal panels
northFramePos		= get(rsd.northFrame, 'Position');
southFramePos		= get(rsd.southFrame, 'Position');
westFramePos		= get(rsd.westFrame , 'Position');
eastFramePos		= get(rsd.eastFrame , 'Position');

northFramePos([2,3])	= [figPos(4) - rsd.nfHeight figPos(3)];
southFramePos(3)	= figPos(3);
westFramePos([2,4])	= [rsd.sfHeight figPos(4) - rsd.nfHeight - rsd.sfHeight];
eastFramePos([1,2,4])	= [figPos(3) - rsd.efWidth rsd.sfHeight ...
  figPos(4) - rsd.nfHeight - rsd.sfHeight];

set(rsd.northFrame, 'Position', northFramePos)
set(rsd.southFrame, 'Position', southFramePos)
set(rsd.westFrame , 'Position', westFramePos)
set(rsd.eastFrame , 'Position', eastFramePos)

% Update positions of sliders and frames
verSliderPos		= get(rsd.verSlider, 'Position');
horSliderPos		= get(rsd.horSlider, 'Position');
verFramePos		= get(rsd.verFrame , 'Position');
horFramePos		= get(rsd.horFrame , 'Position');

verSliderPos([1,2,4])	= [eastFramePos(1) - rsd.sliderWidth ...
  rsd.sfHeight + rsd.sliderWidth - rsd.addVer eastFramePos(4) - rsd.sliderWidth + rsd.addVer];
horSliderPos(3)		= southFramePos(3) - rsd.efWidth ...
  - rsd.wfWidth - rsd.sliderWidth + rsd.addHor;

verFramePos(1)		= verSliderPos(1);
verFramePos(2)		= verSliderPos(2) - rsd.addVer;
verFramePos(4)		= verSliderPos(4) + rsd.addVer;
horFramePos(3)		= horSliderPos(3) + rsd.addHor;

set(rsd.verSlider, 'Position', verSliderPos)
set(rsd.horSlider, 'Position', horSliderPos)
set(rsd.verFrame , 'Position', verFramePos)
set(rsd.horFrame , 'Position', horFramePos)

% Update position of center panel
centerFramePos		= get(rsd.centerFrame, 'Position');
  
[pos, x, xInv]	= scrollFigure_calcX(rsd);
centerFramePos([1,3])	= [pos(1) rsd.width];
if figPos(3) < rsd.maxSize(1)
  set(rsd.horSlider, 'Visible', 'on')
  set(rsd.horSlider, 'Value', rsd.oldHorVal)
  minStep		= min(.5*(rsd.uiSize(1) + rsd.uiOffset(1))/x, ...
    .5*(rsd.uiSize(1) + rsd.uiOffset(1))/xInv);
  set(rsd.horSlider,'SliderStep', [min(1, minStep) min(1, 2*minStep)])
end

[pos, y, yInv]	= scrollFigure_calcY(rsd);
centerFramePos([2,4])	= [pos(2) rsd.height];
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

set(rsd.centerFrame, 'Position', centerFramePos);

end  % #resize
%__________________________________________________________
%% #scrollHor
%
function scrollFigure_scrollHor(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');
pos	= scrollFigure_calcX(rsd);

set(rsd.centerFrame, 'Position', pos)

end  % #scrollHor
%__________________________________________________________
%% #calcX
%
function [pos, x, xInv] = scrollFigure_calcX(rsd)

val		= get(rsd.horSlider, 'Value');
sliderPos	= get(rsd.horSlider, 'Position');
posRel		= val/rsd.width;
visRel		= sliderPos(3)/rsd.width;

x		= posRel*(1-visRel)*rsd.width;
xInv		= (1-posRel)*(1-visRel)*rsd.width;

oldPos		= get(rsd.centerFrame, 'Position');
pos		= [-x+rsd.wfWidth oldPos(2) oldPos(3:4)];

end  % #calcX
%__________________________________________________________
%% #scrollVer
%
function scrollFigure_scrollVer(h, evd)
  
fig	= hfigure(h);
rsd	= getappdata(fig, 'rsd');
pos	= scrollFigure_calcY(rsd);

set(rsd.centerFrame, 'Position', pos)

end  % #scrollVer
%__________________________________________________________
%% #calcY
%
function [pos, y, yInv] = scrollFigure_calcY(rsd)
  
val		= get(rsd.verSlider, 'Value');
sliderPos	= get(rsd.verSlider, 'Position');
posRel		= val/rsd.height;
visRel		= sliderPos(4)/rsd.height;

y		= posRel*(1-visRel)*rsd.height;
yInv		= (1-posRel)*(1-visRel)*rsd.height;

oldPos		= get(rsd.centerFrame, 'Position');
pos		= [oldPos(1) -y+rsd.sfHeight+rsd.sliderWidth-rsd.addVer oldPos(3:4)];

end  % #calcY
%__________________________________________________________
%% #setDefaultPanels
%
function rsd = scrollFigure_setDefaultFrames(fig, rsd)

framesConfig	= scrollFigure_getFramesConfig;

uiPrp			= struct;
uiPrp.Parent		= fig;
uiPrp.BackgroundColor	= get(fig, 'Color');
uiPrp.Units		= 'points';
uiPrp.Style		= 'frame';
uiPrp.Visible		= 'off';
uiPrp.Position		= [0 0 1 1];

for ii = 1:size(framesConfig, 1)
  rsd.(framesConfig(ii).name)	= uicontrol(uiPrp);
end % for ii

end  % #setDefaultPanels
%__________________________________________________________
%% #getFramesConfig
%
function framesConfig = scrollFigure_getFramesConfig
  
headersC = {'name', 'varNm', 'posNr'};

framesConfigC	 = {
  % name		varNm		posNr	
  'centerFrame'		''		[]
  'northFrame'		'nfHeight'	4
  'eastFrame'		'efWidth'	3
  'southFrame'		'sfHeight'	4
  'westFrame'		'wfWidth'	3
};

framesConfig	= cell2struct(framesConfigC', headersC);

end  % #getFramesConfig
%__________________________________________________________
%% #qqq
%
function scrollFigure_qqq
  
end  % #qqq
%__________________________________________________________