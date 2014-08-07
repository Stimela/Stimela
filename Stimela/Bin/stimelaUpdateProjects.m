function stimelaUpdateProjects(projectDir)
% doorlopen files. Elk mdl openen. Als het een Stimela model wijzigen naar
% voorbeeld block0. Behouden van filenaam en uiterlijk etc.

if nargin < 1
  projectDir = stimFolder('My_projects');
end

stimUpdateBlocks('update', projectDir, true);

end %#stimelaUpdateProjects
%__________________________________________________________________________