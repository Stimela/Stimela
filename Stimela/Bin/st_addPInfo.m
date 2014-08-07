function PInfo = st_addPInfo(PInfo,Name,DefaultValue,MinValue, MaxValue, Unit,Description, ControlStyle)
% PInfo = st_addPInfo(PInfo,Name,DefaultValue,Unit,DEscription)
%    Add new PInfo entry. Used in _d
%
% Stimela, 2004

% © Kim van Schagen,

P.Name = Name;
P.DefaultValue = DefaultValue;
P.MinValue = MinValue;
P.MaxValue = MaxValue;
P.Unit = Unit;
P.Description = Description;

if nargin>7
  P.ControlStyle=ControlStyle;
  %edit,select
  % select box -> MinValue=description, MAxValue=Values as Strings
else
  P.ControlStyle='edit';
end  

PInfo = [PInfo;P];