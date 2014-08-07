function [sys,x0,str,ts] = dhvgrp_s(t,x,u,flag,B,x0,U,P),
%  [sys,x0,str,ts] = dhvgrp_s(t,x,u,flag,B,x0,U,P),
%    Stimela S-Function
%
% t = time
% x = state vector, filled with continuous states (flag 1) or
%                      discrete states (flag 2)
% u = input vector
%
% P =  proces parameters, filled with dhvgrp_p.m and defined in dhvgrp_d.m
% B =  Model size, filled with dhvgrp_i.m,
% x0 = initial state, filled with dhvgrp_i.m,
% U = Translationstructure for inout vector, filled in uit Blok00_i.m.
%     Fields are determined by 'st_Varia'
%
% Stimela, 2004

% © Kim van Schagen,

% General purpose calculations
if any(abs(flag)==[1 2 3])

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: convert input vector to user names
  % eg. Temp = u(U.Temperature);
  % in the code it is also possible to use u(U.Temparature) directly.

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  name = P.name;
  dt = P.dt;
  ry = P.ry;
  PosF = P.PosF;
  Options = P.Options;
  Names=P.Names;
   
  dtt = Options(2);     % sample tijd
  nmax = Options(1);    % maximaal aantal punten
  timesc = 1;
  if length(Options)>3, % verekenen tijdschaal
    timesc = Options(4);
  end
  graf = 2;
  if length(Options)>4, % verekenen tijdschaal
    graf = Options(5);
  end

  % graf == 1 -> zonder naam
  % graf == 2 -> met naam
  % graf == 11 -> bar met x 1:length Names
  % graf == 12 -> bar met x Names

  if graf <10
    ng  = length(u);
  elseif graf <20
    ng = nmax;
  end
  
  titlebr=45; % hoogte titelbar
  nfs=10; % doorschuiven dt

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % optional: calculated values used for al flags
  % eg. TempArea = u(U.Temperature)/P.Area;

  %%%% <= MODEL-SPECIFIC  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end; % of any(abs(flag)==[1 2 3])


if flag == 1, % Continuous states derivative calculation

  % default derivative =0;
  sys = zeros(B.CStates,1);
  
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the derivatives of the continuous states
  % eg. sys(1) = (u(U.Temperature)-x(1))/P.Volume;

  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp('dhvgrp has complex or nan values in flag=1')
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==2, %discrete state determination

  % default next sample same states (length is B.DStates)
  sys = x(B.CStates+1:B.CStates+B.DStates);
    
  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fill sys with the state value on the next samplemoment (determined by
  % B.SampleTime)
  % eg. sys(1) = (x(1)+u(U.Temperature))/P.Volume;

  nu = length(u);   % aantal inputs

  fig = findobj('Type','figure','Name',P.name)';
  if length(fig)~=1
    close(fig);
    fig=makefig(t,u,P);    
  end
  userf = get(fig,'userdata'); % en geschikte userdata
  if length(userf)~=1+ng+1;
    close(fig);
    fig=makefig(t,u,P);    
  end

  h_fig=fig;
  userf = get(h_fig,'userdata'); % en geschikte userdata
  tprev = userf(1+ng+1);

  % namen
  if rem(graf,10)==2
    if size(Names,1)<nu
      for tel = size(Names,1)+1:nu,
        Names(tel,1:8) = sprintf('line %3d',tel);
      end
    end
  end


  % controle of figuur nog bruikbaar is
%   figs = get(0,'chil');
%   OK = 1;
%   if all(h_fig~=figs),  % is ie er nog
%     OK = 0;
%   elseif ~strcmp(get(h_fig,'name'),name), % met dezelfde naam
%     OK = 0;
%   else
%     userf = get(h_fig,'userdata'); % en geschikte userdata
%     if length(userf)~=ng+1,
%       OK = 0;
%     end
%   end
% 
  if (t-tprev)>dtt, % als figuur aanwezig en de tijd is verstreken

    ax = userf(1);
    if graf <10
      if all((t+dt/nfs)/timesc>get(ax,'xlim')),
        set(ax,'xlim',[t-(nfs-2)*dt/nfs t+2*dt/nfs]/timesc); %,'ylim',ry);
      end
      for tel = 1:nu,
        xd = get(userf(1+tel),'xdata');
        yd = get(userf(1+tel),'ydata');
        nx = length(xd);
        if nx>=nmax,
          xd = xd(nx-nmax+2:nx);
          yd = yd(nx-nmax+2:nx);
        end
        set(userf(1+tel),'xdata',[xd t/timesc],'ydata',[yd u(tel)]);
        if graf==2
          set(get(userf(1+tel),'userdata'),'position',[t/timesc u(tel)],'string',Names(tel,:));
        end
      end
    elseif graf <20
      yd = [zeros(1,nu); u(:)'; u(:)'; zeros(1,nu)];
      yd = yd(:);
      % dan data veranderen
      nn = get(userf(1+1),'userdata');
      nn2 = rem(nn,nmax)+1;
      set(userf(1+1),'userdata',nn2);

      set(userf(1+nn2),'ydata',yd);

      % dan verkleuren
      colv = rem(nn(1)+nmax:-1:nn(1)+1,nmax)+1;
      col = figcol(h_fig);
      for colt = 1:nmax
        set(userf(1+colv(colt)),'color',abs( col-([1 1 1]/(.5+.5*colt)) ) )
      end
    end

    userf(1+nu+1)=t;
    set(h_fig,'userdata',userf); % en geschikte userdata
  
  else
    ax = userf(1);
    if graf<10
      for tel = 1:nu
         set(userf(1+tel),'xdata',t/timesc,'ydata',u(tel));
      end
      set(ax,'xlim',[t t+dt]/timesc,'ylim',ry);
    elseif graf <20
      set(ax,'xlim',[0 nu+1]);
    end
  end


  drawnow;
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp('dhvgrp has complex or nan values in flag=2')
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag ==4, % next sample hit

  % is only called if the sample time equals -2
  %  e.g. sys = t+1;
  
