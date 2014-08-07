function ret=WSGenerateXML(ModelName)
% WSGenerateXML(ModelName)

cd(stimFolder('My_projects'))
if ~exist(ModelName,'dir')
  ret=['Error: Project not found : ' ModelName];
  return
end

cd(ModelName)
if ~exist([ModelName '.mdl'],'file')
  ret=['Error: Model not Found :' ModelName];
  return
end

nInputs=0;
nOutputs=0;


open_system(ModelName);

%
gew=0;
sfuns = find_system(ModelName,'BlockType','SubSystem'); %%, 'LookUnderMasks'); %%,'all');
for s=1:length(sfuns)
  % op zoek naar de s-functie met blok 123456_s 
  snm='';

  % zoeken naar blok met systeem
  if strcmp(get_param(sfuns{s},'BlockType'),'SubSystem')
    ini = get_param(sfuns{s},'MaskInitialization');
    n = findstr(ini,'_p(filenaam)');
    if length(n)>0 
      snm = ini(n(1)-6:n(1)-1);
    end
  end
  
  switch snm
    case 'wsgetm'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nOutputs = nOutputs+1;
      Outputs(nOutputs).Tag=P.WSTag;
      Outputs(nOutputs).Default=num2str(P.Default);
      Outputs(nOutputs).Min=num2str(P.Minimal);
      Outputs(nOutputs).Max=num2str(P.Maximal);
      Outputs(nOutputs).Description='Measurement';
      Outputs(nOutputs).WSDescription=P.WSDescription;
      Outputs(nOutputs).Unit=P.WSUnit;
    case 'wsgetq'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nOutputs = nOutputs+1;
      Outputs(nOutputs).Tag=P.WSTag;
      Outputs(nOutputs).Default=num2str(P.Default);
      Outputs(nOutputs).Min=num2str(P.Minimal);
      Outputs(nOutputs).Max=num2str(P.Maximal);
      Outputs(nOutputs).Description=P.VariaName;
      Outputs(nOutputs).WSDescription=P.WSDescription;
      Outputs(nOutputs).Unit=P.WSUnit;
    case 'wssetq'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nInputs = nInputs+1;
      Inputs(nInputs).Tag=P.WSTag;
      Inputs(nInputs).Default=num2str(P.Default);
      Inputs(nInputs).Min=num2str(P.Minimal);
      Inputs(nInputs).Max=num2str(P.Maximal);
      Inputs(nInputs).Description=P.VariaName;
      Inputs(nInputs).WSDescription=P.WSDescription;
      Inputs(nInputs).Unit=P.WSUnit;

    case 'wssetc'
      naamfile = get_pfil(sfuns{s});
      P = st_getPdata(naamfile, snm);  

      nInputs = nInputs+1;
      Inputs(nInputs).Tag=P.WSTag;
      Inputs(nInputs).Default=num2str(P.Default);
      Inputs(nInputs).Min=num2str(P.Minimal);
      Inputs(nInputs).Max=num2str(P.Maximal);
      Inputs(nInputs).Description='Setpoint';
      Inputs(nInputs).WSDescription=P.WSDescription;
      Inputs(nInputs).Unit=P.WSUnit;
  end
end

close_system(ModelName);


% weschrijven
fid = fopen(['Waterspot\' ModelName '.xml'],'wt');
fprintf(fid,'<?xml version="1.0" encoding="utf-8"?>');
fprintf(fid,'<model>');
fprintf(fid,'<name>%s</name>',ModelName);
fld=fieldnames(Inputs);
for i = 1:nInputs
fprintf(fid,'<input>');
  for f=1:length(fld)
    fprintf(fid,'<%s>',fld{f});
    fprintf(fid,'%s',getfield(Inputs,{i},fld{f}));
    fprintf(fid,'</%s>',fld{f});
  end
fprintf(fid,'</input>');
end

fld=fieldnames(Outputs);
for i = 1:nOutputs
fprintf(fid,'<output>');
  for f=1:length(fld)
    fprintf(fid,'<%s>',fld{f});
    fprintf(fid,'%s',getfield(Outputs,{i},fld{f}));
    fprintf(fid,'</%s>',fld{f});
  end
fprintf(fid,'</output>');
end
fprintf(fid,'</model>');

fclose(fid);

dos([' .\Waterspot\' ModelName '.xml']);