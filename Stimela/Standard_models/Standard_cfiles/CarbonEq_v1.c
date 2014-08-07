// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Version 6.5.9 (14 -07- 2009) 
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// include file for Carbonic Acid  Equilibrium
// concentrations in mmol/l

// you can use  K values from the following function (included)
//  KValues(Temp,K1,K2,Kw,Ks)
//    Temperature in Kelvin

// you can use the following function to determine Theoretical CaCO3 Crystalization potential (included)
//   dCaCO3 = CE_TCCP(Ca,M,P,K1,K2,Kw,Ks,IonStregth)

// you can use the following function to determine Activity (included)
//   f = CE_Activity(IonStregth)

// typical function : z = CE_xy_z(x,y,K1,K2,Kw)
// for x,y,z use the following symbols (xy in this order!) :
// pH, CO2, HCO3, CO3, M, P
// x or z must be pH 

// automatically generated from the following  5 equations
// M=2*CO3+HCO3+OH-H3O
// P=CO3-CO2+OH-H3O
// K1*CO2=HCO3*H3O
// K2*HCO3=CO3*H3O
// Kw=H3O*OH


// © 1999-2009, Kim van Schagen, Luuk Rietveld


//declares:
double findpH(double (*fcnHndl)(double,double,double,double,double,double),double pH0, double Var1,double Var2,double K1,double K2,double Kw,double f);double finddCa(double dCa0, double pH0, double Ca, double M, double P, double K1,double K2,double Kw, double Ks, double f0, double IB0);

double CE_pHCO2_HCO3(double pH,double CO2,double K1,double K2,double Kw, double f)
{
// calculation of HCO3 using pH and CO2
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K1*CO2/H3O;
return t0;
}

double CE_pHCO2_CO3(double pH,double CO2,double K1,double K2,double Kw, double f)
{
// calculation of CO3 using pH and CO2
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K1*CO2*K2/(H3O*H3O);
return t0;
}

double CE_pHCO2_M(double pH,double CO2,double K1,double K2,double Kw, double f)
{
// calculation of M using pH and CO2
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-2.0*K1*CO2*K2-K1*CO2*H3O-Kw*H3O+H3O*H3O*H3O)/(H3O*H3O);
return t0;
}

double CE_pHCO2_P(double pH,double CO2,double K1,double K2,double Kw, double f)
{
// calculation of P using pH and CO2
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-K1*CO2*K2+CO2*H3O*H3O-Kw*H3O+H3O*H3O*H3O)/(H3O*H3O);
return t0;
}

double CE_pHCO2_OH(double pH,double CO2,double K1,double K2,double Kw, double f)
{
// calculation of OH using pH and CO2
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = Kw/H3O;
return t0;
}

double CE_pHHCO3_CO2(double pH,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of CO2 using pH and HCO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = HCO3*H3O/K1;
return t0;
}

double CE_pHHCO3_CO3(double pH,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of CO3 using pH and HCO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K2*HCO3/H3O;
return t0;
}

double CE_pHHCO3_M(double pH,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of M using pH and HCO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-2.0*K2*HCO3-HCO3*H3O-Kw+H3O*H3O)/H3O;
return t0;
}

double CE_pHHCO3_P(double pH,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of P using pH and HCO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-K1*K2*HCO3+HCO3*H3O*H3O-Kw*K1+H3O*H3O*K1)/H3O/K1;
return t0;
}

double CE_pHHCO3_OH(double pH,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of OH using pH and HCO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = Kw/H3O;
return t0;
}

double CE_pHCO3_CO2(double pH,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of CO2 using pH and CO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = CO3*H3O*H3O/K1/K2;
return t0;
}

double CE_pHCO3_HCO3(double pH,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of HCO3 using pH and CO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = CO3*H3O/K2;
return t0;
}

double CE_pHCO3_M(double pH,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of M using pH and CO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = (2.0*CO3*K2*H3O+CO3*H3O*H3O+Kw*K2-K2*H3O*H3O)/K2/H3O;
return t0;
}

double CE_pHCO3_P(double pH,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of P using pH and CO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-CO3*K1*K2*H3O+CO3*H3O*H3O*H3O-Kw*K1*K2+K1*K2*H3O*H3O)/K1/K2/H3O;
return t0;
}

