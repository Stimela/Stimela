/*
This is the C-version of the Stimela model Pelsof for pellet reactor softening.

 pelsof 7  : correct IS en M number in measurement
 pelsof 10 : Porositeit volgens Ergun
 pelsof 20 : Porositeit volgens Richardson Zaki
 pelsof 22 : diffusie met factor vermenigvuldiging

 pelsof 25 : zonder eKT,RF,Dc,Activity, met kT20 en aangepaste RZ(Fit)

 9 september 2008 :
 conus toegevoegd 

  
*/

#include "mex.h"
#include "simstruc.h"
#include <math.h>
#include "CarbonEq_v2.c"

extern SimStruct *SS;

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]

#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)

#define P(D)   mxGetPr(mxGetField(Pin,0,D))

/************* pelsof specific ****************/

double pi=3.14159265359;

double functiep_Ergun(double nu,double rhow,double rhop,double v,double d);
double functiep_RZ(double nu,double rhow,double rhop,double v,double d, int flag);


double MAX(double x, double y)
{
   if (x > y) return x;
    else return y;
}


double MIN(double x, double y)
{
   if (x < y) return x;
    else return y;
}

void DebugPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("pels25_s_c3.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}

/*
 * Mex Output function
 *
 */
 void pels25_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
/*parameters */
double d0,rhog,rhos,rhow,rhol,KT,KT20,TanAngle,Radius;
int NumCel;
/* u */
double Q,Temp,pH0,HCO30,Ca0,EC,NaOH,NGrains,NPellets,sl;
double Mgetal0,Pgetal0,IB0,Uionsterkteco,Factiefco;
double TempK,nu;

double d[20],rhop[20],pe[20],dX[20],S[20];
double Mgetal[20],Pgetal[20],pH[20],CO3[20],HCO3[20];
double CaCO3[20], mg[20], Ca[20], dP[20];
double DF[20], IB[20], Factief[20];
double Nc[20], Nt[20];
double deltaP, bedhoogte;
double mCa, mCaCO3, mHCO3, mNaOH;
double Ntot;
double KS, IoEc;
double K1,K2,Kw;
double FB, Sa;
double Df,Reh,Sc,Sh,kf;
double A[20];
double dP50;

int i;

/*molecular masses */
mCa = 40;
mCaCO3 = 40+12+3*16;
mHCO3 = 1+12+3*16;
mNaOH = 23+16+1;

Radius    = *P("Radius"); /* oppervlakte reactor */
TanAngle 	= *P("TanAngle"); /* conus */
d0	= *P("d0")/1000.0; /* initiele zand diameter */
rhog= *P("rhog"); /* dichtheid zand */
rhos= *P("rhos"); /* dichtheid caco3 */
rhol= *P("rhol");  /* dichtheid loog */
sl= *P("sl");     /* oplossing */
FB = *P("FB");
Df  = *P("Df");
KT20  = *P("KT20")/1000.0;     /* KT Invoer naar mmol*/
IoEc = *P("IoEc");

NumCel = (int) *P("NumCel"); /* aantal cellen */
 
if (NumCel > 20) NumCel=20;  /* Limit number of cells, because of limited memory allocation. */

// DebugPr(xC,6*NumCel);

Q=u[U("Flow")]/3600.0; /* water flow, limited to 200 m3/h */
Temp=u[U("Temperature")]; /* Temperature in oC, limited to 1 oC */
pH0=u[U("pH")]; /* influent pH between 6 and 9*/
Ca0=u[U("Calcium")]/mCa; /* influent calcium concentration (mmol/l) */
HCO30=u[U("Bicarbonate")]/mHCO3; /* influent HCO3 concentration (mmol/l) */
EC=u[U("Conductivity")]; /* influent electrical conductivity mS/m */

NaOH = 1E-3*u[U("Number")+1]/(u[U("Flow")]+1E-3*u[U("Number")+1])*sl*rhol/mNaOH*1E3; //1e3 voor mol/l -> mmol/l
//NGrains = MAX(u[U("Number")+2]*1000.0,0); // number of grains in
NGrains = u[U("Number")+2]*1000.0; // number of grains in
NPellets = MAX(u[U("Number")+3]*1000.0,0);  // number of pellets out

// change to  kg/s
NGrains = NGrains * rhog * (pi/6*d0*d0*d0); 
NPellets = NPellets * rhog * (pi/6*d0*d0*d0);

TempK = Temp + 273.15; /* Temperature in Kelvin */
nu = 4.97e-4 / (pow(Temp+42.5,3.0/2.0)); /* viscosity */
rhow = (0.2198670356299949E16/2199023255552.0+0.4769643019957967E16/281474976710656.0*Temp-0.4604215144723611E16/0.5764607523034235E18*Temp*Temp-212923669458047.0/0.4611686018427388E19*Temp*Temp*Temp+249253633739249.0/0.2361183241434823E22*Temp*Temp*Temp*Temp-0.5426481728272187E16/0.1934281311383407E26*Temp*Temp*Temp*Temp*Temp)/(1.0+0.4865285514884471E16/0.2882303761517117E18*Temp);

KT=pow(1.053,(Temp-20.0))*KT20;

Uionsterkteco=IoEc*EC; /* mmol/l benaderingsformule */
Factiefco = CE_Activity(Uionsterkteco);

KValues(&K1,&K2,&Kw,&KS,TempK);
Mgetal0 = CE_pHHCO3_M(pH0,HCO30,K1,K2,Kw,Factiefco);
Pgetal0 = CE_pHHCO3_P(pH0,HCO30,K1,K2,Kw,Factiefco);
//IS = IB + (2*CO3+HCO3/2 +H3O/2 + OH/2);
IB0 = Uionsterkteco - (HCO30/2) + NaOH/2 ; // aanname CO3 =0, H3O =0 OH =0 en Na+ bij basis sterkte op.

/*mixing */
Pgetal0 = Pgetal0+NaOH;
Mgetal0 = Mgetal0+NaOH;  

bedhoogte = 0;
/* reactor */
for (i=0; i < NumCel; i++) 
{
  //bedhoogte loopt langzaam op
  A[i]      = pi*pow(Radius+bedhoogte*TanAngle,2);

  Ca[i]     = xC[i];
  Mgetal[i] = xC[NumCel+i];
  Pgetal[i] = xC[2*NumCel+i];
  IB[i]     = xC[3*NumCel+i];
  CaCO3[i]  = xC[4*NumCel+i];
  mg[i]     = xC[5*NumCel+i];

  if (CaCO3[i]<0)
      CaCO3[i]=0.0;
  if (IB[i]<0)
      IB[i]=0.0;
  if (mg[i]<0.1)
      mg[i]=0.1;

  //pellet diameter
  //d[i]=pow( pow(d0,3) + 6.0/pi*CaCO3[i]/(rhos*Ng[i]),(1.0/3.0));
  d[i] = d0*pow((1+CaCO3[i]/mg[i]*rhog/rhos),(1.0/3.0));

  //pellet density
  //rhop[i]=(rhog*pow(d0,3)+rhos*(pow(d[i],3)-pow(d0,3)))/pow(d[i],3);
  rhop[i]=(CaCO3[i]+mg[i])/(CaCO3[i]/rhos + mg[i]/rhog);

  // porosity
  //pe[i]=functiep(nu,rhow,rhop[i],Q/A,d[i],Cd,nd);
  pe[i]=functiep_RZ(nu,rhow,rhop[i],Q/A[i],d[i],3);


  // bedheight
  //dX[i]=Ng[i]*pi/6.0*pow(d[i],3)/((1-pe[i])*A);
  dX[i] = (CaCO3[i]+mg[i])/(rhop[i]*(1.0-pe[i])*A[i]);

  //specific surface
  S[i]=6.0*(1-pe[i])/(d[i]);
  S[i] = S[i]/pe[i];
    
  //pressuredrop
  dP[i]=((1-pe[i])*dX[i])*(rhop[i]-rhow)/rhow;

  /* schatting met Factiefco */
  if (i==0)
    pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factiefco,9.0);
  else
    pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factiefco,pH[i-1]);

  if (pH[i]<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }

  CO3[i]=CE_pHM_CO3(pH[i],Mgetal[i],K1,K2,Kw,Factiefco);
  HCO3[i]=CE_pHM_HCO3(pH[i],Mgetal[i],K1,K2,Kw,Factiefco);

  Factief[i]=CE_Activity(IB[i] + HCO3[i]/2 + 2*CO3[i]);

  /* berekening Factief */
  pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factief[i],pH[i]);
  if (pH[i]<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }

  CO3[i]=CE_pHM_CO3(pH[i],Mgetal[i],K1,K2,Kw,Factief[i]);
  HCO3[i]=CE_pHM_HCO3(pH[i],Mgetal[i],K1,K2,Kw,Factief[i]);

  Sa = (Ca[i]*CO3[i]-KS/(pow(Factief[i],8.0)));

  //diffusie
  Reh = 2.0/3.0*Q/A[i]*d[i]/(1.0-pe[i])/nu;
  Sc = nu/Df;
  Sh = 0.66*pow(Reh,0.5)*pow(Sc,0.33);
  kf = Sh*Df/d[i];
    
  DF[i] = (KT*kf/(KT+kf))*S[i]*Sa;
	if (DF[i]<0)
		DF[i]=0;

  //totale hoogte
  bedhoogte = bedhoogte + dX[i];
}

