function h=dhv_actionbar()
% h = dhv_actionbar() 
% new, open, save, save as buttons maken
% handles teruggeven in h

un = get(gcf,'units');
set(gcf,'units','pixel');
fg = get(gcf,'position');
set(gcf,'units',un);

x0 = [2 fg(4)];

CN = imread('dhv_new.bmp');
sCN = size(CN);

x0(2)=x0(2)-sCN(2)-4;

h.New = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','New');

x0(1)=x0(1)+sCN(1)+6;


CN = imread('dhv_open.bmp');
sCN = size(CN);

h.Open = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','Open');
x0(1)=x0(1)+sCN(1)+4;

CN = imread('dhv_save.bmp');
sCN = size(CN);

h.Save = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','Save');
x0(1)=x0(1)+sCN(1)+4;

CN = imread('dhv_saveas.bmp');
sCN = size(CN);

h.SaveAs = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','Save As');
x0(1)=x0(1)+sCN(1)+6;

CN = imread('dhv_exit.bmp');
sCN = size(CN);

h.Exit = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','Exit');
x0(1)=x0(1)+sCN(1)+6;

CN = imread('dhv_help.bmp');
sCN = size(CN);

h.Help = uicontrol('style','push','units','pixels', ...
               'position',[x0 sCN(1:2)+4],'CData',CN,  ...
               'tooltipstring','Help');
x0(1)=x0(1)+sCN(1)+6;