double CE_pHCO3_OH(double pH,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of OH using pH and CO3
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = Kw/H3O;
return t0;
}

double CE_pHM_CO2(double pH,double M,double K1,double K2,double Kw, double f)
{
// calculation of CO2 using pH and M
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = (-Kw+H3O*M+H3O*H3O)/(2.0*K2+H3O)*H3O/K1;
return t0;
}

double CE_pHM_HCO3(double pH,double M,double K1,double K2,double Kw, double f)
{
// calculation of HCO3 using pH and M
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = (-Kw+H3O*M+H3O*H3O)/(2.0*K2+H3O);
return t0;
}

double CE_pHM_CO3(double pH,double M,double K1,double K2,double Kw, double f)
{
// calculation of CO3 using pH and M
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K2*(-Kw+H3O*M+H3O*H3O)/(2.0*K2+H3O)/H3O;
return t0;
}

double CE_pHM_P(double pH,double M,double K1,double K2,double Kw, double f)
{
// calculation of P using pH and M
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(-Kw*K1*K2-K1*K2*H3O*M+K1*K2*H3O*H3O-H3O*H3O*Kw+H3O*H3O*H3O*M+H3O*H3O*H3O*H3O-Kw*K1*H3O+H3O*H3O*H3O*K1)/(2.0*K2+H3O)/H3O/K1;
return t0;
}

double CE_pHM_OH(double pH,double M,double K1,double K2,double Kw, double f)
{
// calculation of OH using pH and M
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = Kw/H3O;
return t0;
}

double CE_pHP_CO2(double pH,double P,double K1,double K2,double Kw, double f)
{
// calculation of CO2 using pH and P
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -H3O*(P*H3O-Kw+H3O*H3O)/(-K2*K1+H3O*H3O);
return t0;
}

double CE_pHP_HCO3(double pH,double P,double K1,double K2,double Kw, double f)
{
// calculation of HCO3 using pH and P
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -K1*(P*H3O-Kw+H3O*H3O)/(-K2*K1+H3O*H3O);
return t0;
}

double CE_pHP_CO3(double pH,double P,double K1,double K2,double Kw, double f)
{
// calculation of CO3 using pH and P
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -K2*K1*(P*H3O-Kw+H3O*H3O)/(-K2*K1+H3O*H3O)/H3O;
return t0;
}

double CE_pHP_M(double pH,double P,double K1,double K2,double Kw, double f)
{
// calculation of M using pH and P
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = -(2.0*P*H3O*K2*K1-Kw*K1*K2+K1*K2*H3O*H3O+K1*H3O*H3O*P-Kw*K1*H3O+H3O*H3O*H3O*K1-H3O*H3O*Kw+H3O*H3O*H3O*H3O)/(-K2*K1+H3O*H3O)/H3O;
return t0;
}

double CE_pHP_OH(double pH,double P,double K1,double K2,double Kw, double f)
{
// calculation of OH using pH and P
double H3O,t0;
 H3O = pow(10,(3-pH))/f;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = Kw/H3O;
return t0;
}

double CE_CO2HCO3_pH(double CO2,double HCO3,double K1,double K2,double Kw, double f)
{
// calculation of pH using CO2 and HCO3
double t0;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K1*CO2/HCO3;
return 3.0-log10(t0*f);
}

double CE_CO2CO3_pH(double CO2,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of pH using CO2 and CO3
double t0;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = 1/CO3*sqrt(K1*CO2*K2*CO3);
return 3.0-log10(t0*f);
}

double CE_HCO3CO3_pH(double HCO3,double CO3,double K1,double K2,double Kw, double f)
{
// calculation of pH using HCO3 and CO3
double t0;
K1=K1/pow(f,2);K2=K2/pow(f,4);Kw=Kw/pow(f,2);
      t0 = K2*HCO3/CO3;
return 3.0-log10(t0*f);
}

double CE_CO2M_pH(double CO2,double M,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using CO2 and M
if (CO2>0)
  return findpH(CE_pHCO2_M,pH0,CO2,M,K1,K2,Kw,f);
else
  return findpH(CE_pHM_CO2,pH0,M,CO2,K1,K2,Kw,f);
}

