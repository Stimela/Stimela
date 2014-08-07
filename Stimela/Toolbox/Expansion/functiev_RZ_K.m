function [v,x] = functiev_RZ_K(x0, nu, rhow, rhop, p, d,flag)
%p = functiev_RZ_K(x0, nu, rhow, rhop, p, d,flag)
% function to determine flow for porositeit

  tol = 1e-3;
  iter = 0;
  itermax = 50;
  
  g = 9.81;
  
  Var2 = 4/3*d.*(rhop-rhow).*g./rhow;
    
  fnk = feval(@fnkv,x0,d,nu,rhop,flag)-Var2;

  x = x0;
  x0 = x + 1;

  % Main iteration loop
  while any(abs(x - x0) > tol) & (iter <= itermax)
   iter = iter + 1;
   x0 = x;
   
   % Set dx for differentiation
   if x ~= 0
      dx = x*tol;
   else
      dx = tol;
   end
   
   % Differentiation
   xa = x - dx;  
   fnka  = feval(@fnkv,xa,d,nu,rhop,flag)-Var2;
   df = (fnk - fnka)./(x - xa);

   % Next approximation of the root
   if any(any(df==0))
      x(df==0) = x0(df==0) + 1.1*tol;
      x(df~=0) = x0(df~=0) - fnk(df~=0)./df(df~=0);
      warning('differentiation failed')
   else
      x = x0 - fnk./df;
   end
  
  fnk = feval(@fnkv,x,d,nu,rhop,flag)-Var2;
  % Show the results of calculation
  
  end
  
if iter >= itermax
   warning('Maximimum iterations reached. ')
end

  Re = x.*d./nu;
  n=2.4*ones(size(x));
  n(Re<500)=(4.4)*(Re(Re<500).^-0.1);

  v = x.*p.^n;



function res = fnkv(vb,d, nu,rhop, flag)

  Re = vb.*d./nu;
  switch flag
      case 0
       Cw = 24./Re.*(1.0+0.15*(Re.^0.687));
      case 1
       Cw = 24./Re.*(1 + 0.0752121354307409*(Re.^0.880220950948111));
      case 2
       Cw = 24./Re.*(1 + 0.0703133122353068*(Re.^0.89489568693569));
      case 3
       Cw = 24./Re.*(1 + 0.0790784448728646*(Re.^0.869705267565341));
      
  end
  
  res = Cw.*(vb.^2.0);