elseif flag ==3, % output data determination

  % default equal to the input with zeros for extra measurements
  sys = [u(1:U.Number*B.WaterOut); zeros(B.Measurements,1)];

  %%%% MODEL-SPECIFIC => %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine output for calculated values
  % eg. sys(U.Temparature) = x(1);

  % Determine extra measurements
  % eg. sys(U.Number+1) = x(1)/P.Opp;
  
  %%%% <= MODEL-SPECIFIC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if any( (~isreal(sys)) | isnan(sys))
    disp('dhvgrp has complex or nan values in flag=3')
    sys((~isreal(sys))| isnan(sys))=0;
  end
  
elseif flag == 0
  % initialize Model
  % [cs,ds,out,in,,direct]
  sys = [B.CStates,B.DStates,U.Number*B.WaterOut+B.Measurements,U.Number*B.WaterIn+B.Setpoints, 0, B.Direct,1];
  ts = [B.SampleTime,1];
  str = 'dhvgrp';
  x0=[];
  
  UData.tprev=t;
  
  fig = findobj('Type','figure','Name',P.name)';
  if length(fig)~=1,
    close(fig);
  end
  
  mstr = '';
  ts = [-1,0];

else
    % If flag is anything else, no need to return anything
    % since this is a continuous system
    sys = [];
end



function h_fig=makefig(t,u,P)

  name = P.name;
  dt = P.dt;
  ry = P.ry;
  PosF = P.PosF;
  Options = P.Options;
  Names=P.Names;
   
  dtt = Options(2);     % sample tijd
  nmax = Options(1);    % maximaal aantal punten
  timesc = 1;
  if length(Options)>3, % verekenen tijdschaal
    timesc = Options(4);
  end
  graf = 2;
  if length(Options)>4, % verekenen tijdschaal
    graf = Options(5);
  end

  % graf == 1 -> zonder naam
  % graf == 2 -> met naam
  % graf == 11 -> bar met x 1:length Names
  % graf == 12 -> bar met x Names

  if graf <10
    ng  = length(u);
  elseif graf <20
    ng = nmax;
  end
  
  titlebr=45; % hoogte titelbar
  nfs=10; % doorschuiven dt

  nu=length(u);
  
  
    % namen
  if rem(graf,10)==2
    if size(Names,1)<nu
      for tel = size(Names,1)+1:nu,
        Names(tel,1:8) = sprintf('line %3d',tel);
      end
    end
  end

        [flag,fig] = figflag(name,0);
        if flag,
          close(fig);
        end
        Ps = Kimfigps(PosF);
        
        h_fig = figure('units','normalized','position',Ps,...
                     'name',name,...
                     'number','off');
        ax = axes('parent',h_fig);
        Mdhv;

        if graf <10
          set(ax,'box','on','xlim',[dt*floor(t/dt) dt*floor(t/dt)+dt]/timesc, ...
                  'ylim',ry, ...
                  'xgrid','on','ygrid','on',...
                  'xlimmode','man','ylimmode','man');
        elseif graf <20
          set(ax,'box','on','xlim',[0 nu+1], ...
                  'ylim',ry, ...
                  'xgrid','on','ygrid','on',...
                  'xlimmode','man','ylimmode','man');
          if graf == 12
            set(ax,'xtickmode','man','xtick',[1:nu])
            set(ax,'xticklabelmode','man','xticklabel',Names)
          end
        end
        title(name);
        cols = Dhv_defa(2.1);
        nc = size(cols,1);
        if graf < 10
          menufig =uimenu('label','visible lines');
          nf = (u~=0);

          onoff=['off';'on '];

          for tel = 1:nu,
            hl(tel) = line('parent',ax);
            set(hl(tel),'xdata',t/timesc,'ydata',u(tel),'visible',onoff(nf(tel)+1,:),...
                     'color',cols(rem((tel-1),nc)+1,:),'erasemode','none');
            hm(tel) = uimenu(menufig,'label',[Names(tel,:)],'check',onoff(nf(tel)+1,:),...
                       'userdata',hl(tel),'callback','Kimfigln');
          end

  
          if graf ==1
            axleg=Dhv_mleg(Names);
          elseif graf ==2
            for tel = 1:nu,
              ht(tel) = text('position',[t/timesc u(tel)],'visible',onoff(nf(tel)+1,:),...
                       'erasemode','back','verticalal','mid','horizontalal','left',...
                       'string',Names(tel,:),'color',cols(rem((tel-1),nc)+1,:),'interpreter','none');
              set(hl(tel),'userdata',ht(tel));
              set(hm(tel),'userdata',[hl(tel) ht(tel)])
            end
          end
        elseif graf <20
          for tel = 1:nmax
            hl(tel) = line('parent',ax);
            dx = .25;
            xd = [(1:nu)-dx;(1:nu)-dx;(1:nu)+dx;(1:nu)+dx];
            xd=xd(:);
            set(hl(tel),'xdata',xd,'ydata',zeros(4*nu,1),...
                      'erasemode','xor');
          end
          set(hl(1),'userdata',1);
        end
   
        set(h_fig,'userdata',[ax hl(:)' t]);

