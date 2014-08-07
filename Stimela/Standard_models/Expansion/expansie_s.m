function [v,ECorstjens,ERealitymin2,EReality,ERealityplus2,stroming,F3,ECorstjensd,ERealitymin2d,ERealityd,ERealityplus2d] = expansie_versie2(filtmat,zeeffrac,vdiam,vlower,vupper,T,po)


%Je moet kunnen kiezen tussen zelf het materiaal en de fracties en vormfactoren ingeven
%of kiezen uit één van de mogelijkheden.



%Controleren of Matlab 5.3 wordt gedraaid of een andere versie

versie = findstr(version,'5.3'); %geeft de waarde 1 als er gedraaid wordt op matlab 5.3 anders is hij leeg
if isempty(versie)
   versie = 5.2;
end


% Invoer variabelen
vlower    = vlower/3600;
vupper    = vupper/3600;
vdiam     = vdiam/3600;
Temp      = T;
%po
%filtmat
%zeeffrac

%constanten
g         = 9.81;
rho_water = 1000;
viscosity = 497e-6/((Temp+42.5)^1.5);

%si   s(i+1)(si+s(i+1))^0.5  Zeef fracties, alleen de gemiddelde fractie, de laatste rij is van belang
Fractie=[...
2.0   2.24  2.118
1.8   2.0   1.898
1.6   1.8   1.697
1.4   1.6   1.497
1.25  1.4   1.323
1.12  1.25  1.184
1.0   1.12  1.058
0.9   1.0   0.949
0.8   0.9   0.848
0.71  0.8   0.754
0.63  0.71  0.669
0.56  0.63  0.594
0.5   0.56  0.529]*1e-3;

%zeef = {'2.0  - 2.24';'1.8  - 2.0 ';'1.6  - 1.8 ';'1.4  - 1.6 ';'1.25 - 1.4 ';'1.12 - 1.25';'1.0  - 1.12';'0.9  - 1.0 ';'0.8  - 0.9 ';'0.71 - 0.8 ';'0.63 - 0.71';'0.56 - 0.63';'0.5  - 0.56';'Zeef analyse'};

%Fractie=Fractie*1e-3;
%spec_diam = Fractie(zeeffrac,3);
%spec_diam = 1e-3;

%Van de volgende materialen zijn de vormfactoren gegeven voor de hierboven
%gegeven zeeffracties. De eerste rij is de vormfactor voor een laminaire stroming
%(Re<4.6), de tweede rij geeft de vormfactoren voor het eerste overgangsgebied bij 
%een laminair/turbulente stroming (4.6<Re<34) en de derde rij geeft de vormafactoren
%voor tweede overgangsgebied bij een laminair/turbulente stroming (Re>34).
%phi = [PhifL Phif1  Phif2]

% De keuze mogelijkheden van de materialen in filtmat:
% 1 = zand
% 2 = granaatzand
% 3 = gebroken grind
% 4 = magnetiet
% 5 = Wales antraciet
% 6 = Hydro antraciet

if filtmat == 1    %Zand
phi=[...
0.72   0.71   0.71
0.75   0.76   0.76
0.78   0.80   0.80
0.81   0.84   0.84
0.84   0.88   0.88
0.855  0.91   0.91
0.87   0.935  0.935
0.88   0.955  0.955
0.89   0.97   0.97
0.90   0.985  0.985
0.91   0.995  0.995
0.915  0.995  0.995
0.92   0.995  0.995];

rho_frac = 2640;

elseif filtmat == 2    %Granaatzand
phi=[...
0.72   0.71   0.71
0.75   0.76   0.76
0.78   0.80   0.80
0.81   0.84   0.84
0.84   0.88   0.88
0.855  0.91   0.91
0.87   0.935  0.935
0.88   0.955  0.955
0.89   0.97   0.97
0.90   0.985  0.985
0.91   0.995  0.995
0.915  0.995  0.995
0.92   0.995  0.995];

rho_frac = 4100;


elseif filtmat == 3  %gebroken grind
phi=[...
0.665  0.51   0.50
0.665  0.56   0.57
0.665  0.60   0.63
0.665  0.645  0.68
0.665  0.68   0.735
0.665  0.705  0.765
0.665  0.725  0.79
0.665  0.74   0.8
0.665  0.755  0.8
0.665  0.77   0.8
0.665  0.78   0.8
0.665  0.785  0.8
0.665  0.79   0.8];

rho_frac = 2630;

elseif filtmat == 4  %magnetiet
phi=[...
0.75   0.51   0.65
0.75   0.55   0.67
0.75   0.58   0.68
0.75   0.62   0.71
0.75   0.655  0.73
0.75   0.69   0.75
0.75   0.72   0.77
0.75   0.745  0.785
0.75   0.77   0.8
0.75   0.79   0.81
0.75   0.81   0.825
0.75   0.825  0.835
0.75   0.84   0.84];

