function StimelaStripProject(nm)
% StimelaStripProject(nm,flag)
%  strip to file blocks from project


open_system(nm)

gew=0;
sfuns = find_system(nm,'LookUnderMasks','All','MaskType','To File DHV');


for s=1:length(sfuns)
  gew=1;
  
  if isempty(findstr(sfuns{s},'ws2opc'))
    % maar niet het ws2opc blok!  
    pos = get_param(sfuns{s},'position');
    delete_block(sfuns{s})
    % nieuwe toevoegen
    add_block('built-in/terminator',sfuns{s},'position',pos);
  end
end


 
if gew>0
  % bckup maken
  nfilenm = sprintf('%s_BeforeStrip_%04d%02d%02d_%02d%02d%02d',nm,round(clock));
  copyfile([nm '.mdl'],[ nfilenm '.mdl']);

  save_system(nm)
end
close_system(nm)
