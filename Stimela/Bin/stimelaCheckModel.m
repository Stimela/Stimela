%% #stimelaCheckModel
% stimelaCheckModel(modelDir)
% Checks all mdl-files in the given directory and replaces the
% old models from the Stimela library with the updated models.

function stimelaCheckModel(modelDir)

if nargin < 1
  modelDir = stimFolder('My_models');
end

stimUpdateBlocks('update', modelDir, false);

end %stimelaCheckModel
%__________________________________________________________________________