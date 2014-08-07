function foundblckstr = UniqName(searchstr,beforestr,blocktype,blockpar)
% function foundblckstr = UniqName(searchstr,beforestr,blocktype,blockpar)
%
% UniqName searches the current Simulink-system for a certain block parameter value.
% Blockparameter values are converted to strings and compared with the concatenated
% searchstring: <beforestr><searchstr>. Block path names of blocks, other than the
% current block, are returned in the string <foundblckstr>.
% 
% searchstr: the string we're looking for
% beforestr: the string preceeding <searchstr>
% blocktype: the type of blocks to be investigated
% blockpar : the block parameter to be investigate
% foundblockstr : found blocks, each block between "", blocks seperated by one space
%
% Example: errstr = UniqName(FileNaam,'filenaam=''','SubSystem','OpenFcn');
%
% © Adriën van den Berge, 13/03/00

% Following comments are in Dutch and specifically meant for Stimela-toolbox purposes

     %	Haal de block-path-names van alle blokjes van het type SubSystem op
     testblocks = find_system(gcs, 'BlockType', blocktype);
     %	Haal van deze blokjes de waarde van parameter OpenFcn op
     %	(leeg als het blokje geen parameter OpenFcn heeft)
     bp = get_param(testblocks, blockpar);
     %	rows is het aantal gevonden SubSystems
     [rows,dummy]=size(testblocks);
     %	Initialisatie: error is leeg
     foundblckstr=[];
     
     %	Onderzoek alle gevonden SubSystems
     for tel=1:rows
        %	bp is van het type cell-structure > omzetten naar string
        bptext=char(bp(tel,:));
        %	bptext moet minstens even lang zijn als 'filenaam='(10)+lengte(searchstr)
        if length(bptext)>=length([beforestr searchstr])
           %	Bevat bptext de gezochte tekst?
           if bptext(1:length([beforestr searchstr]))==[beforestr searchstr]
              %	Heeft dit blok een block-path-name met andere lengte dan het huidige
              if length(char(testblocks(tel,:)))~=length(gcb)
                 %	Dit SubSystem heeft onze bestandsnaam al in gebruik: errorstring
                 foundblckstr=[foundblckstr '"' char(testblocks(tel,:)) '" '];
              %	De block-path-name is even lang, maar misschien niet ons blokje
              elseif char(testblocks(tel,:))~=gcb
                 %	Dit SubSystem heeft onze bestandsnaam al in gebruik: errorstring
      		     foundblckstr=[foundblckstr '"' char(testblocks(tel,:)) '" '];
         	  end % if
           end % if
        end % if
     end % for
  
