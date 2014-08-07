function varargout = ozoncc_f(option,varia1,varia2,varia3)
% ozoncc_f(option,varia1,varia2,varia3)
%   Functie voor afhandelen van blokafhankelijk gedrag in de
%   ParamterInputFigure.
%   Wordt aangeroepen door st_ParameterInput.m.
%
% Stimela, 2008

% © Kim van Schagen

% In UData wordt alles opgeslagen (userdata van deze figuur)
% UData.BlokNaam = Bloknaam
% Udata.Filenaam = Filenaam
% UData.handle(1) = FileNAam Handle
% UData.handle(2) = BlokNaam Handle
% UData.modif = Gewijzigd flag
% Udata.edit(:) = Editbox waarden Handles

option = upper(option);
varargout{1} = [];

% option switch
switch option
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Callback van de editvelden
  case 'WAARDE'
     % edit field changed
%    Invoer_fig=gcf;
%    UData=get(Invoer_fig,'UserData');
%    hEdit=UData.edit(varia1);
     
     
 case 'EXIT'
     % input field is closed
     
    
end % switch
