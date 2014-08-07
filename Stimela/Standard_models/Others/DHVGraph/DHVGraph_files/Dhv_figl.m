function Dhv_figl(flag)
%  Dhv_figl(flag)
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95
if nargin <1,
 flag==1;
end;

if flag== 1, % load
    [filenm,pathnm] = uigetfile('*.m','Load figure m-file');
    if filenm,
      direc = cd;
      eval(['cd ' pathnm(1:length(pathnm)-1)]);
      eval(strtok(filenm,'.m'));
      eval(['cd ' direc])

      % en menu dhv laden
      Mdhv;
    end;

elseif flag == 2, % save
    OK = Dis_zoom;
    if OK,
      [filenm,pathnm] = uiputfile('*.m','Save figure m-file');
      Set_zoom
      if filenm,
        eval(['print -dmfile ' pathnm filenm ])
      end;
    end;

end;


