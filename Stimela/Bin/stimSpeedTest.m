% stimSpeedTest('runTest', mdlNm, stopTime)
% mdlNm can be a single modelname or a cell of modelnames
% stopTime can be a singel stoptime or a cell of stoptimes
%
% stimSpeedTest('getResult', mdlNms)
% mdlNm can be a single modelname or a cell of modelnames


function varargout = stimSpeedTest(action, varargin)
  
  if ~nargin
    action	= 'qqq'; 
  end
  
  if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['stimSpeedTest_' action], varargin{:});
  else
    feval(['stimSpeedTest_' action], varargin{:});
  end
  
end  % <main>
%__________________________________________________________
%% #runTest
%
function stimSpeedTest_runTest(mdlNm, stopTime, varargin)

if ~iscell(stopTime)
  stopTime = {stopTime};
end

if ~iscell(mdlNm)
  mdlNm = {mdlNm};
end

if ~isempty(varargin)
  saveData	= varargin{1};
else
  saveData	= false(numel(stopTime));
end

nrOfMdls	= numel(mdlNm);
if size(stopTime, 1) < nrOfMdls
  stopTimeOrg	= stopTime;
  stopTime	= cell(nrOfMdls, size(stopTimeOrg, 2));
  for ii = 1:nrOfMdls
    stopTime(ii,:) = stopTimeOrg;
  end % for ii
end

fprintf('\nPreprocessing test run ...')
mdlFls	= cell(numel(mdlNm), 2);
for ii = 1:nrOfMdls
  mdlNm_ii		= mdlNm{ii};
  [ok, msg, mdlFlNm]	= stimSpeedTest_preRunProcess(mdlNm_ii, stopTime(ii,:));
  if ~ok
    fprintf(2,'\nSimulation cannot start for the following reason:\n')
    fprintf(2,'%s\n', msg{:})
    return
  end 
  mdlFls{ii, 1}	= mdlNm_ii;
  [pd, fl, exe]	= fileparts(mdlFlNm);
  mdlFls{ii, 2}	= pd;
end % for ii
fprintf('done\n')

cdOrg		= cd;

for ii = 1:nrOfMdls
  mdlNm_ii	= mdlFls{ii, 1};
  cd(mdlFls{ii, 2})
  fprintf('\nStarting simulation test for "%s" ...\n', mdlNm_ii)
  stopTime_ii	= stopTime(ii,:);
  for jj = 1:numel(stopTime_ii)
    stopTime_jj	= stopTime_ii{jj};
    try
      simData		= stimSpeedTest_simulate(mdlNm_ii, stopTime_jj);
      stimSpeedTest_postProcess(simData, mdlFls(ii,:), stopTime_jj, saveData(jj))
    catch ME
      ok		= false;
      msg{end+1}	= ME.getReport;
      ctrlCInd		= strfind(msg, '(Ctrl-C)');	
      if any(ctrlCInd{:})
	return
      end
    end
    if ~ok
      fprintf(2,'\nSimulation of "%s" at stoptime "%s" could not be completed.\n',...
	mdlNm_ii, stopTime_jj)
      fprintf(2,'%s\n', msg{:})
    end    
  end % for jj
end % for ii

cd(cdOrg)

end  % #runTest
%__________________________________________________________
%% #preRunProcess
%
function [ok, msg, mdlFlNm] = stimSpeedTest_preRunProcess(mdlNm, stopTime)
  
ok			= false;
msg			= {};

[okIn, msg, mdlFlNm]	= stimSpeedTest_getMdlFlNm(mdlNm);

if ~okIn, return, end
  
for ii = 1:numel(stopTime)
 stopTimeStr	= stopTime{ii};
 try
   stopTimeVal	= eval(stopTimeStr);
 catch ME
   msg{end+1}	= sprintf('The stoptime string "%s" is invalid.', stopTimeStr);
   msg{end+1}	= sprintf('The following error was given:');
   msg{end+1}	= ME.getReport;
   return
 end
 if ~isnumeric(stopTimeVal)
   msg{end+1}	= sprintf('The stoptime string value "%s" is not numeric!', stopTimeVal);
   return
 end
 
end % for ii

ok	= true;

end  % #preRunProcess
%__________________________________________________________
%% #simulate
%
function simData = stimSpeedTest_simulate(mdlNm, stopTime)
  
fprintf('Starting simulation of %s for %s seconds.\n', mdlNm, stopTime) 

simData			= struct;
simData.stopTime	= stopTime;

load_system(mdlNm)

configSet	= getActiveConfigSet(mdlNm);
set_param(configSet, 'StopTime', stopTime)
set_param(configSet, 'SimCompilerOptimization', 'on')
set_param(configSet, 'SimulationMode', 'normal')

simData.startTime	= now;
fprintf('Simulation starting at %s.\n', datestr(simData.startTime, 0))

fprintf('Simulation running ...')
tic1		= tic; 

simData.simOut	= sim(mdlNm, configSet); 

simData.duration= toc(tic1); 
simData.endTime	= now;
minutes		= floor(simData.duration/60);
seconds		= rem(simData.duration, 60);

fprintf('done in %d minutes and %2.0f seconds\n', minutes, seconds)
fprintf('Simulation ended at %s.\n', datestr(simData.endTime, 0))

end  % #simulate
%__________________________________________________________
%% #postProcess
%
function stimSpeedTest_postProcess(simData, mdlFl, stopTime, saveData)
  
mdlNm		= mdlFl{1};
fprintf('Starting postprocessing of %s and %s seconds ...', mdlNm, stopTime) 