/* doorschuiven pellets */
Ntot=mg[0];
Nc[0]=mg[0];
for (i=1; i < NumCel; i++) 
{
  Nc[i] = Nc[i-1]+mg[i];
  Ntot += mg[i];
}
for (i=0; i < NumCel; i++) 
{
  Nc[i] = Nc[i]/Ntot;
}
Nt[0] = NPellets;
for (i=1; i < NumCel; i++) 
{
  Nt[i] = (1-Nc[i-1])*NPellets + Nc[i-1]*NGrains;
}

/* Einde algemene berekeningen */

// direct feedthrough
  for (i=0;i<U("Number")+1;i++)
    sys[i]=u[i];
  for (i=0;i<B("Measurements");i++)
    sys[U("Number")+1+i]=0.0;

/* Stimela waterquality outputs */    
sys[U("pH")]=          pH[NumCel-1]; /* effluent pH */
sys[U("Calcium")]=     Ca[NumCel-1]*mCa; /* effluent calcium concentration (mg/l) */
sys[U("Bicarbonate")]= HCO3[NumCel-1]*mHCO3; /* effluent HCO3 concentration (mg/l) */
sys[U("Conductivity")]=(IB[NumCel-1] + 2*CO3[NumCel-1] + HCO3[NumCel-1]/2 )/IoEc; /* effluent electrical conductivity */
sys[U("Mnumber")]= Mgetal[NumCel-1];
sys[U("Pnumber")]= Pgetal[NumCel-1];