rho_frac = 5040;

elseif filtmat == 5  %Wales antraciet
phi=[...
0.66   0.765  0.845
0.66   0.765  0.845
0.66   0.765  0.845
0.67   0.78   0.85
0.695  0.8    0.86
0.72   0.83   0.875
0.745  0.86   0.885
0.77   0.885  0.895
0.79   0.91   0.915
0.81   0.93   0.92
0.83   0.95   0.92
0.84   0.97   0.93
0.85   0.98   0.93];

rho_frac = 1410;

elseif filtmat == 6  %Hydro antraciet
phi=[...
0.36   0.44   0.5
0.43   0.51   0.56
0.48   0.56   0.62
0.53   0.62   0.67
0.57   0.66   0.705
0.59   0.69   0.72
0.61   0.70   0.73
0.62   0.715  0.74
0.63   0.73   0.75
0.63   0.74   0.75
0.64   0.75   0.75
0.65   0.75   0.76
0.65   0.76   0.76];

rho_frac = 1690;

else
   error
end


%phi       = 0.95;


%De expansie bij een verlopende snelheid

phi_str = 2; %phi stroming geeft aan of het laminair(1) overgangsgebied 1(2) of overgangsgebied 2(3) is.
tel = 0;
vverschil = vupper-vlower;
for velocity = vlower:vverschil/20:vupper
   tel = tel + 1;
   v(tel,1) = velocity;
   Re1(tel,1) = (v(tel,1) * phi(zeeffrac,phi_str) * Fractie(zeeffrac,3))/((1 - po) * viscosity);
   
   if Re1(tel,1) < 4.6
      a1 = 75;
      n1 = 1;
      phi_str = 1;
   elseif Re1(tel,1) < 34
      a1 = 61.5;
      n1 = 0.87;
      phi_str = 2;
    else
      a1 = 30;
      n1 = 0.67;
      phi_str = 3;
   end
   
   factor(tel,1) = (2.4 * viscosity^n1 * a1 * v(tel,1)^(2-n1))/(g * (phi(zeeffrac,phi_str) * Fractie(zeeffrac,3))^(n1+1) * (rho_frac/rho_water - 1));
   
   if versie == 1
      funpe = fsolve('funpe',0.1,optimset('Display','off'),factor(tel,1),n1);
   else versie ~= 1
      funpe = fsolve('funpe',0.1,foptions,[],factor(tel,1),n1);
   end
      
   fac(tel,1) = (funpe^3)/((1-funpe)^n1);
   pe(tel,1)  = funpe;
   stroming(tel,1) = phi_str;
   
   Re2(tel,1) = (v(tel,1) * phi(zeeffrac,phi_str) * Fractie(zeeffrac,3))/((1 - pe(tel,1)) * viscosity);
   if Re2(tel,1) < 4.6
      a2 = 75;
      n2 = 1;
      phi_str = 1;
   elseif Re2(tel,1) < 34
      a2 = 61.5;
      n2 = 0.87;
      phi_str = 2;
   else
      a2 = 30;
      n2 = 0.67;
      phi_str = 3;
   end
   
      
   if n1 ~= n2    
      
      factor(tel,1) = (2.4 * viscosity^n2 * a2 * v(tel,1)^(2-n2))/(g * (phi(zeeffrac,phi_str) * Fractie(zeeffrac,3))^(n2+1) * (rho_frac/rho_water - 1));
   
      if versie == 1
         funpe = fsolve('funpe',0.1,optimset('Display','off'),factor(tel,1),n2);
      else versie ~= 1
         funpe = fsolve('funpe',0.1,foptions,[],factor(tel,1),n2);
      end
   
      fac(tel,1) =  (funpe^3)/((1-funpe)^n2);
      pe(tel,1)  = funpe;
      stroming(tel,1) = phi_str;
   else
   end
end

%a=[factor fac pe]

v              = v*3600;
ECorstjens     = (pe./(1-pe))*100;
ERealitymin2   = ((pe-(po-0.02))./(1-pe))*100;
EReality       = ((pe-po)./(1-pe))*100;
ERealityplus2  = ((pe-(po+0.02))./(1-pe))*100;

t = 0;
for nul = 1:length(EReality)
   t = t + 1;
   if EReality(t,1) < 0
      EReality(t,1) = 0;
   else
   end
   if ERealitymin2(t,1) < 0
      ERealitymin2(t,1) = 0;
   else
   end
   if ERealityplus2(t,1) < 0
      ERealityplus2(t,1) = 0;
   else
   end