flNm		= stimSpeedTest_getFl;
pd		= mdlFl{2};
[d,stimDataPdNm]= st_StimelaDataDir;
pd		= fullfile(pd, stimDataPdNm);

dataPdNm	= sprintf('run_%s_%d_second_%s', mdlNm,...
  eval(stopTime), datestr(simData.startTime, 30));
dataPd		= fullfile(pd, dataPdNm);
mkdir(dataPd)

if saveData
  srcStr		= sprintf('%s\\*.sti', pd);
  destStr		= sprintf('%s\\', dataPd);
  movefile(srcStr, destStr)
end

flNm		= fullfile(dataPd, flNm);
save(flNm, 'simData')

fprintf('done\n')
fprintf('Data was saved in the following directory:\n')
fprintf('%s\n', dataPd)

end  % #postProcess
%__________________________________________________________
%% #getResults
%
function stimSpeedTest_getResult(mdlNms)

if ~iscell(mdlNms)
  mdlNms = {mdlNms};
end

nrOfMdls	= numel(mdlNms);
mdlFlNms	= cell(nrOfMdls, 2);

for ii = 1:nrOfMdls
  [ok, msg, mdlFlNm] = stimSpeedTest_getMdlFlNm(mdlNms{ii});
if ~ok
  fprintf(2, '%s\n', msg{:})
  return
end

[pd, fl, exe]	= fileparts(mdlFlNm);

mdlFlNms{ii, 1} = pd;
mdlFlNms{ii, 2} = [fl exe];

end % for ii

result		= struct;
fl		= stimSpeedTest_getFl;
[d,stimDataPdNm]= st_StimelaDataDir;

for ii = 1:nrOfMdls
  pd_ii		= mdlFlNms{ii, 1};
  pd_ii		= fullfile(pd_ii, stimDataPdNm);
  dirs		= stimSpeedTest_getDirs(pd_ii);
  indicesC	= strfind(dirs, '_second');
  indices	= cellfun(@isempty, indicesC);
  runPdNms	= dirs(~indices);
  
  
  nrOfRuns	= numel(runPdNms);
  compareData	= nan(nrOfRuns, 2);
    
  for jj = 1:nrOfRuns
    flNm		= fullfile(pd_ii, runPdNms{jj}, fl);
    data		= load(flNm, '-mat');
    simData		= data.simData;
    stopTime		= simData.stopTime;
    compareData(jj,1)	= eval(stopTime)/60;
    compareData(jj,2)	= simData.duration;    
  end % for jj
  compareDataSorted		= sort(compareData);		
  
  xData		= compareDataSorted(:,1);
  yData		= compareDataSorted(:,2);
  coefs		= polyfit(xData, yData, 1);
  x		= 0:2:xData(end);
  y		= coefs(1)*x + coefs(2);
  fittedData	= [x', y']; 
  
  result(ii).mdlNm		= mdlNms{ii};
  result(ii).compareData	= compareDataSorted;
  result(ii).fittedData		= fittedData;
  result(ii).coefs		= coefs;
  
end % for ii

stimSpeedTest_showData(result)

end  % #getResults
%__________________________________________________________
%% #getMdlFlNm
%
function [ok, msg, mdlFlNm] = stimSpeedTest_getMdlFlNm(mdlNm)

ok		= false;
msg		= {};

mdlFlNm		= which(mdlNm);
if isempty(mdlFlNm)
  msg{end+1}	= sprintf('Model with the name "%s" was not found on the path.', mdlNm);
  return
end

ok		= true;

end  % #getMdlFlNm
%__________________________________________________________
%% #getDirs
%
function dirs = stimSpeedTest_getDirs(pd)

dirData				= dir(pd);
dirIndex			= [dirData.isdir];
dirs				= {dirData(dirIndex).name}';
dirs(strcmp(dirs, '.'))		= [];
dirs(strcmp(dirs, '..'))	= [];

end  % #getDirs
%__________________________________________________________
%% #getFl
%
function fl = stimSpeedTest_getFl
  
fl = 'runData.simtest';

end  % #getFl
%__________________________________________________________
%% #showData
%
function stimSpeedTest_showData(result)

fig		= figure('Name', 'Results speed test');
ax		= axes('Parent', fig);

plotStr		= 'plot(ax';
legendStr	= 'hLeg = legend(';
for ii = 1:size(result, 2)
  plotStr	= sprintf('%s, result(%d).compareData(:,1)', plotStr, ii);
  plotStr	= sprintf('%s, result(%d).compareData(:,2), ''o''', plotStr, ii);
  plotStr	= sprintf('%s, result(%d).fittedData(:,1)', plotStr, ii);
  plotStr	= sprintf('%s, result(%d).fittedData(:,2), ''-''', plotStr, ii);
  coefStr	= sprintf('y = %fx + %f', result(ii).coefs);
  if ii == 1
    legendStr	= sprintf('%sresult(%d).mdlNm, [result(%d).mdlNm ''_fitted %s'']', legendStr, ii, ii, coefStr);
  else
    legendStr	= sprintf('%s, result(%d).mdlNm, [result(%d).mdlNm ''_fitted %s'']', legendStr, ii, ii, coefStr);
  end
  
end % for ii
plotStr		= sprintf('%s)', plotStr);
legendStr	= sprintf('%s);', legendStr);
eval(plotStr)
eval(legendStr);
set(hLeg, 'Interpreter', 'none', 'fontSize', 11)
assignin('base', 'result', result)

end  % #showData
%__________________________________________________________
%% #qqq
%
function stimSpeedTest_qqq
  
end  % #qqq
%__________________________________________________________