double CE_CO2P_pH(double CO2,double P,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using CO2 and P
if (CO2>0)
  return findpH(CE_pHCO2_P,pH0,CO2,P,K1,K2,Kw,f);
else
  return findpH(CE_pHP_CO2,pH0,P,CO2,K1,K2,Kw,f);
}

double CE_HCO3M_pH(double HCO3,double M,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using HCO3 and M
if (HCO3>0)
  return findpH(CE_pHHCO3_M,pH0,HCO3,M,K1,K2,Kw,f);
else
  return findpH(CE_pHM_HCO3,pH0,M,HCO3,K1,K2,Kw,f);
}

double CE_HCO3P_pH(double HCO3,double P,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using HCO3 and P
if (HCO3>0)
  return findpH(CE_pHHCO3_P,pH0,HCO3,P,K1,K2,Kw,f);
else
  return findpH(CE_pHP_HCO3,pH0,P,HCO3,K1,K2,Kw,f);
}

double CE_CO3M_pH(double CO3,double M,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using CO3 and M
if (CO3>0)
  return findpH(CE_pHCO3_M,pH0,CO3,M,K1,K2,Kw,f);
else
  return findpH(CE_pHM_CO3,pH0,M,CO3,K1,K2,Kw,f);
}

double CE_CO3P_pH(double CO3,double P,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using CO3 and P
if (CO3>0)
  return findpH(CE_pHCO3_P,pH0,CO3,P,K1,K2,Kw,f);
else
  return findpH(CE_pHP_CO3,pH0,P,CO3,K1,K2,Kw,f);
}

double CE_MP_pH(double M,double P,double K1,double K2,double Kw,double f,double pH0)
{
// calculation of pH using M and P
if (M>0)
  return findpH(CE_pHM_P,pH0,M,P,K1,K2,Kw,f);
else
  return findpH(CE_pHP_M,pH0,P,M,K1,K2,Kw,f);
}



// standard functions for CarbonEw
double CE_Activity(double Uionsterkte)
{
  return pow(10,(-1.0*(0.5*sqrt(Uionsterkte)/ (sqrt(1.0E3)+sqrt(Uionsterkte))-0.00015*Uionsterkte)));
}


double fnkCa(double dCa, double pH0, double M, double P, double K1, double K2, double Kw, double Ks, double f0, double IB)
{
	double pH,HCO3,CO3,H3O,OH,IS,Ca,f;

M=M-2*dCa;
P=P-dCa;
IB=IB-2*dCa;
 
pH = CE_MP_pH(M,P,K1,K2,Kw,f0,pH0);
HCO3 = CE_pHM_HCO3(pH,M,K1,K2,Kw,f0);
CO3 = CE_pHM_CO3(pH,M,K1,K2,Kw,f0);
H3O = pow(10,(3-pH))/f0;
OH = Kw/(f0*f0*H3O);
 
IS = IB + (2*CO3+HCO3/2 +H3O/2 + OH/2);
f=CE_Activity(IS);
 
pH = CE_MP_pH(M,P,K1,K2,Kw,f,pH0);
HCO3 = CE_pHM_HCO3(pH,M,K1,K2,Kw,f);
CO3 = CE_pHM_CO3(pH,M,K1,K2,Kw,f);
H3O = pow(10,(3-pH))/f;
OH = Kw/(f*f0*H3O);
 
Ca = Ks/(pow(f,8))/CO3 + dCa;

return Ca;

}

double CE_TCCP(double Ca, double M, double P, double K1, double K2, double Kw, double Ks, double IS)
{
double pH0;
double f0, HCO3, CO3, H3O, OH, IB;

f0 = CE_Activity(IS);
pH0 = CE_MP_pH(M,P,K1,K2,Kw,f0,7);

HCO3 = CE_pHM_HCO3(pH0,M,K1,K2,Kw,f0);
CO3 = CE_pHM_CO3(pH0,M,K1,K2,Kw,f0);
H3O = pow(10,(3-pH0))/f0;
OH = Kw/(f0*f0*H3O);
 
IB = IS - (2*CO3+HCO3/2 +H3O/2 + OH/2);

return finddCa(0,pH0,Ca,M,P,K1,K2,Kw,Ks,f0,IB);
}



