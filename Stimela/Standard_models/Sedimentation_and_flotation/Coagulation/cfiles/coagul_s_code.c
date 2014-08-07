/*
This is the C-version of the Stimela coagul model.

*/
#include "mex.h"
#include <math.h>
//#include "StimelaFcns.c"
#include "CarbonEq_v1.c" 

extern  void StimelaSetErrorMessage(char * MyErrorMessage);
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))

void LogPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("coagul_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}


/************* coagul specific ****************/

/*
 * Mex Derivatives function
 *
 */
void coagul_Derivatives(real_T *sysC, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)

{


}

/*
 * Mex Updates function
 *
 */
extern void coagul_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;



}


/*
 *  Mex output function
 *
 */
 
void coagul_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{

double  Susp, Temp, Flow, DOC, UV, pH0, Dos, EC, Mn;
double FeCl3, Fe2SO43, Al2SO43; 
int NumCel;

double IS0, f, pH;  
double K1,K2,Kw,KS;
double CO2, CO3, HCO3, Pn, H3O, OH, IB0, IB1, IS1;
double Vol, G10, Ka, Kb,k1, k2, a1, a2, a3, b;
double TempK, nu, nu10, G, SUV, fN, DOCads, a;
double Suspcoag, ceq, DOCcoag, UVcoag;
//double noemer, teller;

//double *Solids, *Organics, *Absorbance;
  
  NumCel = 1;
  Vol    = *P("Volume");
  G10    = *P("G10");
  Ka     = *P("Ka");
  Kb     = *P("Kb");
  k1     = *P("k1");
  k2     = *P("k2");
  a1     = *P("a1");
  a2     = *P("a2");
  a3     = *P("a3");
  b      = *P("b");
   
  Susp   = uWQ[U("Suspended_solids")];   //mg/l
  Susp   = Susp/1000.0;               //kg/m3
  Temp   = uWQ[U("Temperature")];
  Flow   = uWQ[U("Flow")]/3600.0;
  DOC    = uWQ[U("DOC")];
  UV     = uWQ[U("UV254")];
  pH0     = uWQ[U("pH")];
  EC     = uWQ[U("Conductivity")];        // Electrical conductivity [mS/m]
  Mn     = uWQ[U("Mnumber")];             // m number [-]
  
  FeCl3  	= uES[7];       			 // Iron chloride dosing [mmol/L]
  Fe2SO43 	= uES[8];       			 // Iron sulfate dosing [mmol/L]
  Al2SO43 	= uES[9];       			 // aluminium sulfate dosing [mmol/L]

  //LogPr("DOC", &DOC,1);
  //LogPr("a1",&a1, 1);
  //LogPr("a2",&a2, 1);
  //LogPr("a3",&a3, 1);


  //Dos    = u(U.Number+1);           %coagulant dosing in mmol/l
  Dos = FeCl3+Fe2SO43+Al2SO43;
  //LogPr("Dos",&Dos,1);
  
  TempK	 = Temp +273.15;
  
  nu     = (497.0e-6)/pow((42.5+Temp),1.5);    // kinematic viscosity m2/s for 0oC until 35oC
  nu10   = (497.0e-6)/pow((42.5+10.0),1.5);
  G		 = G10*pow(nu10/nu,0.5);
  //LogPr("nu", &nu, 1); 
  
  IS0    = 0.183*EC;
  f      = CE_Activity(IS0);
  
  //LogPr("f",&f, 1);
  
  KValues(&K1,&K2,&Kw,&KS,TempK);
  
  //LogPr("K1", &K1, 1);
  //LogPr("K2", &K2, 1);
  //LogPr("Kw", &Kw, 1);
  //LogPr("KS", &KS, 1);
  
  CO2	 = CE_pHM_CO2(pH0,Mn,K1,K2,Kw,f);
  
  //LogPr("CO2", &CO2, 1);
  
  CO3	 = CE_pHM_CO3(pH0,Mn,K1,K2,Kw,f);
  HCO3	 = CE_pHM_HCO3(pH0,Mn,K1,K2,Kw,f);
  Pn	 = CE_pHM_P(pH0,Mn,K1,K2,Kw,f);
  H3O 	 = pow(10.0,(3.0-pH0))/f;
  OH 	 = Kw/((pow(f,2.0))*H3O);
  IB0 	 = IS0 - (HCO3/2.0+2.0*CO3 +H3O/2.0 + OH/2.0);
  
  //LogPr("Pn-1", &Pn, 1);
  //LogPr("Mn-1", &Mn, 1);
  
  IB1    = IB0 + 6.0*FeCl3+15.0*Fe2SO43+15.0*Al2SO43;
  Pn     = Pn-3.0*FeCl3-3.0*Fe2SO43-3.0*Al2SO43;
  Mn     = Mn-3.0*FeCl3-3.0*Fe2SO43-3.0*Al2SO43;
  
  //LogPr("Pn", &Pn, 1);
  //LogPr("Mn", &Mn, 1);
     
  pH	 = CE_MP_pH(Mn,Pn,K1,K2,Kw,f,pH0);
  CO2	 = CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3	 = CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3	 = CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O 	 = pow(10.0,(3.0-pH))/f;
  OH 	 = Kw/((pow(f,2.0))*H3O);
  
  IS1 	 = IB1 + (2.0*CO3+HCO3/2.0 +H3O/2.0 + OH/2.0);
  f 	 = CE_Activity(IS1);
  pH	 = CE_MP_pH(Mn,Pn,K1,K2,Kw,f,pH0);
  CO2	 = CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3	 = CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3	 = CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O 	 = pow(10.0,(3.0-pH))/f;
  OH 	 = Kw/((pow(f,2.0))*H3O);
  IS1 	 = IB1 + (2.0*CO3+HCO3/2.0 +H3O/2.0 + OH/2.0);
  
  EC 	 = IS1/0.183;



  
  SUV	 = UV/DOC;
  fN	 = k1*SUV+k2;
  DOCads = (1.0-fN)*DOC;
  
  //LogPr("pH", &pH, 1);
  
  //LogPr("DOCads", &DOCads,1);
  a 	 = a1*pH+a2*pow(pH,2.0)+a3*pow(pH,3.0);
  //LogPr("a",&a,1);
  

  
  
  //LogPr("DOC",&DOC, 1);
  //LogPr("Susp",&Susp, 1);
  //translation x into actual names
  //Solids   = &xC[0];
  //Organics = &xC[NumCel];
  //Absorbance= &xC[2*NumCel];


  //Suspcoag=(1+Dos*Kb*G^2*(Vol/Flow))/(1+Dos*Ka*G*(Vol/Flow))*Susp;  
  Suspcoag=(1.0+Dos*Kb*pow(G,2.0)*(Vol/Flow))/(1.0+Dos*Ka*G*(Vol/Flow))*Susp; 
  //LogPr("noemer",&noemer, 1);
  //LogPr("teller",&teller, 1);
  //LogPr("Suspcoag",&Suspcoag, 1);
 
  //ceq=((1-b*DOCads+Dos*a*b)-(((1-b*DOCads+Dos*a*b)^2+4*b*DOCads))^0.5)/(-2*b);
  ceq=((1.0-b*DOCads+Dos*a*b)-pow((pow((1.0-b*DOCads+Dos*a*b),2.0)+4.0*b*DOCads),0.5))/(-2.0*b);
  //test1=(1.0-b*DOCads+Dos*a*b);
  
  //LogPr("ceq",&ceq, 1);
  //LogPr("test1",&test1, 1);
  
  DOCcoag = ceq+fN*DOC;
  UVcoag = (DOCcoag/DOC)*UV;  
  
  sysWQ[U("Suspended_solids")]=Suspcoag*1000.0; 
  sysWQ[U("DOC")]= DOCcoag;
  sysWQ[U("UV254")]= UVcoag; 
  sysWQ[U("Conductivity")]=EC; 
  sysWQ[U("pH")]=pH; 
  sysWQ[U("Mnumber")]=Mn; 

    
  //LogPr("sysEM",sysEM,NumCel);

};

