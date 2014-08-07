function copyBlocks(naam_dst,naam_src,totnaam_src)
% copyBlocks(DestinationBlockName,SourceBlockName)
%   SourceBlockName = string of 6 characters with existing blockname,
%            if SourceBlockName is ommited, the default block structure is taken
%   DestinationBlockName = string of 6 characters with the new blockname
%
% Stimela, 2004-2007

% © Kim van Schagen,

if nargin <2
  naam_src='block0';
end

if ~isstr(naam_dst)
  error('DestinationBlockName must be a string');
end
if ~isstr(naam_src)
  error('SourceBlockName must be a string');
end

if (length(naam_dst)~=6)
  error('DestinationBlockName must be a string of 6 characters');
end
if (length(naam_src)~=6)
  error('SourceBlockName must be a string of 6 characters');
end

% Alleen karakters en getallen zijn toegestaan
tt = find( (naam_dst<48) | (naam_dst>57 & naam_dst<65) | (naam_dst>65+25 & naam_dst<97) | (naam_dst>97+25) );
if length(tt)
  error(['These ' sprintf('%3de',tt) ' character(s) are not aloud in DestinationBlockName']);
end

tt = find( (naam_src<48) | (naam_src>57 & naam_src<65) | (naam_src>65+25 & naam_src<97) | (naam_src>97+25) );
if length(tt)
  error(['These ' sprintf('%3de',tt) ' character(s) are not aloud in SourceBlockName']);
end

if nargin <3
  pth = which([naam_src '_s.m']);
  if length(pth)==0
    error(['SourceBlock ''' naam_src ''' not found']);
  end
  %if findstr(pth,' ')
  %  error('function does not work if there are '' '' characters in the path');
  %end

  % paden toevoegen
  totnaam_src = [pth(1:length(pth)-10) ];
else
  totnaam_src = [totnaam_src '\'];
end

% copieren
cpy(totnaam_src, naam_src, naam_dst, '_s.m');
cpy(totnaam_src, naam_src, naam_dst, '_p.m');
cpy(totnaam_src, naam_src, naam_dst, '_i.m');
cpy(totnaam_src, naam_src, naam_dst, '_d.m');
cpy(totnaam_src, naam_src, naam_dst, '_g.m');
cpy(totnaam_src, naam_src, naam_dst, '_f.m');
if exist([totnaam_src naam_src '_f.jpg'])
  copyfile([totnaam_src naam_src '_f.jpg'], [naam_dst '_f.jpg'],'f');
end
cpymodel(totnaam_src, naam_src, naam_dst);

if exist([totnaam_src 'cfiles'])==7
  %pad maken
  if ~isdir([cd '\cfiles'])
    mkdir('cfiles')
  end
  % c files kopieren welke niet ??????_s zijn
  fs = dir([totnaam_src 'cfiles\*.c']);
  for i=1:length(fs)
    cp=1;
    if length(fs(i).name)>8
      if fs(i).name(7:8)=='_s'
        cp=0;
      end
    end
    if cp==1
      copyfile([totnaam_src 'cfiles\' fs(i).name],['cfiles\' fs(i).name],'f');
    end
  end
  cd cfiles
  cpy([totnaam_src 'cfiles\'], naam_src, naam_dst, '_s_c.c');
  cpy([totnaam_src 'cfiles\'], naam_src, naam_dst, '_s_code.c');
  cpy([totnaam_src 'cfiles\'], naam_src, naam_dst, '_compile.m');

  disp (' ');
  disp (['run ' naam_dst '_compile in the cfiles directory to create dll.']);
  disp (['replaces ' naam_dst '_s with ' naam_dst '_s_c to use c-version']);
  
  cd ..
end

% kopieren eigen functies
if exist([totnaam_src '\private'])==7
  mkdir('private')
  copyfile([totnaam_src '\private\*.*'],['\private'],'f')
end

function cpy(srcpth,src,dst,ext)
fid = fopen([srcpth,src,ext],'rt');
if fid>0
  M= fread(fid,inf,'char');
  fclose(fid);
  M = char(M(:)');
  M = strrep(M,src,dst);
  
  fid=fopen([cd '\' dst ext],'wt');
  fwrite(fid,M,'char');
  fclose(fid);
else
    disp(['No copy of ' src ext]);
end

function cpymodel(srcpth,src,dst,ext)

if strcmp(src,dst)
  % zelfde naam, dan niets aanpassen
  copyfile([srcpth src '_m.mdl'],[dst '_m.mdl'],'f')
else
  open_system([srcpth src '_m.mdl']);
  save_system([src '_m'],[dst '_m']);

  % eerst alle namen
  niets=0;
  while niets==0
    niets=1;
    sfuns = find_system([dst '_m'],'LookUnderMasks','all');
    for s=1:length(sfuns)
      ini = lower(get_param(sfuns{s},'Name'));
      if length(findstr(ini,src))>0
        ini=strrep(ini,src,dst);
        set_param(sfuns{s},'Name',ini);
        niets=0;
        %stoppen eerst weer namen ophalen
        break;
      end
    end
  end


  % dan alle andere parameters
  Pars = {'MaskInitialization','Description','OpenFcn','MaskDisplay','FileName','MatrixName','FunctionName'};
    sfuns = find_system([dst '_m'],'LookUnderMasks','all');
    for s=1:length(sfuns)
      for p=1:length(Pars);
        try
          ini = get_param(sfuns{s},Pars{p});
          if length(findstr(ini,src))>0
            ini=strrep(ini,src,dst);
            set_param(sfuns{s},Pars{p},ini);
          end
        catch
        end
      end
    end
  
  
    save_system([dst '_m']);
    close_system([dst '_m']);
    
end  