/* Additional outputs */
deltaP = 0;
//herbereken bedhoogte
bedhoogte = 0;
for (i=0; i < NumCel; i++)
{
    deltaP=deltaP+dP[i];
    bedhoogte = bedhoogte + dX[i];
    if (bedhoogte<0.75)
    {
      dP50 = deltaP/bedhoogte*0.5;
    }
   
    sys[U("Number")+1+NumCel+i]=d[i]*1000.0;     /* diameter van pellets over de hoogte in mm */
    sys[U("Number")+1+2*NumCel+i]=pe[i];        
    sys[U("Number")+1+3*NumCel+i]=dX[i];
    sys[U("Number")+1+4*NumCel+i]=pH[i];
    sys[U("Number")+1+5*NumCel+i]=dP[i];         /* drukval */
    sys[U("Number")+1+6*NumCel+i]=Q/A[i];        /* snelheid */
}

/* Important outputs */

sys[U("Number")+1+0] = deltaP; /* Total Pressure drop */
sys[U("Number")+1+1] = bedhoogte; /* Bedheight */
sys[U("Number")+1+2] = d[0]*1000.0; /* Released pellet diameter */
sys[U("Number")+1+3] = log10(Ca[NumCel-1]*CO3[NumCel-1]/(KS/pow(Factief[NumCel-1],8))); //SI
sys[U("Number")+1+4] = dP50; //DP50

