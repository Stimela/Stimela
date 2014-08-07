/*
  ccemsi  
*/

#include "mex.h"
#include "simstruc.h"
#include <math.h>
#include "CarbonEq_v2.c" 

extern SimStruct *SS;

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))


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

    fid=fopen("ccemsi_s_c3.log","at");
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
 void ccemsi_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
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

  SIndex = log10(pow(f,8.0)*(CaTot*CO3)/Ks); 
  // Determine extra measurements
  // eg. sys(U.Number+1) = x(1)/P.Opp;
  
  sys[0] = SIndex;      // Langelier Index

}


/*
 * Mex Updates function
 *
 */
extern void ccemsi_Update(real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


/*
 *  Mex Derivatives function
 *
 */
 
 
void ccemsi_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
/*parameters */

}

