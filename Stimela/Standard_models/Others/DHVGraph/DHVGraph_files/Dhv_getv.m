function [whostr, bytestr]= Dhv_getv(flag);
%  whostr= Dhv_getv;
%
%  Kimtools for figures 1993-1995
%

% © Kim van Schagen, 1-Aug-95 

% flag =0 zonder groottes
% flag =1 met grootte aanduiding in whostr
% flag =2 bytestr = groottes

if nargin <1,
  flag =1;
end;

whostr = [];
bytestr = [];

fid = fopen([cd '\tempfile.tmp'],'r');
whochoice =2;


ln = fgetl(fid);
while ln == ''
  ln = fgetl(fid);
end

if strcmp('Your variables are:',ln)
  whochoice = 1;
end;

if whochoice ==1,
  % inlezen
  lntot = [];
  ln = fgetl(fid);
  while ln == ''
    ln = fgetl(fid);
  end

  if ln ~=-1,
    lntot = ln;
    ln = fgetl(fid);

    while ln~=-1 & ln~='',
      lntot = str2mat(lntot,ln);
      ln = fgetl(fid);
    end;

    lntot = [lntot 32*ones(size(lntot,1),1) zeros(size(lntot,1),1)];

    % list maken


    if size(lntot,1)>1
      z = sum(abs(lntot))==size(lntot,1)*32;
    else
      z = abs(lntot)==size(lntot,1)*32;
    end
    p = find(z(1:length(z)-1)-z(2:length(z))>0);

    whostr = lntot(:,1:p(1));

    for tel = 2:length(p)
      str = lntot(:,p(tel-1)+1:p(tel));
      whostr = str2mat(whostr,str);
    end;
    ntel = [];
    for tel = 1:size(whostr,1),
      if ~length(Delspace(whostr(tel,:))),
        ntel = [ntel tel];
      end;
    end
    whostr(ntel,:) = [];
  end

elseif whochoice ==2,  %whos
  if ln ~=-1,
    lntot = [];
    ln = fgetl(fid);
    while ln == ''
      ln = fgetl(fid);
    end

    if ln ~=-1,
      lntot = ln;
      ln = fgetl(fid);

      while ln~=-1 & ln~='',
        lntot = str2mat(lntot,ln);
        ln = fgetl(fid);
      end;

      lntot = [lntot 32*ones(size(lntot,1),1) zeros(size(lntot,1),1)];

      % list maken
      tel = 1;
      z = abs(lntot(tel,:))==32;
      p = find(z(1:length(z)-1)-z(2:length(z))>0);
      pn= find(z(1:length(z)-1)-z(2:length(z))<0);

      str = lntot(tel,p(1)+1:pn(1));
      size1str = lntot(tel,p(2)+1:pn(2));
      size2str = lntot(tel,p(4)+1:pn(4));
      if flag == 2,
        bytestr = [eval(size1str) eval(size2str)];
      else
        bytestr = lntot(tel,p(6)+1:pn(6));
      end

      if flag==1,
        if eval(size1str)>1,
          if eval(size2str)>1,
            str = [str '(1:' size1str ',1:' size2str ')'];
          else
            str = [str '(1:' size1str ')'];
          end
        else
          if eval(size2str)>1,
            str = [str '(1:' size2str ')'];
          elseif eval(size1str)==0,
            str = [str '([])'];
          end
        end;
      end
      whostr = str;

      for tel = 2:size(lntot,1),
        z = abs(lntot(tel,:))==32;
        p = find(z(1:length(z)-1)-z(2:length(z))>0);
        pn = find(z(1:length(z)-1)-z(2:length(z))<0);

        str = lntot(tel,p(1)+1:pn(1));
        size1str = lntot(tel,p(2)+1:pn(2));
        size2str = lntot(tel,p(4)+1:pn(4));
        if flag ==2,
          bytestr = [bytestr; eval(size1str) eval(size2str)];
        else
          bytestr = str2mat(bytestr,lntot(tel,p(6)+1:pn(6)));
        end

        if flag ==1,
          if eval(size1str)>1,
            if eval(size2str)>1,
              str = [str '(1:' size1str ',1:' size2str ')'];
            else
              str = [str '(1:' size1str ')'];
            end
          else
            if eval(size2str)>1 & flag,
              str = [str '(1:' size2str ')'];
            elseif eval(size1str)==0 & flag,
              str = [str '([])'];
            end
          end;
        end
        whostr = str2mat(whostr,str);
      end  
    end
  end

end

fclose(fid);
delete tempfile.tmp



