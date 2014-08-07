function varargout = scrollFigureTest(varargin)
  
fig		= stimFigure('create', 'test', 'Test', [inf inf], true);
rsd		= struct;
  
rsd		= scrollFigure('setDefaultFrames', fig, rsd);

set(rsd.centerFrame, 'Position', [0 0 900 1200])
set(rsd.centerFrame, 'Visible', 'on')
set(rsd.centerFrame, 'BackgroundColor', 'r')

set(rsd.northFrame, 'Position', [0 0 10 60])
set(rsd.northFrame, 'Visible' , 'on')
set(rsd.southFrame, 'Position', [0 0 10 30])
set(rsd.southFrame, 'Visible' , 'on')
set(rsd.eastFrame , 'Position', [0 0 30 10])
set(rsd.eastFrame , 'Visible' , 'on')
set(rsd.westFrame , 'Position', [0 0 60 10])
set(rsd.westFrame , 'Visible' , 'on')
rsd		= scrollFigure('create', fig, rsd);

setappdata(fig, 'rsd', rsd)
set(fig, 'Visible', 'on')

end  
%__________________________________________________________
