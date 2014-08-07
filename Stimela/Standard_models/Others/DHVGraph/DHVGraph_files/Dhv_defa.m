function PO = Dhv_defa(flag);
%  Dhv_defa(flag);
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95

% binnen halen van de parameters
fOK=1;
eval('Mdhvdefs','fOK=0;');
if ~fOK
  disp('Invalid ''Mdhvdefs.m''-file. Delete or modify (Advanced-Figure-Config) file. Defaults used');
  TextSize = 10;
  LineColorOrder = get(0,'defaultaxescolororder');
  LineStyleOrder = str2mat('- ','-.','--',':');
  Name = 'Enter your name here';
  LineWidth = get(0,'defaultlinelinewidth');
  MarkerSize = get(0,'defaultlinemarkersize');
  DotSize = 15;
  ArrowWidth = get(0,'defaultlinelinewidth');
  ArrowSize = 10;
  ArrowAngle = 30;
  FreeWidth = get(0,'defaultlinelinewidth');
  ArcAngle = 45;
  ArcDist = 20;
else
  strlist = str2mat(str2mat('TextSize','LineColorOrder','LineStyleOrder',...
                            'Name','LineWidth','MarkerSize'),...
           'DotSize','ArrowWidth','ArrowSize','ArrowAngle','FreeWidth',...
           'ArcAngle','ArcDist');

  isstrlist = [0   0   1   1   0   0   0   0   0   0   0   0    0];
  llimg =     [1   Inf Inf 1   1   1   1   1   1   1   1   1    1];
  llimh =     [1   1   1   1   1   1   1   1   1   1   1   1    1];
  blimg =     [1   3   2   Inf 1   1   1   1   1   1   1   1    1];
  blimh =     [1   3   1   1   1   1   1   1   1   1   1   1    1];
  limg =      [Inf 1   Inf 256 Inf Inf Inf Inf Inf Inf Inf 360 Inf];
  limh =      [0   0  -Inf  32 0   0   0   0   0   0   0   -360  0];

  % check inputs
  for tel = find(flag==[2.4 2.1 2.3 2.2 2.8 2.8 2.5 2.6 2.6 2.6 2.7 2.9 2.9]);
    perr = 0;
    var = Delspace(strlist(tel,:));
    if exist(var)~=1,
      disp(['Erroneous input in MenuDHV config file: ''' var ''' not defined. Default used.']);
      perr =1;
    else
      eval(['varv = ' var ';'])
      if isstr(varv)~=isstrlist(tel),
        disp(['Erroneous input in MenuDHV config file: ''' var ''' invaled type. Default used.']);
        perr = 1;
      elseif ~any(size(varv)),
        disp(['Erroneous input in MenuDHV config file: ''' var ''' empty. Default used.']);
        perr = 1;
      elseif size(varv,1)>llimg(tel) | size(varv,1)<llimh(tel) | ... '
               size(varv,2)>blimg(tel) | size(varv,2)<blimh(tel)
        disp(['Erroneous input in MenuDHV config file: ''' var ''' invalid size. Default used.']);
        perr = 1;
      elseif any(any(real(varv) > limg(tel))) | any(any(real(varv) < limh(tel))),
        disp(['Erroneous input in MenuDHV config file: ''' var ''' invalid value(s). Default used.']);
        perr = 1;
      elseif tel == 3,
        if size(varv,2)==2,
          for tel2 = 1:size(varv,1),
            if any(varv(tel2,2)=='-.')
              if varv(tel2,1)~='-',
                perr=1;
              end
            elseif any(varv(tel2,2)==[ setstr(0) ' ']),
              if all(varv(tel2,1)~='-:+o*.x')
                perr=1;
              end
            else
              perr=1;
            end
          end
        else
          for tel2 = 1:size(varv,1),
            if all(varv(tel2,1)~='-:+o*.x')
              perr=1;
            end
          end
        end

        if perr
          disp(['Erroneous input in MenuDHV config file: ''' var ''' invalid value(s). Default used.']);
        end
      end
    end

    if perr,
      if tel ==1,
        TextSize = 10;
      elseif tel == 2,
        LineColorOrder = get(0,'defaultaxescolororder');
      elseif tel == 3,
        LineStyleOrder = str2mat('- ','-.','--',':');
      elseif tel == 4,
        Name = 'Enter your name here';
      elseif tel == 5,
        LineWidth = get(0,'defaultlinelinewidth');
      elseif tel == 6,
        MarkerSize = get(0,'defaultlinemarkersize');
      elseif tel == 7,
        DotSize = 15;
      elseif tel == 8,
        ArrowWidth = get(0,'defaultlinelinewidth');
      elseif tel == 9
        ArrowSize = 10;
      elseif tel == 10,
        ArrowAngle = 30;
      elseif tel == 11,
        FreeWidth = get(0,'defaultlinelinewidth');
      elseif tel == 12,
        ArcAngle = 45;
      elseif tel == 13,
        ArcDist  = 20;
      end
    end
  end
end

if flag ==2.1,
  PO = LineColorOrder;
elseif flag == 2.2,
  PO = Name;
elseif flag ==2.3,
  PO = LineStyleOrder;
elseif flag ==2.4,
  PO = TextSize;
elseif flag ==2.5,
  PO = DotSize;
elseif flag ==2.6,
  PO = [ArrowWidth,ArrowSize,ArrowAngle];
elseif flag ==2.7,
  PO = FreeWidth;
elseif flag == 2.8,
  PO = [LineWidth,MarkerSize];
elseif flag == 2.9
  PO = [ArcAngle,ArcDist];
end


