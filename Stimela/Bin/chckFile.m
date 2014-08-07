function filenaamEcht = chckFile(filenaam)
%function filenaamEcht = chckFile(filenaam)
% check naar de flenaam, eerst met volledig path, daarna in huidige directory
% geeft 0 terug als er geen filegevonden is.

[direc,naam,ext]=Fileprop(filenaam);

% inlezen naam, bij voorkeur in oorspronkelijke directory,
if exist([direc,naam,ext]),
  filenaamEcht=filenaam;
else
  % anders in huidige directory
  if ~exist([naam ext]),
    filenaamEcht=0;
  else
    % anders een leeg
    filenaamEcht=which([naam ext]);

  end
end

