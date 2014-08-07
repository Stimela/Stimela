% ok = stimZip('zip', zipFlNm, flNms);

function varargout = stimZip(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimZip_' action], varargin{:});
  else
    feval(['stimZip_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #zip
%
function ok = stimZip_zip(zipFlNm, flNms, varargin)
  
[ok, msg, exeFlNm] = stimZip_findExe;
if ~ok
  fprintf(2, '%s\n',msg)
  return
end

if ~iscell(flNms)
  flNms = {flNms};
end

tmpPd	= stimZip_moveToTempPd(flNms);

% compress folder
% !"C:\Program Files\7-Zip\Command_line\7za.exe" a -tzip C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela_v2011b_IM\My_projects\Int_model_new\test.zip C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela_v2011b_IM\My_projects\Int_model_new\StimelaData\*

commandLine		= sprintf('"%s" a -tzip %s %s\\*', exeFlNm, zipFlNm, tmpPd);

[status, result]	= dos(commandLine);

if status > 0
  fprintf(2, 'Error while trying to archive the obsolete files.\n')
  fprintf(2, 'Files can be found in: "%s".\n', tmpPd)
  fprintf(2, '================== Command Line ==================\n')
  fprintf(2, '%s\n', commandLine)
  fprintf(2, '================== Error message ==================\n')
  fprintf(2, '%s\n', result)
  return
end

rmdir(tmpPd, 's')

end  % #zip
%__________________________________________________________
%% #findExe
%
function [ok, msg, exeFlNm] = stimZip_findExe
  
exeNm	= '7za.exe';
exePd	= '';
ok	= false;
msg	= '';

pd	= 'C:\Program Files\7-Zip\Command_line';

if isdir(pd)
  exePd = pd;
else
  % search for exePd?  
end

if ~isempty(exePd)
  exeFlNm	= fullfile(exePd, exeNm);
  ok		= true;
else
  exeFlNm	= '';
  msg		= sprintf('The %s could not be found.', exeNm);
end

end  % #findExe
%__________________________________________________________
%% #moveToTempPd
%
function tmpPd = stimZip_moveToTempPd(flNms)

[pd, fl, exe]	= fileparts(flNms{1});

tmpPd		= fullfile(pd, 'tmpZip');
mkdir(tmpPd);

for ii = 1:numel(flNms)
  movefile(flNms{ii}, tmpPd);
end
  
end  % #moveToTempPd
%__________________________________________________________
%% #qqq
%
function stimZip_qqq
  
end  % #qqq
%__________________________________________________________