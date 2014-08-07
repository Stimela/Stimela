function [stimDir, corePd] = stimelaDir(varargin)
%automatically generated

if ~isempty(varargin) && strcmpi(varargin{1}, 'core')
  corePd = 'C:\Users\NL77801\Documents\MATLAB\SLIMM\Stimela_v2012a\Stimela_v2012a\Stimela';
else
  corePd = '';
end

stimDir = 'C:\Users\NL77801\Documents\MATLAB\SLIMM\Stimela_v2012a\Stimela_v2012a';

end