end


Expansiev = [v ECorstjens ERealitymin2 EReality ERealityplus2 stroming];


%%%%%%%%

%De expansie bij een verlopende diameter

%De verlopende vormfactor zit er nog niet in!!!!!!!

phi_str = 2;
tel2 = 0;
for diam = 1:length(Fractie)
   tel2 = tel2 + 1;
   %diam(tel2,1) = Fractie(tel2,3);
   %%% Reynolds kan zo niet
   Re1d(tel2,1) = (vdiam * phi(tel2,phi_str) * Fractie(tel2,3))/((1 - po) * viscosity);
   %Re1d(tel2,1) = (vdiam * phi_Filter(tel) * Fractie(tel2,3))/((1 - po) * viscosity);
   
   if Re1d(tel2,1) < 4.6
      a1 = 75;
      n1 = 1;
      phi_str = 1;
   elseif Re1d(tel2,1) < 34
      a1 = 61.5;
      n1 = 0.87;
      phi_str = 2;
   else
      a1 = 30;
      n1 = 0.67; 
      phi_str = 3;
   end
   
   %factord(tel2,1) = (2.4 * viscosity^n1 * a1 * vdiam^(2-n1))/(g * (phi_Filter(tel,p) * diam(tel2,1))^(n1+1) * (rho_frac/rho_water - 1));
   factord(tel2,1) = (2.4 * viscosity^n1 * a1 * vdiam^(2-n1))/(g * (phi(tel2,phi_str) * Fractie(tel2,3))^(n1+1) * (rho_frac/rho_water - 1));
   
   if versie == 1
      funped = fsolve('funpe',0.1,optimset('Display','off'),factord(tel2,1),n1);
   else versie ~= 1
      funped = fsolve('funpe',0.1,foptions,[],factord(tel2,1),n1);
   end

   facd(tel2,1) = (funped^3)/((1-funped)^n1);
   ped(tel2,1)  = funped;
   
   
   %Re2d(tel2,1) = (vdiam * phi_Filter(tel,p) * diam(tel2,1))/((1 - ped(tel2,1)) * viscosity);
   Re2d(tel2,1) = (vdiam * phi(tel2,phi_str) * Fractie(tel2,3))/((1 - ped(tel2,1)) * viscosity);
   if Re2d(tel2,1) < 4.6
      a2 = 75;
      n2 = 1;
      phi_str = 1;
   elseif Re2d(tel2,1) < 34
      a2 = 61.5;
      n2 = 0.87;
      phi_str = 2;
   else
      a2 = 30;
      n2 = 0.67; 
      phi_str = 3;
   end
   
      
   if n1 ~= n2    
      
      %factord(tel2,1) = (2.4 * viscosity^n2 * a2 * vdiam^(2-n2))/(g * (phi_Filter(tel,p) * diam(tel2,1))^(n2+1) * (rho_frac/rho_water - 1));
      factord(tel2,1) = (2.4 * viscosity^n2 * a2 * vdiam^(2-n2))/(g * (phi(tel2,phi_str) * Fractie(tel2,3))^(n2+1) * (rho_frac/rho_water - 1));
   
   
      if versie == 1
         funped = fsolve('funpe',0.1,optimset('Display','off'),factord(tel2,1),n2);
      else versie ~= 1
         funped = fsolve('funpe',0.1,foptions,[],factord(tel2,1),n2);
      end
   
      facd(tel2,1) =  (funped^3)/((1-funped)^n2);
      ped(tel2,1)  = funped;
   else
   end
  
end

%a=[factor fac pe]

vdiam           = vdiam*3600;
ECorstjensd     = (ped./(1-ped))*100;
ERealitymin2d   = ((ped-(po-0.02))./(1-ped))*100;
ERealityd       = ((ped-po)./(1-ped))*100;
ERealityplus2d  = ((ped-(po+0.02))./(1-ped))*100;

t = 0;
for nul = 1:length(ERealityd)
   t = t + 1;
   if ERealityd(t,1) < 0
      ERealityd(t,1) = 0;
   else
   end
   if ERealitymin2d(t,1) < 0
      ERealitymin2d(t,1) = 0;
   else
   end
   if ERealityplus2d(t,1) < 0
      ERealityplus2d(t,1) = 0;
   else
   end
end

F3 = Fractie(:,3);

Expansied = [F3 ECorstjensd ERealitymin2d ERealityd ERealityplus2d];
Expansied = flipud(Expansied);

%val = [v,ECorstjens,ERealitymin2,EReality,ERealityplus2,Fractie(:,3),ECorstjensd,ERealitymin2d,ERealityd,ERealityplus2d]