/* Future important output? */
//  DebugPr(sys,U("Number")+1+6*NumCel);
}


/*
 * Mex Updates function
 *
 */
extern void pels25_Update(real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


/*
 *  Mex Derivatives function
 *
 */
 
 
void pels25_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
/*parameters */
double d0,rhog,rhos,rhow,rhol,KT,KT20,TanAngle,Radius;
int NumCel;
/* u */
double Q,Temp,pH0,HCO30,Ca0,EC,NaOH,NGrains,NPellets,sl;
double Mgetal0,Pgetal0,IB0,Uionsterkteco,Factiefco;
double TempK,nu;

double d[20],rhop[20],pe[20],dX[20],S[20];
double Mgetal[20],Pgetal[20],pH[20],CO3[20],HCO3[20];
double CaCO3[20], mg[20], Ca[20], dP[20];
double DF[20], IB[20], Factief[20];
double Nc[20], Nt[20];
double deltaP, bedhoogte;
double mCa, mCaCO3, mHCO3, mNaOH;
double Ntot;
double KS, IoEc;
double K1,K2,Kw;
double FB, Sa;
double Df,Reh,Sc,Sh,kf;
double A[20];


int i;

/*molecular masses */
mCa = 40;
mCaCO3 = 40+12+3*16;
mHCO3 = 1+12+3*16;
mNaOH = 23+16+1;

Radius    = *P("Radius"); /* oppervlakte reactor */
TanAngle 	= *P("TanAngle"); /* conus */
d0	= *P("d0")/1000.0; /* initiele zand diameter */
rhog= *P("rhog"); /* dichtheid zand */
rhos= *P("rhos"); /* dichtheid caco3 */
rhol= *P("rhol");  /* dichtheid loog */
sl= *P("sl");     /* oplossing */
FB = *P("FB");
Df  = *P("Df");
KT20  = *P("KT20")/1000.0;     /* KT Invoer naar mmol*/
IoEc = *P("IoEc");

NumCel = (int) *P("NumCel"); /* aantal cellen */
 
if (NumCel > 20) NumCel=20;  /* Limit number of cells, because of limited memory allocation. */

// DebugPr(xC,6*NumCel);

Q=u[U("Flow")]/3600.0; /* water flow, limited to 200 m3/h */
Temp=u[U("Temperature")]; /* Temperature in oC, limited to 1 oC */
pH0=u[U("pH")]; /* influent pH between 6 and 9*/
Ca0=u[U("Calcium")]/mCa; /* influent calcium concentration (mmol/l) */
HCO30=u[U("Bicarbonate")]/mHCO3; /* influent HCO3 concentration (mmol/l) */
EC=u[U("Conductivity")]; /* influent electrical conductivity mS/m */

NaOH = 1E-3*u[U("Number")+1]/(u[U("Flow")]+1E-3*u[U("Number")+1])*sl*rhol/mNaOH*1E3; //1e3 voor mol/l -> mmol/l
//NGrains = MAX(u[U("Number")+2]*1000.0,0); // number of grains in
NGrains = u[U("Number")+2]*1000.0; // number of grains in
NPellets = MAX(u[U("Number")+3]*1000.0,0);  // number of pellets out

// change to  kg/s
NGrains = NGrains * rhog * (pi/6*d0*d0*d0); 
NPellets = NPellets * rhog * (pi/6*d0*d0*d0);

TempK = Temp + 273.15; /* Temperature in Kelvin */
nu = 4.97e-4 / (pow(Temp+42.5,3.0/2.0)); /* viscosity */
rhow = (0.2198670356299949E16/2199023255552.0+0.4769643019957967E16/281474976710656.0*Temp-0.4604215144723611E16/0.5764607523034235E18*Temp*Temp-212923669458047.0/0.4611686018427388E19*Temp*Temp*Temp+249253633739249.0/0.2361183241434823E22*Temp*Temp*Temp*Temp-0.5426481728272187E16/0.1934281311383407E26*Temp*Temp*Temp*Temp*Temp)/(1.0+0.4865285514884471E16/0.2882303761517117E18*Temp);

KT=pow(1.053,(Temp-20.0))*KT20;

Uionsterkteco=IoEc*EC; /* mmol/l benaderingsformule */
Factiefco = CE_Activity(Uionsterkteco);

KValues(&K1,&K2,&Kw,&KS,TempK);
Mgetal0 = CE_pHHCO3_M(pH0,HCO30,K1,K2,Kw,Factiefco);
Pgetal0 = CE_pHHCO3_P(pH0,HCO30,K1,K2,Kw,Factiefco);
//IS = IB + (2*CO3+HCO3/2 +H3O/2 + OH/2);
IB0 = Uionsterkteco - (HCO30/2) + NaOH/2 ; // aanname CO3 =0, H3O =0 OH =0 en Na+ bij basis sterkte op.

/*mixing */
Pgetal0 = Pgetal0+NaOH;
Mgetal0 = Mgetal0+NaOH;  

bedhoogte = 0;
/* reactor */
for (i=0; i < NumCel; i++) 
{
  //bedhoogte loopt langzaam op
  A[i]      = pi*pow(Radius+bedhoogte*TanAngle,2);

  Ca[i]     = xC[i];
  Mgetal[i] = xC[NumCel+i];
  Pgetal[i] = xC[2*NumCel+i];
  IB[i]     = xC[3*NumCel+i];
  CaCO3[i]  = xC[4*NumCel+i];
  mg[i]     = xC[5*NumCel+i];

  if (CaCO3[i]<0)
      CaCO3[i]=0.0;
  if (IB[i]<0)
      IB[i]=0.0;
  if (mg[i]<0.1)
      mg[i]=0.1;

  //pellet diameter
  //d[i]=pow( pow(d0,3) + 6.0/pi*CaCO3[i]/(rhos*Ng[i]),(1.0/3.0));
  d[i] = d0*pow((1+CaCO3[i]/mg[i]*rhog/rhos),(1.0/3.0));

  //pellet density
  //rhop[i]=(rhog*pow(d0,3)+rhos*(pow(d[i],3)-pow(d0,3)))/pow(d[i],3);
  rhop[i]=(CaCO3[i]+mg[i])/(CaCO3[i]/rhos + mg[i]/rhog);

  // porosity
  //pe[i]=functiep(nu,rhow,rhop[i],Q/A,d[i],Cd,nd);
  pe[i]=functiep_RZ(nu,rhow,rhop[i],Q/A[i],d[i],3);


  // bedheight
  //dX[i]=Ng[i]*pi/6.0*pow(d[i],3)/((1-pe[i])*A);
  dX[i] = (CaCO3[i]+mg[i])/(rhop[i]*(1.0-pe[i])*A[i]);

  //specific surface
  S[i]=6.0*(1-pe[i])/(d[i]);
  S[i] = S[i]/pe[i];
    
  //pressuredrop
  dP[i]=((1-pe[i])*dX[i])*(rhop[i]-rhow)/rhow;


  /* schatting met Factiefco */
  if (i==0)
    pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factiefco,9.0);
  else
    pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factiefco,pH[i-1]);
  if (pH[i]<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }

  CO3[i]=CE_pHM_CO3(pH[i],Mgetal[i],K1,K2,Kw,Factiefco);
  HCO3[i]=CE_pHM_HCO3(pH[i],Mgetal[i],K1,K2,Kw,Factiefco);

  Factief[i]=CE_Activity(IB[i] + HCO3[i]/2 + 2*CO3[i]);

  /* berekening Factief */
  pH[i]=CE_MP_pH(Mgetal[i],Pgetal[i],K1,K2,Kw,Factief[i],pH[i]);
  if (pH[i]<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }

  CO3[i]=CE_pHM_CO3(pH[i],Mgetal[i],K1,K2,Kw,Factief[i]);
  HCO3[i]=CE_pHM_HCO3(pH[i],Mgetal[i],K1,K2,Kw,Factief[i]);

  Sa = (Ca[i]*CO3[i]-KS/(pow(Factief[i],8.0)));

  //diffusie
  Reh = 2.0/3.0*Q/A[i]*d[i]/(1.0-pe[i])/nu;
  Sc = nu/Df;
  Sh = 0.66*pow(Reh,0.5)*pow(Sc,0.33);
  kf = Sh*Df/d[i];
    
  DF[i] = (KT*kf/(KT+kf))*S[i]*Sa;
	if (DF[i]<0)
		DF[i]=0;

  //totale hoogte
  bedhoogte = bedhoogte + dX[i];
}

