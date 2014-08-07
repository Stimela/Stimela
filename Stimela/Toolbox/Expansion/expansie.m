function h = expanfig
% This function was created by saveas(...,'mfig'), or print -dmfile.
% It loads an HG object saved in binary format in the FIG-file of the
% same name.  NOTE: if you want to see the old-style M code
% representation of a saved object, previously created by print -dmfile,
% you can obtain this by using saveas(...,'mmat'). But be advised that the
% M-file/MAT-file format does not preserve some important information due
% to limitations in that format, including ApplicationData stored using
% setappdata.  Also, references to handles stored in UserData or Application-
% Data will no longer be valid if saved in the M-file/MAT-file format.
% ApplicationData and stored handles (excluding integer figure handles)
% are both correctly saved in FIG-files.
%
%load the saved object
open('expanfig.fig')
if nargout > 0, h = gcf; end
