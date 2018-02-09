function fontsize = getFontsize
  
fig		= figure('visible', 'off');
screensize	= get(0, 'ScreenSize');

pos		=  [1 1 screensize(3) 0.9*screensize(4)];
set(fig, 'position', pos)
 
ax = axes('parent', fig);
hText = text(0,0,'X','parent', ax, ...
  'fontunits', 'norm', 'fontsize', 0.0155);

set(hText, 'fontunits', 'pixels');
drawnow
fontsize = get(hText,'fontsize');

delete(fig)

end  
%__________________________________________________________
