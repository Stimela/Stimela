function pH = findpH(fcnHndl,pH0,Var1,Var2,varargin)
  % function to determine pH based on iteration
  % to find the solution to fcnHndl(pH,Var1)=Var2
  tol = 1e-3;
  iter = 0;
  itermax = 50;
  
  fnk = feval(fcnHndl,pH0,Var1,varargin{:})-Var2;

  pH = pH0;
  pH0 = pH + 1;

  % Main iteration loop
  while any(abs(pH - pH0) > tol) & (iter <= itermax)
   iter = iter + 1;
   pH0 = pH;
   
   % Set dx for differentiation
   if pH ~= 0
      dpH = pH*tol;
   else
      dpH = tol;
   end
   
   % Differentiation
   pHa = pH - dpH;  fnka  = feval(fcnHndl,pHa,Var1,varargin{:})-Var2;
   df = (fnk - fnka)./(pH - pHa);

   % Next approximation of the root
   if df==0
      pH = pH0 + 1.1*tol;
      warning('differentiation failed')
   else
      pH = pH0 - fnk./df;
   end
   
   pH(pH<0)=0;
   pH(pH>14)=14;
   
  fnk = feval(fcnHndl,pH,Var1,varargin{:})-Var2;
  % Show the results of calculation
  
  end
  
if iter >= itermax
   error('Maximimum iterations reached. pH=')
end

