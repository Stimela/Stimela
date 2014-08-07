function [direc,filenaam,ext,no] = Fileprop(naam)
%function [direc,filenaam,ext,no] = Fileprop(naam)
% eigenschappen van een filenaam worden terug gegeven
% wordt geen extensie aangegeven is de standaard extensie .mat
% wordt geen directory aangegeven is de directory de huidige directory
% no is het aantal vrije karakters in de naam = 8-lengte van filenaam

% © Kim van Schagen, 1-Aug-95

dirp = findstr(fliplr(naam),'.');
if length(dirp),
  ext = naam(length(naam)-dirp(1)+1:length(naam));
  naam = naam(1:length(naam)-dirp(1));
else
  ext = '.mat';
end

naam = strrep(naam,'\','/');
dirp = findstr(naam,'/');
if length(dirp),
  direc = naam(1:dirp(length(dirp)));
  naam = naam(dirp(length(dirp))+1:length(naam));
else
  direc = [cd '\'];
end

filenaam = naam;

no = 8-length(filenaam);
