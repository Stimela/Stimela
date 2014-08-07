function RTD

FileNameAll={...
        ['Time_distribution']};...
%        ['AWWA19'];...
%        ['AWWA20'];...
%        ['AWWA21']};...
%        ['AWWA05']};

% The model name can be obtained with opening the model and the command gcs
% The block names can be obtained with clicking on the block and the command gcb
Model    = ['Time_distribution']
Block_IN = ['Time_distribution/Water quality' 10 'parameters']
Block_TD = ['Time_distribution/Time_distribution']

open(Model);
for i=1:size(FileNameAll,1);
    FileName=FileNameAll{i,1}
    invruw_f(0,     Block_IN,[ FileName '_IN.mat'])
    invruw_f(16,    Block_IN,[ FileName '_IN.mat'])
    timeds_f('init',Block_TD,[ FileName '_TD.mat']);
    timeds_f('exit',Block_TD,[ FileName '_TD.mat']);
    startcalRTD([ FileName ]);
end