/* doorschuiven pellets */
Ntot=mg[0];
Nc[0]=mg[0];
for (i=1; i < NumCel; i++) 
{
  Nc[i] = Nc[i-1]+mg[i];
  Ntot += mg[i];
}
for (i=0; i < NumCel; i++) 
{
  Nc[i] = Nc[i]/Ntot;
}
Nt[0] = NPellets;
for (i=1; i < NumCel; i++) 
{
  Nt[i] = (1-Nc[i-1])*NPellets + Nc[i-1]*NGrains;
}

/* Einde algemene berekeningen */

/* mengcompartiment */
sys[0]        = Q/(A[0]*pe[0]*dX[0])*(Ca0-Ca[0])         -   DF[0];
sys[NumCel]   = Q/(A[0]*pe[0]*dX[0])*(Mgetal0-Mgetal[0]) - 2.0*DF[0];
sys[2*NumCel] = Q/(A[0]*pe[0]*dX[0])*(Pgetal0-Pgetal[0]) -   DF[0];
sys[3*NumCel] = Q/(A[0]*pe[0]*dX[0])*(IB0-IB[0])         - 2.0*DF[0];
if (FB==0)
{
  sys[4*NumCel] = (DF[0]*A[0]*pe[0]*dX[0]*mCaCO3)/1000.0;                  // /1000 voor omzetten naar kg
  if (Nt[0]>=0.0)
  {
    sys[4*NumCel] -= CaCO3[0]/mg[0]*Nt[0]; 
  }
  else
  {
    sys[4*NumCel] -= CaCO3[0]/mg[0]*Nt[0]; // toevoer van pellets met dezelfde diameter
  }
  //pellets van laag erboven
  if (Nt[1]>=0.0)
  {
    sys[4*NumCel] += CaCO3[1]/mg[1]*Nt[1]; 
  }
  else
  {
    sys[4*NumCel] += CaCO3[0]/mg[0]*Nt[1]; //pellets afvoeren uit huidige laag en niet erboven
  }
  sys[5*NumCel] = Nt[1]-Nt[0];
}
else
{
  sys[4*NumCel]=0;
  sys[5*NumCel]=0;
}
  
