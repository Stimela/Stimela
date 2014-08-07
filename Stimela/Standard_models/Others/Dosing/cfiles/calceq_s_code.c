/*
  calceq  
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

    fid=fopen("calceq_s_c3.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"//s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t//g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}

/*
 * Mex Output function
 *
 */
 void calceq_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
/*parameters */

double Temp, pH, EC, CO2, CO3, HCO3, CaTot, SO4, Mn, Pn, IS;
double TACCacc;
double   HCl , H2SO4 , DosCO2, NaOH ,  CaOH2 ,  Na2CO3 ,  CaCO3 ,  FeCl3 , Fe2SO43, Al2SO43;
double IS0, IB0, IS1;
double f;
double K1,K2,Kw,Ks;
double H3O,OH;
double IB1;
double SIndex ,TACC, Cuoplos,Pboplos;
double Caeq , Peq,  Meq , IBeq, feq, pHeq , CO3eq, HCO3eq, H3Oeq, OHeq, CO2eq, ISeq;
double Caeq1, Peq1, Meq1, IBeq1, feq1, pHeq1, CO3eq1, HCO3eq1, H3Oeq1, OHeq1, CO2eq1, ISeq1;
int swvalue;
int i;

  
  Temp        = u[U("Temperature")]+273.16;    // watertemperature           [Kelvin]
  pH          = u[U("pH")];                    //influent pH                 [-]
  EC          = u[U("Conductivity")];          //influent EC                 [mS/m]
  CO2         = u[U("Carbon_dioxide")]/44.0;     //influent concentratie CO2   [mmol/l]
  HCO3        = u[U("Bicarbonate")]/61.0;         //influent concentratie HCO3  [mmol/l]
  CaTot       = u[U("Calcium")]/40.0;            //influent concentratie Ca2+  [mmol/l]
  SO4         = u[U("Sulphate")]/96.0;           //influent concentratie SO4   [mmol/l]
  Mn           = u[U("Mnumber")];               //influent M alkalinity       [mmol/l]
  Pn           = u[U("Pnumber")];//               //influent P alkalinity       [mmol/l]
  IS          = u[U("Ionstrength")];//           //influent Ionstrenght        [mmol/l]
  
  TACCacc     = *P("TACCacc");
  
  // Dosing of chemicals
  HCl     = u[U("Number")+1];//                 //chemical dosing             [mmol/l]
  H2SO4   = u[U("Number")+2];
  DosCO2  = u[U("Number")+3];
  NaOH    = u[U("Number")+4];
  CaOH2   = u[U("Number")+5];
  Na2CO3  = u[U("Number")+6];
  CaCO3   = u[U("Number")+7];
  FeCl3   = u[U("Number")+8];
  Fe2SO43 = u[U("Number")+9];
  Al2SO43 = u[U("Number")+10];


  swvalue = (int) *P("ParIon");
  switch (swvalue)
  {
      case 1:
        IS0 = IS;
        break;
      default:
        IS0 = 0.183*EC;
  }
  
  f = CE_Activity(IS0);
  KValues(&K1,&K2,&Kw,&Ks,Temp);
  
  swvalue = (int) *P("ParEq");
  switch (swvalue)
  {
       case 2:
          // pH en M
          CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
          CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
          HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
          Pn=CE_pHM_P(pH,Mn,K1,K2,Kw,f);
          break;
       case 3:
          // pH en P
          CO2=CE_pHP_CO2(pH,Pn,K1,K2,Kw,f);
          CO3=CE_pHP_CO3(pH,Pn,K1,K2,Kw,f);
          HCO3=CE_pHP_HCO3(pH,Pn,K1,K2,Kw,f);
          Mn=CE_pHP_M(pH,Pn,K1,K2,Kw,f);
          break;
       case 4:
          // pH en CO2
          CO3=CE_pHCO2_CO3(pH,CO2,K1,K2,Kw,f);
          HCO3=CE_pHCO2_HCO3(pH,CO2,K1,K2,Kw,f);
          Mn=CE_pHCO2_M(pH,CO2,K1,K2,Kw,f);
          Pn=CE_pHCO2_P(pH,CO2,K1,K2,Kw,f);
          break;
       case 5:
          //M en P
          pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f,9);
          if (pH<0)
          {
            ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
          }
          CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
          CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
          HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
          break;
       default:
          // pH en HCO3
          CO2=CE_pHHCO3_CO2(pH,HCO3,K1,K2,Kw,f);
          CO3=CE_pHHCO3_CO3(pH,HCO3,K1,K2,Kw,f);
          Mn=CE_pHHCO3_M(pH,HCO3,K1,K2,Kw,f);
          Pn=CE_pHHCO3_P(pH,HCO3,K1,K2,Kw,f);
          break;
  }  
  H3O = pow(10,(3.0-pH))/f;
  OH = Kw/(pow(f,2.0)*H3O);
  IB0 = IS0 - (HCO3/2.0+2.0*CO3 +H3O/2.0 + OH/2.0);
  
  // Dosing
  IB1    = IB0 + 0.5*HCl+2.0*H2SO4+0.5*NaOH+2.0*CaOH2+Na2CO3+2.0*CaCO3+6.0*FeCl3+15.0*Fe2SO43+15.0*Al2SO43;
  CaTot = CaTot+CaOH2+CaCO3;
  Pn     = Pn-HCl-2.0*H2SO4-DosCO2+NaOH+2.0*CaOH2+Na2CO3+CaCO3-3.0*FeCl3-3.0*Fe2SO43-3.0*Al2SO43;
  Mn     = Mn-HCl-2.0*H2SO4+NaOH+2.0*CaOH2+2.0*Na2CO3+2.0*CaCO3-3.0*FeCl3-3.0*Fe2SO43-3.0*Al2SO43;
  SO4   = SO4+H2SO4+3.0*Fe2SO43+3.0*Al2SO43;
    
  pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f,pH);
  if (pH<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }
  CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O = pow(10,(3.0-pH))/f;
  OH = Kw/(pow(f,2.0)*H3O);  
  IS1 = IB1 + (2.0*CO3+HCO3/2.0 +H3O/2.0 + OH/2.0);
  f = CE_Activity(IS1);
  pH=CE_MP_pH(Mn,Pn,K1,K2,Kw,f,pH);
  if (pH<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }
  CO2=CE_pHM_CO2(pH,Mn,K1,K2,Kw,f);
  CO3=CE_pHM_CO3(pH,Mn,K1,K2,Kw,f);
  HCO3=CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f);
  H3O = pow(10,(3.0-pH))/f;
  OH = Kw/(pow(f,2.0)*H3O);
 
  IS1 = IB1 + (2.0*CO3+HCO3/2.0 +H3O/2.0 + OH/2.0);
  EC = IS1/0.183;

  //Determine the supersaturated calcium and the equilibrium pH
 //[CaSO4,Calcium]=freecalcium(CaTot,SO4,Uionsterkte,Temp);
  SIndex = log10(pow(f,8.0)*(CaTot*CO3)/Ks); 
    TACC = CE_TCCP(CaTot,Mn,Pn,K1,K2,Kw,Ks,IS1);
  Cuoplos= 0.52*(HCO3+CO2+CO3)-1.37*pH+2*SO4+10.2;
  Pboplos= -14.1*pH + 12.0*(Temp-273.16) + 1.135;

  Caeq  = CaTot-TACC;
  Peq   = Pn-TACC;
  Meq   = Mn-2.0*TACC;
  IBeq    = IB1-2.0*TACC;
  feq = CE_Activity(IS0);
  pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq,pH);
  if (pHeq<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }

  CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  H3Oeq = pow(10.0,(3.0-pHeq))/feq;
  OHeq  = Kw/(pow(feq,2.0)*H3Oeq);
 
  ISeq = IBeq + (2.0*CO3eq+HCO3eq/2.0 +H3Oeq/2.0 + OHeq/2.0);
  feq   = CE_Activity(ISeq);
  pHeq  =CE_MP_pH(Meq,Peq,K1,K2,Kw,feq,pHeq);
  if (pHeq<0)
  {
    ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
  }
  
  CO2eq =CE_pHM_CO2(pHeq,Meq,K1,K2,Kw,feq);
  CO3eq =CE_pHM_CO3(pHeq,Meq,K1,K2,Kw,feq);
  HCO3eq=CE_pHM_HCO3(pHeq,Meq,K1,K2,Kw,feq);
  H3Oeq = pow(10,(3.0-pHeq))/feq;
  OHeq  = Kw/(pow(feq,2.0)*H3Oeq);

  if (TACCacc!=0)
  {
    Caeq1  = CaTot-(TACC-TACCacc);
    Peq1   = Pn-(TACC-TACCacc);
    Meq1   = Mn-2.0*(TACC-TACCacc);
    IBeq1    = IB1-2.0*(TACC-TACCacc);
    ISeq1 = IBeq1 + Meq1;
    feq1   = CE_Activity(ISeq1);
    pHeq1  =CE_MP_pH(Meq1,Peq1,K1,K2,Kw,feq1,pHeq);
    if (pHeq1<0)
    {
      ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
    }

    CO2eq1 =CE_pHM_CO2(pHeq1,Meq1,K1,K2,Kw,feq1);
    CO3eq1 =CE_pHM_CO3(pHeq1,Meq1,K1,K2,Kw,feq1);
    HCO3eq1=CE_pHM_HCO3(pHeq1,Meq1,K1,K2,Kw,feq1);
    H3Oeq1 = pow(10,(3.0-pHeq1))/feq1;
    OHeq1  = Kw/(pow(feq1,2.0)*H3Oeq1);
 
    ISeq1 = IBeq1 + (2.0*CO3eq1+HCO3eq1/2.0 +H3Oeq1/2.0 + OHeq1/2.0);
    feq1   = CE_Activity(ISeq1);
    pHeq1  =CE_MP_pH(Meq1,Peq1,K1,K2,Kw,feq1,pHeq1);
    if (pHeq1<0)
    {
      ssSetErrorStatus(SS,"Error CE: pH Calculation based on M and P failed" );
    }
//    CO2eq1 =CE_pHM_CO2(pHeq1,Meq1,K1,K2,Kw,feq1);
//    CO3eq1 =CE_pHM_CO3(pHeq1,Meq1,K1,K2,Kw,feq1);
//    HCO3eq1=CE_pHM_HCO3(pHeq1,Meq1,K1,K2,Kw,feq1);
//    H3Oeq1 = pow(10,(3-pHeq1))/feq1;
//    OHeq1  = Kw/(pow(feq1,2)*H3Oeq1);
  }
  else
  {
    Caeq1=Caeq;
    pHeq1=pHeq;
  }
