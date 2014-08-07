function p = functiep(p0, nu, rhow, rhop, v, d,flag)
  % function to determine porositeit based on iteration

  tol = 1e-3;
  iter = 0;
  itermax = 50;
  
  g = 9.81;
  
  Var2 = 3/4*v^2/g/d*rhow/(rhop-rhow);
    
  fnk = feval(@fnkP,p0,nu,v,d,rhop,flag)-Var2;

  p = p0;
  p0 = p + 1;

  % Main iteration loop
  while (abs(p - p0) > tol) & (iter <= itermax)
   iter = iter + 1;
   p0 = p;
   
   % Set dx for differentiation
   if p ~= 0
      dp = p*tol;
   else
      dp = tol;
   end
   
   % Differentiation
   pa = p - dp;  
   fnka  = feval(@fnkP,pa,nu,v,d,rhop,flag)-Var2;
   df = (fnk - fnka)/(p - pa);

   % Next approximation of the root
   if df==0
      p = p0 + 1.1*tol;
      warning('differentiation failed')
   else
      p = p0 - fnk/df;
   end
   
   if p<0.001
       p=0.001;
   end
   if p>0.999
       p=0.999;
   end
   
  fnk = feval(@fnkP,p,nu,v,d,rhop,flag)-Var2;
  % Show the results of calculation
  
  end
  
if iter >= itermax
   warning('Maximimum iterations reached. p=',p)
end


function res = fnkP(p, nu, v, d,rhop,flag)

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

res = p^3/Cd;