/* overige comparimenten */
for (i=1; i<NumCel-1; i++)
{
  sys[i]          = Q/(A[i]*pe[i]*dX[i])*(Ca[i-1]-Ca[i])         -   DF[i];
  sys[NumCel+i]   = Q/(A[i]*pe[i]*dX[i])*(Mgetal[i-1]-Mgetal[i]) - 2*DF[i];
  sys[2*NumCel+i] = Q/(A[i]*pe[i]*dX[i])*(Pgetal[i-1]-Pgetal[i]) -   DF[i];
  sys[3*NumCel+i] = Q/(A[i]*pe[i]*dX[i])*(IB[i-1]-IB[i])         - 2*DF[i];
  if (FB==0)
  {
    sys[4*NumCel+i] = (DF[i]*A[i]*pe[i]*dX[i]*mCaCO3)/1000.0;          // /1000 voor omzetten naar kg
    if (Nt[i]>=0.0)
    {
      sys[4*NumCel+i] -= CaCO3[i]/mg[i]*Nt[i]; 
    }
    else
    {
      sys[4*NumCel+i] -= CaCO3[i-1]/mg[i-1]*Nt[i]; 
    }
    if (Nt[i+1]>=0.0)
    {
      sys[4*NumCel+i] += CaCO3[i+1]/mg[i+1]*Nt[i+1]; 
    }
    else
    {
      sys[4*NumCel+i] += CaCO3[i]/mg[i]*Nt[i+1]; 
    }
    sys[5*NumCel+i] = Nt[i+1]-Nt[i];
  }
  else
  {
    sys[4*NumCel+i]=0;
    sys[5*NumCel+i]=0;
  }

}

