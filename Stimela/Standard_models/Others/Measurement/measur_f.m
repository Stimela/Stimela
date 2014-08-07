function varargout = measur_f(option,varia1,varia2,varia3)
% measur_f(option,varia1,varia2,varia3)
%   Functie voor afhandelen van blokafhankelijk gedrag in de
%   ParamterInputFigure.
%   Wordt aangeroepen door st_ParameterInput.m.
%
% Stimela, 2004

% © Kim van Schagen,

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
    % Exit
  case 'EXIT'
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'UserData');
    BlokNaam = UData.BlokNaam;
    filenaam = get_pfil(BlokNaam);
    
    [Pn,Fn,ext]=Fileprop(filenaam);
    try
      set_param(UData.BlokHandle,'name',Fn);
    catch
    end
    
    
end % switch
