function d = functied_RZ(d0, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3, flag)
  % function to determine diameter based on iteration

  tol = 1e-6;
  iter = 0;
  itermax = 50;
  
  
  fnk = feval(@fnkdRZ,d0, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);

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
   fnka = feval(@fnkdRZ,da, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);
   df = (fnk - fnka)/(d - da);

   % Next approximation of the root
   if df==0
      d = d0 + 1.1*tol;
      warning('differentiation failed')
   else
      d = d0 - fnk/df;
   end
  
  fnk = feval(@fnkdRZ,d, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag);

     if d<dg
       d=dg;
   end

  
  end
  
if iter >= itermax
   warning('Maximimum iterations reached. x=',x)
end

function res = fnkdRZ(d, nu, rhow, v, dpdl, dg, rhog, rhoCaCO3,flag)
  g = 9.81;
  rhop = (rhog*dg^3+rhoCaCO3*(d^3-dg^3) )/d^3;
  p = 1-dpdl/((rhop-rhow)*g);

  nl=3.4;
  n=2.4;
  while abs(n-nl)>.001
   nl=n;    
    v0 = v/p^n;

    Re = v0*d/nu;
  
    if (Re<500);
      n=(4.4)*(Re^-0.1);
    else
      n=2.4;
    end
  end  
  
  switch flag
      case 0
       Cw = 24/Re*(1.0+0.15*(Re^0.687));
      case 1
       Cw = 24/Re*(1 + 0.0752121354307409*(Re^0.880220950948111));
      case 2
       Cw = 24/Re*(1 + 0.0703133122353068*(Re^0.89489568693569));
      case 3
       Cw = 24/Re*(1 + 0.0790784448728646*(Re^0.869705267565341));
  end

res = v0^2 / (4/3*(rhop-rhow)*g/(Cw*rhow))-d;
