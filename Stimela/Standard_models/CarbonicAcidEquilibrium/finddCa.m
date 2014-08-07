function dCa = finddCa(fcnHndl,dCa0,Var1,Var2,varargin)
  % function to determine dCa based on iteration
  % to find the solution to fcnHndl(dCa,Var1)=Var2
  tol = 1e-4;
  iter = 0;
  itermax = 50;
  
  fnk = feval(fcnHndl,dCa0,Var1,varargin{:})-Var2;

  dCa = dCa0;
  dCa0 = dCa + 1;

  % Main iteration loop
  while any(abs(dCa - dCa0) > tol) & (iter <= itermax)
   iter = iter + 1;
   dCa0 = dCa;
   
   % Set dx for differentiation
   if dCa ~= 0
      ddCa = dCa*tol;
   else
      ddCa = tol;
   end
   
   % Differentiation
   dCaa = dCa - ddCa;  fnka  = feval(fcnHndl,dCaa,Var1,varargin{:})-Var2;
   df = (fnk - fnka)./(dCa - dCaa);
   
   % Next approximation of the root
   if df == 0
      dCa = dCa0 + 1.1*tol;
      warning('differentiation failed')
   else
      dCa = dCa0 - fnk./df;
   end
   
  fnk = feval(fcnHndl,dCa,Var1,varargin{:})-Var2;
  % Show the results of calculation
  
  end
  
if iter >= itermax
   error('Maximimum iterations reached.')
end

