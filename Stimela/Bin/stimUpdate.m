% Stimela update function
%
% Function updates Stimela m-files and mdl-files to be compatible with
% Matlab R2011b and R2012a. This is needed due to case-sensitivity errors.
%
% Update the all m-files and mdl-files in the given directory including all subfolders
% stimUpdate('update', stimela core directory, update directory)
%
% Update the m-files and mdl-files with the given filename in the given directory including all subfolders
% stimUpdate('update', stimela core directory, update directory, filename)
%
% Update the m-files and mdl-files with the given filenames in the given directory including all subfolders
% stimUpdate('update', stimela core directory, update directory, {filename 1, filename 2, ..., filename N})
%
% To call the inner functions like "stimUpdate_isFcnName(arguments-in)" use:
% stimUpdate('isFcnName', arguments-in)

% Martijn Sparnaaij (2012)

function varargout = stimUpdate(action, varargin)

if ~nargin
  action	= 'test';
end

if nargout
  varargout	= cell(1, nargout);
  [varargout{:}]= feval(['stimUpdate_' action], varargin{:});
else
  feval(['stimUpdate_' action], varargin{:});
end

end  % <main>
%__________________________________________________________
%% #update
%
function stimUpdate_update(corePd, updatePd, varargin)

flNms	= {};

if length(varargin) == 1
  flNms	= varargin{end};
  if ~iscell(flNms)
    flNms = {flNms};
  end
elseif length(varargin) > 1
  msg1	= 'To many input variables given!';
  msg2	= 'Type "help stimUpdate" for information on the different ways of calling stimUpdate.';
  fprintf(2, '%s %s\n', msg1, msg2)
  return
end

fprintf('Starting update to Matlab R2011b or newer...\n')

if ~isdir(corePd)  , error('Directory is invalid: %s', corePd)  , end
if ~isdir(updatePd), error('Directory is invalid: %s', updatePd), end

fcns			= stimUpdate_getFcns(corePd);

if ~isempty(flNms)
  [flNms, exeInd]	= stimUpdate_checkFiles(updatePd, flNms);
else
  flNms			= {};
  [files, flInd, exeInd]= stimGetFiles('get', updatePd, {'.m', '.mdl'});
  if ~isempty(files)
    flNms		= cellfun(@fullfile,files(:,1), files(:,2), 'UniformOutput', false);
  end
end

mdlFiles	= flNms(exeInd(:,2));
stimUpdate_preProcessMdl(mdlFiles)

stimUpdate_checkAndRename(flNms, fcns)

fprintf('... update finished.\n')

end  % #update
%__________________________________________________________
%% #getFcns
%
function fcns = stimUpdate_getFcns(corePd)

fcns	= {};
mFiles	= stimGetFiles('get', corePd, '.m');

for ii = 1:size(mFiles, 1)
  [pd, fl, ext]	= fileparts(mFiles{ii, 2});
  fcns{end+1}	= fl;
end % for ii

end  % #getFcns
%__________________________________________________________
%% #checkFiles
%
function [flNms, exeInd] = stimUpdate_checkFiles(updatePd, flNmsIn)

orgPath		= path;
addpath(genpath(updatePd))

flNms		= {};
exeInd		= logical([]);

for ii = 1:length(flNmsIn)
  fl_ii		= flNmsIn{ii};
  flNm_ii	= which(fl_ii);
  if ~any(flNm_ii)
    fprintf(2, 'Could not find the file named: "%s".\n', fl_ii)
    fprintf(2, '"%s" was therefore not included in the update!\n', fl_ii)
    continue
  end
  if any(strcmpi(flNm_ii(end-1:end), '.m'))
    exeInd(end+1,1)	= true;
    exeInd(end  ,2)	= false;
  elseif any(strcmpi(flNm_ii(end-3:end), '.mdl'))
    exeInd(end+1,2)	= true;
    exeInd(end  ,1)	= false;
  else
    fprintf(2, '"%s" has got an invalid extension.\n', fl_ii)
    fprintf(2, 'Only ".m" and ".mdl" files can be updated.\n')
    continue
  end
  flNms{end+1,1}	= flNm_ii;
  
end % for ii

rmpath(genpath(updatePd))
path(orgPath)

end  % #checkFiles
%__________________________________________________________
%% #preProcessMdl
%
function stimUpdate_preProcessMdl(mdlFiles)

fprintf('Preprocessing mdl-files...')

for ii = 1:length(mdlFiles)
  flNm		= mdlFiles{ii};
  fid		= fopen(flNm,'r');
  fileData	= fread(fid, 'char');
  fclose(fid);
  
  indices	= find(fileData == 34);
  indToRemove	= [];
  
  for jj = 1:length(indices)
    ind = indices(jj);
    if ind-1 <= 0, continue; end
    if ind+3 > length(fileData), continue; end
    if fileData(ind+1) == 13 && fileData(ind+2) == 10
      n	= 3;
      while fileData(ind+n) == 32 || fileData(ind+n) == 9
	n = n+1;
      end
      if fileData(ind+n) == 34
	indToRemove = [indToRemove ind:ind+n];
      end
      
    end
  end % for jj
  
  fileData(indToRemove) = [];
  
  fid	= fopen(flNm,'w');
  fwrite(fid, fileData);
  fclose(fid);
  
