function d = functied(d0, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3, flag)
  % function to determine diameter based on iteration

  tol = 1e-6;
  iter = 0;
  itermax = 50;

  fnk = feval(@fnkd, d0, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);

  d = d0;
  d0 = d + 1;

  % Main iteration loop
  while (abs(d - d0) > tol) & (iter <= itermax)
   iter = iter + 1;
   d0 = d;
   
   % Set dx for differentiation
   if d ~= 0
      dd = d*tol;
   else
      dd = tol;
   end
   
   % Differentiation
   da = d - dd;  
   fnka = feval(@fnkd, da, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);
   df = (fnk - fnka)/(d - da);

   % Next approximation of the root
   if df==0
      d = d0 + 1.1*tol;
      warning('differentiation failed')
   else
      d = d0 - fnk/df;
   end
   
   if d<dg
       d=dg;
   end
   
  fnk = feval(@fnkd, d, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);
  % Show the results of calculation
  
  end
  
if iter >= itermax
   warning('Maximimum iterations reached. d=',d)
end


function res = fnkd( d, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag)

  
  g = 9.81;
  rhop = (rhog*dg^3+rhoCaCO3*(d^3-dg^3) )/d^3;
  p = 1-dpdl/((rhop-rhow)*g);

Reh = 2/3*v*d/(1-p)/nu;
switch flag
  case -1
      %Monttgommery
    Cd =(130*4/3*(2/3)^.8)/Reh^0.8;
  case 0
    Cd = 2.3+150/Reh;
  case 1
    Cd = 2.8254366834061    + 104.437711880785/Reh; % granaat dichtheid 4100
  case 2
    Cd = 3.11820419105966   +  95.4047242279929/Reh; %granaat dichtheid 3900
  case 3
    Cd = 3.08350575983573   +  95.4047242279929/Reh; %granaat dichtheid 4100 aangepast dp
end 

res = 3/2*Cd*v^2/2*(1-p)/p^3*rhow/dpdl-d;



