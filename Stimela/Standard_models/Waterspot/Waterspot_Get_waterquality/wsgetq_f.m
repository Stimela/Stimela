function varargout = wsgetq_f(option,varia1,varia2,varia3)
% wsgetq_f(option,varia1,varia2,varia3)
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
    % Waarde
  case 'WAARDE'
    Invoer_fig=gcf;
    UData=get(Invoer_fig,'UserData');
    hEdit=UData.edit(varia1);

    % bij wijziging WSTag ook FileNaam aanpassen.
    PInfo = get(hEdit,'UserData');
    if strcmp(PInfo.Name,'WSTag');
      % afwijkende tag naam. BEstandsnaam aanpassenen save flag zetten  
      UData.FileNaam=[st_StimelaDataDir get(hEdit,'String') '.mat'];
      set(UData.handle(1),'String',['File Name : ' get(hEdit,'String')]);

      UData.modif=1;

      set(Invoer_fig,'UserData',UData)
    end
  
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
