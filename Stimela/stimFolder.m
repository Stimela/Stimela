% Stimela function to get the path to a Stimela directory
%
% call:
% directory = stimFolder(type);
%
% types: 'main', 'stimela', 'bin', 'standard_models', 'standard_projects', ...
%	 'my_models', 'my_projects', 'standard_cfiles', 'stimela_menu', ...
%	 'stimela_menu_templates', 'backup', 'toolbox', 'dev'    
%
% Stimela, 2004-2012

% © Martijn Sparnaaij

function pd = stimFolder(pdNm)
  
[pdMain, corePd]	= stimelaDir('core');

switch lower(pdNm)
  case 'main'
    pd	= pdMain;
   case 'bin'
    pd	= fullfile(stimFolder('stimela'), 'Bin');
  case 'stimela'
    pd	= corePd;
  case 'standard_models'
    pd	= fullfile(stimFolder('stimela'), 'Standard_models');
  case 'standard_projects'
    pd	= fullfile(stimFolder('stimela'), 'Standard_projects');
  case 'my_models'
    pd	= fullfile(pdMain, 'My_models');
  case 'my_projects'
    pd	= fullfile(pdMain, 'My_projects');
  case 'standard_cfiles'
    pd = fullfile(stimFolder('Standard_models'), 'Standard_cfiles');
  case 'stimela_menu'
    pd = fullfile(stimFolder('Bin'), 'Stimela_menu');
  case 'stimela_menu_templates'
    pd = fullfile(stimFolder('Stimela_menu'), 'Templates');
  case 'backup'
    pd = fullfile(stimFolder('Bin'), 'Backup');    
  case 'toolbox'
    pd = fullfile(stimFolder('Stimela'), 'Toolbox');
    case 'dev'
    pd = fullfile(stimFolder('Bin'), 'Dev');
  otherwise
    error('No directory by the name "%s"', pdNm)
end

end
%__________________________________________________________