i = NumCel-1;
  sys[i]          = Q/(A[i]*pe[i]*dX[i])*(Ca[i-1]-Ca[i])         -   DF[i];
  sys[NumCel+i]   = Q/(A[i]*pe[i]*dX[i])*(Mgetal[i-1]-Mgetal[i]) - 2*DF[i];
  sys[2*NumCel+i] = Q/(A[i]*pe[i]*dX[i])*(Pgetal[i-1]-Pgetal[i]) -   DF[i];
  sys[3*NumCel+i] = Q/(A[i]*pe[i]*dX[i])*(IB[i-1]-IB[i])         - 2*DF[i];

  if (FB==0)
  {
    sys[4*NumCel+i] = (DF[i]*A[i]*pe[i]*dX[i]*mCaCO3)/1000.0;          // /1000 voor omzetten naar kg
    if (Nt[i]>=0.0)
    {
      sys[4*NumCel+i] -= CaCO3[i]/mg[i]*Nt[i]; 
    }
    else
    {
      sys[4*NumCel+i] -= CaCO3[i-1]/mg[i-1]*Nt[i]; 
    }
    if (NGrains>=0.0)
    {
      sys[4*NumCel+i] += 0; 
    }
    else
    {
      sys[4*NumCel+i] += CaCO3[i]/mg[i]*NGrains; 
    }
    sys[5*NumCel+i] = NGrains - Nt[i];
  }
    else
    {
      sys[4*NumCel+i]=0;
      sys[5*NumCel+i]=0;
    }


}

double schatp0(double nu,double rhow,double rhop,double v,double d)
{
double a,b,c,e,z,val;

z = 13000.0/981.0*pow(nu,0.8)*rhow/(rhop-rhow)*pow(v,0.12E1)/pow(d,0.18E1);
a =	0.99102536;
b =	0.92787413;
c =	1.2143308;
e =	0.42408505;
val = a-b*exp(-c*pow(z,e));

val = MIN(1,MAX(0.41,val));
return val;
}


double fnkp(double p, double nu, double v, double d)
{
  double Reh;
  double Cd;
  double res;

  Reh = 2.0/3.0*v*d/(1.0-p)/nu;
  Cd = 2.3+150.0/Reh;
  res = pow(p,3.0)/Cd;

  return res;
}