void KValues(double *K1, double *K2, double *KW, double *Ks, double TempK)
{
// Kvalues depending on activity
// default is activity 1

  *K1=pow(10,(3 - 356.3094 - 0.06091964*TempK + 21834.37/TempK + 126.8339*log10(TempK) - 1684915/(TempK*TempK))); // verg. (24)
  *K2=pow(10,(3 - 107.8871 - 0.03252849*TempK + 5151.79/TempK + 38.92561*log10(TempK) - 563713.9/(TempK*TempK))); // verg. (19)
  *KW=pow(10,(6 - 4787.3/TempK - 7.1321*log10(TempK) - 0.010365*TempK +22.801)); 
  *Ks=pow(10,(6 + 9.2536 - 0.032449*TempK - 2386.038/TempK));

 }
    
double findpH(double (*fcnHndl)(double,double,double,double,double,double),double pH0, double Var1,double Var2,double K1,double K2,double Kw,double f)
{
  // function to determine pH based on iteration
  // to find the solution to fcnHndl(pH,Var1)=Var2
//first guess only with M and P!!!!

  double pHa, fnka, df,dpH;

  double tol = 1e-3;
  int iter = 0;
  int itermax = 50;
  double fnk = ( *fcnHndl)(pH0,Var1,K1,K2,Kw,f)-Var2;

  double pH = pH0;
  pH0 = pH + 1;

  // Main iteration loop
  while ((fabs(pH - pH0) > tol) && (iter <= itermax))
  {
   iter = iter + 1;
   pH0 = pH;
   
   // Set dx for differentiation
   if (pH != 0)
   {
      dpH = pH*tol;
	  }
   else
   {
      dpH = tol;
	  }
   
   
   // Differentiation
   pHa = pH - dpH;  
   fnka = (*fcnHndl)(pHa,Var1,K1,K2,Kw,f)-Var2;
   df = (fnk - fnka)/(pH - pHa);
   
   // Next approximation of the root
   if (df == 0)
   {
      pH = pH0 + 1.1*tol;
     // warning('differentiation failed')
   }
   else
   {
      pH = pH0 - fnk/df;
	}
	
	   if (pH<0)
   {
     pH=0;
   }
   if (pH>14)
   {
     pH=14;
   }

   
  fnk = (*fcnHndl)(pH,Var1,K1,K2,Kw,f)-Var2;
  // Show the results of calculation
  
  }

  //if (iter >= itermax)
  //warning('Maximimum iterations reached. pH=',pH)
  //end
  return pH;
}


double finddCa(double dCa0, double pH0, double Ca, double M, double P, double K1,double K2,double Kw, double Ks, double f0,double IB0)
{
  // function to determine dCa based on iteration
  // to find the solution to fcnHndl(dCa,Var1)=Var2

  double dCaa, fnka, df,ddCa;

  double tol = 1e-3;
  int iter = 0;
  int itermax = 50;
  double fnk = fnkCa(dCa0,pH0,M,P,K1,K2,Kw,Ks,f0,IB0)-Ca;

  double dCa = dCa0;
  dCa0 = dCa + 1;

  // Main iteration loop
  while ((fabs(dCa - dCa0) > tol) && (iter <= itermax))
  {
   iter = iter + 1;
   dCa0 = dCa;
   
   // Set dx for differentiation
   if (dCa != 0)
   {
      ddCa = dCa*tol;
	  }
   else
   {
      ddCa = tol;
	  }
   
   
   // Differentiation
   dCaa = dCa - ddCa;  
   fnka = fnkCa(dCaa,pH0,M,P,K1,K2,Kw,Ks,f0,IB0)-Ca;
   df = (fnk - fnka)/(dCa - dCaa);
   
   // Next approximation of the root
   if (df == 0)
   {
      dCa = dCa0 + 1.1*tol;
     // warning('differentiation failed')
   }
   else
   {
      dCa = dCa0 - fnk/df;
	}
   
  fnk = fnkCa(dCa,pH0,M,P,K1,K2,Kw,Ks,f0,IB0)-Ca;
  // Show the results of calculation
  
  }

  //if (iter >= itermax)
  //warning('Maximimum iterations reached. dCa=',dCa)
  //end
  return dCa;
}

