function stimTestSim(mdlNm, stopTime)
fprintf('Starting simulation of %s for %s seconds.\n', mdlNm, stopTime) 


load_system(mdlNm)

configSet	= getActiveConfigSet(mdlNm);
set_param(configSet, 'StopTime', stopTime)
set_param(configSet, 'SimCompilerOptimization', 'on')
set_param(configSet, 'SimulationMode', 'normal')

startTime	= now;

fprintf('Simulation starting at %s.\n', datestr(startTime, 0))
fprintf('Simulation running ...')
tic1		= tic; 

simOut		= sim(mdlNm, configSet); 

duration	= toc(tic1); 
endTime		= now;
minutes		= floor(duration/60);
seconds		= rem(duration, 60);
fprintf('done in %d minutes and %2.0f seconds\n', minutes, seconds)
fprintf('Simulation ended at %s.\n', datestr(endTime, 0))


durStr		= sprintf('Simulation completed in %d minutes and %2.0f seconds\n', minutes, seconds);

exe		= '.testsim';
testSimFls	= stimGetFiles('get', cd, exe);

if isempty(testSimFls)
  nr		= 1;
else
 lastFl		= testSimFls{end, 2};
 [pd, fl, exe]	= fileparts(lastFl);
 flNr		= str2double(fl(end-2:end));
 nr		= flNr + 1;
end

fl		= sprintf('%s_testSim_%03d%s', mdlNm, nr, exe);
flNm		= fullfile(cd, fl);

save(flNm, 'simOut', 'durStr', 'startTime', 'endTime', 'stopTime')

fprintf('Simulation data saved to %s\n', flNm)

end