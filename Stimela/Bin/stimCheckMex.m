% Stimela function for checking and recompiling the compiled models
%
% Steps:
% 1.) Check which models need recompiling. 
% 2.) Check for installed compilers. If none are installed the models can't be recompiled.
% 3.) Get the source files for every model.
% 4.) Recompile the models
%
% Calls:
% stimCheckMex('checkMex', mexVersion)
% stimCheckMex('checkMex', mexVersion, '-forceCompile') % forces to recompile all models
% 
% Stimela, 2004-2012

% © Martijn Sparnaaij

function varargout = stimCheckMex(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimCheckMex_' action], varargin{:});
  else
    feval(['stimCheckMex_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #checkMex
%
function stimCheckMex_checkMex(mexVer, varargin)

forceCompile	= false;
if ~isempty(varargin)
  forceCompile	= any(strcmpi(varargin, '-forceCompile'));
end

needRecompile		= stimCheckMex_checkUsedModels(mexVer);
if isempty(needRecompile) && ~forceCompile
  fprintf('done\n')
  return
end

ok = stimCheckMex_checkInstalledCompilers(needRecompile);
if ~ok  
  return
end

modelNms = needRecompile(:,1);
modelPd = stimFolder('Standard_models');
exe = '.c';
cFiles = stimGetFiles('get', modelPd, exe);

canNotCompile = stimCheckMex_compile(modelNms, cFiles);

fprintf('Stimela mex check done\n')

end  % #checkMex
%__________________________________________________________
%% #checkUsedModels
%
function needRecompile = stimCheckMex_checkUsedModels(mexVer)
  
needRecompile		= {};

modelPd			= stimFolder('Standard_models');
exe			= {'.mdl', '.mexw64', '.mexw32'};
[fls, flInd, exeInd]	= stimGetFiles('get', modelPd, exe);

compModelsUsed		= {};
mdlFls			= fls(exeInd(:,1),:);
mexAdd			= '_s_c';

for ii = 1:size(mdlFls, 1)
  fl		= mdlFls{ii, 2};
  fid		= fopen(fl, 'r');
  if fid < 3
    fprintf(1, 'Could not open %s.\n', fl);
    continue;
  end
  text		= fscanf(fid, '%s');
  fclose(fid);
  underInd	= strfind(fl, '_');
  if isempty(underInd)
    underInd	= strfind(fl, '.');
  end
  modelNm	= fl(1:underInd(1)-1);
  mexMdlNm	= [modelNm mexAdd];
  if any(strfind(text, mexMdlNm))
    compModelsUsed{end+1,1} = modelNm;
    compModelsUsed{end  ,2} = mexMdlNm;
  end  
end % for ii
  
mexw64Fls	= fls(exeInd(:,2),:);
mexw32Fls	= fls(exeInd(:,3),:);

eval(['mexFls = ' mexVer 'Fls(:,2);'])

for ii = 1:length(compModelsUsed)
  mexFlNm	= sprintf('%s.%s', compModelsUsed{ii,2}, mexVer);
  if ~any(strcmp(mexFls, mexFlNm))
    needRecompile{end+1,1}	= compModelsUsed{ii,1}; 
    needRecompile{end  ,2}	= mexFlNm;
  end
end % for ii

end  % #checkUsedModels
%__________________________________________________________
%% #checkInstalledCompilers
%
function ok = stimCheckMex_checkInstalledCompilers(needRecompile)
  
ok	= true;

cc	= mex.getCompilerConfigurations('c++','installed');

if isempty(cc)
  fprintf(2, '\nStimela could not find the compilers needed to recompile the models!\n');
  fprintf(2, 'For more information type "doc mex" in the command screen.\n');
  fprintf(2, 'Warning: The following models won''t work:\n');
  for ii = 1:size(needRecompile,1)
    fprintf(2, '[%02d] %s\n', ii, needRecompile{ii,1});
  end % for ii
  fprintf(2, '\nReplace the s-functions to the matlab m file to let the models work.\n');
  ok	= false;
  return
end

end  % #checkInstalledCompilers
%__________________________________________________________
%% #compile
%
function canNotCompile = stimCheckMex_compile(modelNms, cFiles)

[canCompile, canNotCompile] = stimCheckMex_hasSrcFiles(modelNms, cFiles);

for ii = 1:size(canCompile)
  pd	= canCompile{ii,1};
  fl	= canCompile{ii,2};
  src1	= canCompile{ii,3};
  src2	= canCompile{ii,4};
  cPd	= stimFolder('standard_cfiles');
  
  fprintf('Compiling %s ...', fl)
  try
    error = mex('-O', ['-I' cPd],...
      '-outdir', pd, '-output', fl, src1, src2);
  catch ME
    canNotCompile{end+1, 1} = fl;
    canNotCompile{end  , 2} = src1;
    canNotCompile{end  , 3} = src2;
    fprintf(2, 'failed\n');
    continue
  end
  fprintf(1, 'done\n');
end % for ii


end  % #compile
%__________________________________________________________
%% #hasSrcFiles
%
function [canCompile, canNotCompile] = stimCheckMex_hasSrcFiles(modelNms, cFiles)

canCompile	= {
  %pd	name	source1(_s_c)		source2(_s_code)
  };

canNotCompile	= {
  %name		source1(_s_c)		source2(_s_code)
  };

modelsPd	= stimFolder('Standard_models');

for ii = 1:length(modelNms)
  modelNm_ii	= modelNms{ii};
  
  indSrc1	= strcmpi(cFiles(:,2), [modelNm_ii '_s_c.c']);
  indSrc2	= strcmpi(cFiles(:,2), [modelNm_ii '_s_code.c']);
  src1_ii	= cFiles(indSrc1,:);
  src2_ii	= cFiles(indSrc2,:);
  
  nrOfSrcFiles	= sum(indSrc1) + sum(indSrc2);
  if nrOfSrcFiles >= 2
    src1_ii			= src1_ii(1,:);
    src2_ii			= src2_ii(1,:);
    src1Pd			= src1_ii{1,1};	
    cFilePdInd			= strfind(src1Pd,'cfiles');
    modelPd			= src1Pd(1:cFilePdInd-1);
    canCompile{end+1, 1}	= fullfile(modelsPd ,modelPd);
    canCompile{end  , 2}	= [modelNm_ii, '_s_c'];
    canCompile{end  , 3}	= fullfile(modelsPd, src1_ii{1}, src1_ii{2});
    canCompile{end  , 4}	= fullfile(modelsPd, src2_ii{1}, src2_ii{2});
  else
    if isempty(src1_ii)
      src1_ii = {'',''};
    end
    if isempty(src2_ii)
      src2_ii = {'',''};
    end
    
    canNotCompile{end+1, 1} = modelNm_ii;
    canNotCompile{end  , 2} = fullfile(modelsPd, src1_ii{1}, src1_ii{2});
    canNotCompile{end  , 3} = fullfile(modelsPd, src2_ii{1}, src2_ii{2});
  end  
end % for ii

end  % #hasSrcFiles
%__________________________________________________________
%% #qqq
%
function stimCheckMex_qqq
  
end  % #qqq
%__________________________________________________________