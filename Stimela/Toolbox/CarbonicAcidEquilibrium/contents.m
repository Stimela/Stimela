%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Version 6.5.10 (13 -09- 2009) 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% include file for Carbonic Acid  Equilibrium
%% concentrations in mmol/l

%% you can use  K values from the following function (included)
%%  [K1,K2,Kw,Ks] = KValues(Temp)
%%    Temperature in Kelvin

%% you can use the following function to determine Theoretical CaCO3 Crystalization potential (included)
%%   dCaCO3 = CE_TCCP(Ca,M,P,K1,K2,Kw,Ks,IonStregth)

%% you can use the following function to determine Activity (included)
%%   f = CE_Activity(IonStregth)

%% typical function : z = CE_xy_z(x,y,K1,K2,Kw)
%% for x,y,z use the following symbols (xy in this order!) :
%% pH, CO2, HCO3, CO3, M, P
%% x or z must be pH 

%% automatically generated from the following  5 equations
%% M=2*CO3+HCO3+OH-H3O
%% P=CO3-CO2+OH-H3O
%% K1*CO2=HCO3*H3O
%% K2*HCO3=CO3*H3O
%% Kw=H3O*OH


%% © 1999-2009, Kim van Schagen, Luuk Rietveld