end % for ii

fprintf('done\n')

end  % #preProcessMdl
%__________________________________________________________
%% #checkAndRename
%
function stimUpdate_checkAndRename(files, fcns)

fprintf('Start file checking and function renaming ...\n')

nrOfFiles		= length(files);

[perOfFiles, n, perRow]	= stimUpdate_perInfo(nrOfFiles);

steps			= 1;

for ii = 1:nrOfFiles
  
  if ii > perOfFiles*steps
    fprintf('...%d%% done', 5*n*steps)
    if ~any(mod(steps, perRow))
      fprintf('\n')
    end
    steps	= steps + 1;
  end
  
  flNm	= files{ii};
  
  fid		= fopen(flNm,'r');
  text		= fscanf(fid, '%c');
  fclose(fid);
  
  textLower	= lower(text);
  
  fid		= fopen(flNm,'r');
  fileData	= fread(fid, 'char');
  fclose(fid);
  
  for jj = 1:length(fcns)
    fcnNm	= fcns{jj};
    fcnNmLower	= lower(fcnNm);
    fcnNmLength	= length(fcnNm);
    fcnNmAscii	= int8(fcnNm);
    
    indices	= strfind(textLower, fcnNmLower);
    
    if isempty(indices), continue, end
    
    
      for kk = 1:length(indices)
	startInd		= indices(kk);
	endInd		= startInd + fcnNmLength - 1;
	frontChar		= textLower(startInd-1);
	if strcmpi(frontChar,'n')
	  frontChar	= textLower(startInd-2:startInd-1);
	end
	if endInd+1 > length(textLower)
	  backChar	= ' ';
	else
	  backChar	= textLower(endInd+1);
	end
	isFcnNm		= stimUpdate_isFcnNm(frontChar, backChar);
	if isFcnNm > 1
	  fileData(startInd:endInd)	= fcnNmAscii;
	end
      end % for kk
   
  end % for jj
  
  fid	= fopen(flNm,'w');
  if fid~=-1
      
  fwrite(fid, fileData);
  fclose(fid);
  end
end % for ii
fprintf('...100%% done\n')
fprintf('... checking and renaming done\n');

end  % #checkAndRename
%__________________________________________________________
%% #isFcnNm
%
function isFcnNm = stimUpdate_isFcnNm(frontChar, backChar)

charsFront	= [' ' '(' ')' '.' '"' ',' '''' ';' '*' '[' {'\n'} '='];
charsBack	= [' ' '(' ')' '.' '"' ',' '''' ';' '*' ']'];

front		= false;
back		= false;

for ii = 1:length(charsFront)
  if strcmpi(frontChar,charsFront(ii)), front = true; break, end
  if sum(double(frontChar) == 10) > length(frontChar)-1, front = true; break, end
end % for ii

for ii = 1:length(charsBack)
  if strcmpi(backChar,charsBack(ii)), back = true; break, end
  if double(backChar) == 13, back = true; break, end
end % for ii

isFcnNm		= front + back;

end  % #isFcnNm
%__________________________________________________________
%% #perInfo
%
function [perOfFiles, n, perRow] = stimUpdate_perInfo(nrOfFiles)

stepsPos	= [-inf 2 4 5 10 20 inf; 0 10 5 4 2 1 0; 0 2 4 5 5 5 0];
stepsWanted	= floor(nrOfFiles/10);
for ii = 2:size(stepsPos, 2)
  pos1	= stepsPos(1,ii-1) - stepsWanted;
  pos2	= stepsPos(1,ii)   - stepsWanted;
  if pos1 < 0 && pos2 >= 0
    pos1 = abs(pos1);
    pos2 = abs(pos2);
    if pos1 == pos2 || pos1 < pos2
      pos = 1;
    else
      pos = 0;
    end
    nrOfSteps	= stepsPos(1,ii-pos);
    n		= stepsPos(2,ii-pos);
    perRow	= stepsPos(3,ii-pos);
    break
  end
end
perOfFiles	= ceil(nrOfFiles/nrOfSteps);

end  % #perInfo
%__________________________________________________________
%% #test
%
function stimUpdate_test

corePd		= 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela_Core\Stimela_v2011b_Updated Core';
updatePd	= 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Int - Copy';

stimUpdate('update', corePd, updatePd, '', '')
stimUpdate('update', corePd, updatePd)
stimUpdate('update', corePd, updatePd, {'Weir_Center_Flow6', 'poscl2_g', 'poscl2_gasdas', 'cl2dos_s_c', 'precl2_s', 'MIraflores_Panama_v2', 'Coagulation_S_edwards_example'})
stimUpdate('update', corePd, 'C:\Users\M.Sparnaaij\Documents\TU\Stimela\Stimela2007a3\Stimela2007a3')

end  % #test
%__________________________________________________________
%% #qqq
%
function stimUpdate_qqq

end  % #qqq
%__________________________________________________________