double functiep_Ergun(double nu,double rhow,double rhop,double v,double d)
{
  // function to determine p based on iteration
  // to find the solution to fcnp(p)=Var2

  double pa, fnka, df,dp;

  double tol = 1e-3;
  int iter = 0;
  int itermax = 50;
  double fnk ;
  double Var2;
  double g;

  double p, p0;;

  g=9.81;


  Var2 = 3.0/4.0*pow(v,2.0)/g/d*rhow/(rhop-rhow);

  p0 = schatp0(nu,rhow,rhop,v,d);
  fnk = fnkp(p0,nu,v,d)-Var2;

  p=p0;
  p0 = p + 1;

  // Main iteration loop
  while ((fabs(p - p0) > tol) && (iter <= itermax))
  {
   iter = iter + 1;
   p0 = p;
   
   // Set dx for differentiation
   if (p != 0)
   {
      dp = p*tol;
	  }
   else
   {
      dp = tol;
	  }
   
   
   // Differentiation
   pa = p - dp;  
   fnka = fnkp(pa,nu,v,d)-Var2;
   df = (fnk - fnka)/(p - pa);
   
   // Next approximation of the root
   if (df == 0)
   {
      p = p0 + 1.1*tol;
      DebugPr("df=0" ,&p,1);
   }
   else
   {
      p = p0 - fnk/df;
   }
   
   if (p<0.001)
       p=0.001;
   if (p>0.999)
       p=0.999;

   fnk = fnkp(p,nu,v,d)-Var2;
   // Show the results of calculation
  
  }

  if (iter >= itermax)
    DebugPr("iter>itermax" ,&p,1);
  
  return p;
}

double fnkv(double vb, double d, double nu, int flag)
{
  double Re;
  double Cw;
  double res;

  Re = vb*d/nu;
  switch (flag)
  {
     case 0:
       Cw = 24.0/Re*(1.0 + 0.15*pow(Re,0.687));
       break;
     case 1 :
       Cw = 24.0/Re*(1.0 + 0.0752121354307409*pow(Re,0.880220950948111));
       break;
     case 2 :
       Cw = 24.0/Re*(1.0 + 0.0703133122353068*pow(Re,0.89489568693569));
       break;
     case 3 :
       Cw = 24.0/Re*(1.0 + 0.0790784448728646*pow(Re,0.869705267565341));
       break;
      
  }

  res = Cw*pow(vb,2.0);

  return res;
}


double functiep_RZ(double nu,double rhow,double rhop,double v,double d,int flag)
{
  // function to determine p based on iteration
  // to find the solution to fcnp(p)=Var2

  double xa, fnka, df,dx;

  double tol = 1e-3;
  int iter = 0;
  int itermax = 50;
  double fnk ;
  double Var2;
  double g;

  double x, x0;
  double Re, n;
  double p;


  g=9.81;

  x0=300.0/3600.0;

  Var2 = 4.0/3.0*d*(rhop-rhow)*g/rhow;

  fnk = fnkv(x0,d,nu,flag)-Var2;

  x=x0;
  x0 = x + 1;

  // Main iteration loop
  while ((fabs(x - x0) > tol) && (iter <= itermax))
  {
   iter = iter + 1;
   x0 = x;
   
   // Set dx for differentiation
   if (x != 0)
   {
      dx = x*tol;
	  }
   else
   {
      dx = tol;
	  }
   
   
   // Differentiation
   xa = x - dx;  
   fnka = fnkv(xa,d,nu,flag)-Var2;
   df = (fnk - fnka)/(x - xa);
   
   // Next approximation of the root
   if (df == 0)
   {
      x = x0 + 1.1*tol;
      DebugPr("df=0",&x,1);
	  p=iter;
      DebugPr("bij iter",&p,1);
   }
   else
   {
      x = x0 - fnk/df;
   }
   

   fnk = fnkv(x,d,nu,flag)-Var2;
   // Show the results of calculation
  
  }

  if (iter >= itermax)
  {
    DebugPr("iter >itermax",&x,1);
  }
  

  Re = x*d/nu;
  if (Re<500)
  {
    n=(4.4)*pow(Re,-0.1);
  }
  else
  {
    n=2.4;
  }

  p = pow(v/x,1.0/n);

  if (p<0.3)
  {
    p=0.1;

    ssSetErrorStatus(SS,"Error: Porosity below 0.3, model is used outside valid region." );
  }
  if (p>0.99)
  {
    DebugPr("porosity>0.99",&p,1);
    p=0.99;
  }

  //DebugPr("test p ",&p,1);
  return p;
}
