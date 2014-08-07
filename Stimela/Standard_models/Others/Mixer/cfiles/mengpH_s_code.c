/*
This is the C-version of the Stimela mixer model.

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

/*
 * Mex Output function
 *
 */
 void mengpH_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
double  Debiet1,Temp1,EC1,Mgetal1,pH1,Ca1,TempK1,Uionsterkte1,Factiviteit1,Pgetal1,HCO31,Uionbasissterkte1;
double  Debiet2,Temp2,EC2,Mgetal2,pH2,Ca2,TempK2,Uionsterkte2,Factiviteit2,Pgetal2,HCO32,Uionbasissterkte2;
double  Mgetal,Pgetal,HCO3,CO3,pH,Ca,Factiviteit,TempK,Uionbasissterkte,Uionsterkte;
int i;

double mCa, mCaCO3, mHCO3, mNaOH;
double K1,K2,Kw,Ks;

/*molecular masses */
mCa = 40;
mCaCO3 = 40+12+3*16;
mHCO3 = 1+12+3*16;
mNaOH = 23+16+1;

  Debiet1=u[U("Flow")];
  Temp1 = u[U("Temperature")];
  EC1 = u[U("Conductivity")];
  HCO31= u[U("Bicarbonate")]/mHCO3;
  pH1 = u[U("pH")];
  Ca1 = u[U("Calcium")]/mCa;
  TempK1=273.15+Temp1;
  Uionsterkte1=0.183*EC1;

  /* berekeningen 1*/
  KValues(&K1,&K2,&Kw,&Ks,TempK1);
  Factiviteit1 = CE_Activity(Uionsterkte1);
  Mgetal1 = CE_pHHCO3_M(pH1,HCO31,K1,K2,Kw,Factiviteit1);
  Pgetal1 = CE_pHHCO3_P(pH1,HCO31,K1,K2,Kw,Factiviteit1);
  Uionbasissterkte1 = Uionsterkte1- 2* HCO31;

  Debiet2=u[U("Number") + 1 + U("Flow")];
  Temp2 = u[U("Number") + 1 + U("Temperature")];
  EC2 =   u[U("Number") + 1 + U("Conductivity")];
  HCO32= u[U("Number") + 1 + U("Bicarbonate")]/mHCO3;
  pH2 = u[U("Number") + 1 + U("pH")];
  Ca2 = u[U("Number") + 1 + U("Calcium")]/mCa;
  TempK2=273.15+Temp2;
  Uionsterkte2=0.183*EC2;

  /* berekeningen 2*/
  KValues(&K1,&K2,&Kw,&Ks,TempK2);
  Factiviteit2 = CE_Activity(Uionsterkte2);
  Mgetal2 = CE_pHHCO3_M(pH2,HCO32,K1,K2,Kw,Factiviteit2);
  Pgetal2 = CE_pHHCO3_P(pH2,HCO32,K1,K2,Kw,Factiviteit2);
  Uionbasissterkte2 = Uionsterkte2- 2* HCO32;
 
   
  // direct feedthrough
  for (i=0;i<U("Number")+1;i++)
    sys[i]=u[i];
    
  if ((Debiet1+Debiet2)>0)
  {  
        for (i=0; i<U("Number")+1; i++)
             sys[i]=(u[i]*Debiet1+u[U("Number")+1+i]*Debiet2)/(Debiet1+Debiet2);
             
      Uionbasissterkte=(Uionbasissterkte1*Debiet1+Uionbasissterkte2*Debiet2)/(Debiet1+Debiet2);
      Mgetal=(Mgetal1*Debiet1+Mgetal2*Debiet2)/(Debiet1+Debiet2);
      Pgetal=(Pgetal1*Debiet1+Pgetal2*Debiet2)/(Debiet1+Debiet2);
      Ca=(Ca1*Debiet1+Ca2*Debiet2)/(Debiet1+Debiet2);
      TempK = (TempK1*Debiet1+TempK2*Debiet2)/(Debiet1+Debiet2);

      KValues(&K1,&K2,&Kw,&Ks,TempK);

      Uionsterkte = (Uionsterkte1*Debiet1+Uionsterkte2*Debiet2)/(Debiet1+Debiet2);
      Factiviteit = CE_Activity(Uionsterkte);

      pH = CE_MP_pH(Mgetal,Pgetal,K1,K2,Kw,Factiviteit,pH1);
      HCO3 = CE_pHM_HCO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      CO3 = CE_pHM_CO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      Uionsterkte = Uionbasissterkte + 2*HCO3 +CO3/2;

      Factiviteit = CE_Activity(Uionsterkte);
      pH = CE_MP_pH(Mgetal,Pgetal,K1,K2,Kw,Factiviteit,pH);
	  if (pH<0)
      {
        ssSetErrorStatus(SS,"Error CE: pH Calculation based on mixed M and P failed" );
      }
            
     }
       else
    {
      for (i=0; i<U("Number")+1; i++)
        sys[i]=( u[i]+u[U("Number")+1+i] )/2;
       
        Uionsterkte=Uionsterkte1;
        Mgetal=Mgetal1;
        pH=pH1;
        Ca=Ca1;
        
    }

      HCO3 = CE_pHM_HCO3(pH,Mgetal,K1,K2,Kw,Factiviteit);
      CO3 = CE_pHM_CO3(pH,Mgetal,K1,K2,Kw,Factiviteit);

  	  sys[U("Flow")]=Debiet1+Debiet2;
      //y[Uv[2]-1]=Temp1;
      sys[U("Conductivity")]=Uionsterkte/0.183;
      sys[U("Bicarbonate")]=HCO3*mHCO3;
      sys[U("pH")]=pH;
      sys[U("Calcium")]=Ca*mCa;
      /*sys[U("Magnesium")]=Mg*24.3;*/

// geen extra output
//      dCa = CE_TACC(Ca,Mgetal,Pgetal,K1,K2,Kw,Ks,Factiviteit);
//
//    SIndex = log10(Ca*CO3/(Ks/pow(Factiviteit,8)));
//   
//    sys[U("Number")+1]=SIndex;
//    sys[U("Number")+1+1]=dCa;
  
  
}

/*
 * Mex Updates function
 *
 */
 void mengpH_Update(creal_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


/*
 *  Mex Derivatives function
 *
 */
void mengpH_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
}

