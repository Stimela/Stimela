function h = Gcm
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

% huidige object of anders menu
if exist('gcbo'); % voor matlab 5.0
  h=gcbo;
else
  h = get(gcf,'currentmenu');
  if h==gcf,
    h = [];
  end
end