// direct feedthrough
  for (i=0;i<U("Number")+1;i++)
    sys[i]=u[i];
  for (i=0;i<B("Measurements");i++)
    sys[U("Number")+1+i]=0.0;


sys[U("pH")]                = pH;
sys[U("Mnumber")]           = Mn;            //effluent concentration [mmol/l]
sys[U("Pnumber")]           = Pn;            //effluent concentration [mmol/l]
sys[U("Carbon_dioxide")]    = CO2*44.0;        //effluent concentration [mg/l]
sys[U("Bicarbonate")]       = HCO3*61.0;       //effluent concentration [mg/l]
sys[U("Ionstrength")]       = IS1;            //effluent concentration [mmol/l]
sys[U("Calcium")]           = CaTot*40.0;      //effluent concentration [mg/l]
sys[U("Sulphate")]          = SO4*96.0;        //effluent concentration [mg/l]
sys[U("Conductivity")]      = EC;            //effluent concentration [mS/m]
  
  // Determine extra measurements
  // eg. sys(U.Number+1) = x(1)/P.Opp;
  
sys[U("Number")+1] = SIndex;      // Langelier Index
sys[U("Number")+2] = TACC;        // Supersaturated calcium carbonate (mmol/l)
sys[U("Number")+3] = Cuoplos;     // koperoplossend vermogen
sys[U("Number")+4] = Pboplos;     // loodoplossend vermogen
sys[U("Number")+5] = Caeq*40.0;     // Equilibrium calcium concentration (mg/l)
sys[U("Number")+6] = pHeq;        // Equilibrium pH
sys[U("Number")+7] = Caeq1*40.0;    // calcium concentration with accepted supersaturation (mg/l)
sys[U("Number")+8] = pHeq1;       // pH with accepted supersaturation

}


/*
 * Mex Updates function
 *
 */
extern void calceq_Update(real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


/*
 *  Mex Derivatives function
 *
 */
 
 
void calceq_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
/*parameters */

}

