/*
This is the C-version of the Stimela enkfil model.

*/
#include "mex.h"
#include <math.h>
#include "StimelaFcns.c"
#include "CarbonEq_v3.c" 

extern  void StimelaSetErrorMessage(char * MyErrorMessage);
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))

void LogPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("enkfil_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}

void LogPrInt(char* name, int *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("enkfil_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%d",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}


/************* enkfil specific ****************/

/*
 * Mex Output function
 *
 */
 int enkfil_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *uWQ,  real_T *uES,
                          mxArray *Bin, mxArray *Uin, mxArray *Pin)

{
double  Susp, Temp, Flow;
int NumCel,i, spoelen;
double Surf, Diam, nmax, rhoD, FilPor0, Lwater, Lambda0, Lbed, n1, n2;
double dy, FilPor;
double vel, nu, I0;

double *Solids, *dSolids, *Sigma, *dSigma;
  
  
  Susp    = uWQ[U("Suspended_solids")];     //suspended solids concentration [mg/l]
  Susp    = Susp/1000.0;                  //suspended solids concentration [kg/m3]
  Temp    = uWQ[U("Temperature")];          //water temperature [Degrees Celsius]
  Flow    = uWQ[U("Flow")];                // water flow [m3/h]
 
  spoelen = uES[0]; // First Setpoint input is spoelen
  
  NumCel		 = (int) *P("NumCel");			//number of completely mixed reactors [-] 


  if (NumCel > 20) NumCel=20;  /* Limit number of cells, because of limited memory allocation. */
  
  Surf    = *P("Surf");    //Surface area filter
  Diam    = *P("Diam");    //Diameter grain size
  nmax    = *P("nmax");    //maximum pore filling
  rhoD    = *P("rhoD");    //density suspendid solids
  FilPor0 = *P("FilPor0"); //initial porosity of the filter
  Lwater  = *P("Lwater");  //supernatant water level height
  Lambda0 = *P("Lambda0"); //initial Lambda of the filter
  Lbed    = *P("Lbed");    //heigt of the filter bed
  n1      = *P("n1");      //clogging constant 1
  n2      = *P("n2");	    //clogging constant 2
   
  Diam    = Diam/1000.0;
  nmax    = nmax/100.0;
  FilPor0 = FilPor0/100.0; 
  dy      = Lbed/NumCel;
 
  //translation x into actual names
  Solids   = &xC[0];
  dSolids  = &sys[0];
  Sigma    = &xC[NumCel];  
  dSigma   = &sys[NumCel];
  
  if (Lbed<=0)
  {
    StimelaSetErrorMessage("Bed height should be positive");
    return 1;
  }

  /* additional calculations */
  vel          = Flow/(Surf*3600.0);       //surface loading
  nu=(497.0e-6)/pow((Temp+42.5),1.5);
  I0=(180.0*nu*pow((1.0-FilPor0),2)*vel)/(9.81*pow((FilPor0),3)*pow((Diam),2));
 
   
  if (spoelen == 1)
  {
    for (i =0;i<NumCel;i++)
    {  
      dSolids[i] = - (1.0/90.0)*Solids[i];
      dSigma[i]  = - (1.0/90.0)*Sigma[i]; 
    }
  }
	 
  else
  {
  
    
  //Suspendid solids
  //sys(1:NumCel) = ((vel./FilPor)/rhoD))./dy).*(MatQ1*[Susp;x(1:NumCel)]) - (vel./FilPor).*((Lambda0*(1+(x(NumCel+1:2*NumCel)/(k1*rhoD))-((x(NumCel+1:2*NumCel)/rhoD).^2)./(k2*(FilPor))))).*x(1:NumCel);
 
  dSolids[0] = (vel/(FilPor0-(Sigma[0]/rhoD))/dy)*(Susp-Solids[0]);
  for (i =1;i<NumCel;i++)
  {
    FilPor= FilPor0-(Sigma[i]/rhoD); 
    dSolids[i] = (vel/FilPor)/dy*(Solids[i-1]-Solids[i]);
  }
  

  for (i =0;i<NumCel;i++)
  {
    FilPor= FilPor0-(Sigma[i]/rhoD);  
    dSolids[i] =     dSolids[i]  - (vel/FilPor)*Lambda0*(1.0 +(n1/rhoD)*Sigma[i]-(n2/FilPor)*pow((Sigma[i]/rhoD), 2.0))*Solids[i];
  }
  
 
  //Accumulation solids
  //sys(NumCel+1:2*NumCel) = (vel).*((Lambda0*(1+(x(NumCel+1:2*NumCel)/(k1*rhoD))-((x(NumCel+1:2*NumCel)/rhoD).^2)./(k2*(FilPor))))).*x(1:NumCel);
  for (i =0;i<NumCel;i++)
  
  {
    FilPor= FilPor0-(Sigma[i]/rhoD); 
    dSigma[i] = (vel)*Lambda0*(1.0+(n1/rhoD)*Sigma[i]-(n2/FilPor)*pow(Sigma[i]/rhoD, 2.0))*Solids[i];
  }
  

}
	return 0;
}

/*
 * Mex Updates function
 *
 */
 int enkfil_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


  return 0;
}


/*
 *  Mex Derivatives function
 *
 */
 
 int enkfil_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uEM,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{


double  Susp, Temp, Flow;
int NumCel,i;
double Surf, Diam, nmax, rhoD, FilPor0, Lwater, Lambda0, Lbed, n1, n2;
double dy;
double vel, nu, I0;

double *Solids, *Sigma;
  
  
  Susp    = uWQ[U("Suspended_solids")];     //suspended solids concentration [mg/l]
  Susp    = Susp/1000.0;                  //suspended solids concentration [kg/m3]
  Temp    = uWQ[U("Temperature")];          //water temperature [Degrees Celsius]
  Flow    = uWQ[U("Flow")];                // water flow [m3/h]
 
  
  NumCel   = *P("NumCel");   //number of completely mixed reactors [-]
  
  Surf    = *P("Surf");    //Surface area filter
  Diam    = *P("Diam");    //Diameter grain size
  nmax    = *P("nmax");    //maximum pore filling
  rhoD    = *P("rhoD");    //density suspendid solids
  FilPor0 = *P("FilPor0"); //initial porosity of the filter
  Lwater  = *P("Lwater");  //supernatant water level height
  Lambda0 = *P("Lambda0"); //initial Lambda of the filter
  Lbed    = *P("Lbed");    //heigt of the filter bed
  n1      = *P("n1");      //clogging constant 1
  n2      = *P("n2");	    //clogging constant 2
   
  Diam    = Diam/1000.0;
  nmax    = nmax/100.0;
  FilPor0 = FilPor0/100.0; 
  dy      = Lbed/NumCel;
  
    
  //translation x into actual names
  Solids   = &xC[0];
  Sigma    = &xC[NumCel];  


  /* additional calculations */
  vel          = Flow/(Surf*3600.0);       //surface loading
 
 
  nu=(497.0e-6)/pow((Temp+42.5),1.5);
  I0=(180*nu*pow((1-FilPor0),2)*vel)/(9.81*pow((FilPor0),3)*pow((Diam),2));
  
  sysWQ[U("Suspended_solids")] = Solids[NumCel-1]*1000.0; //Concentration suspended solids in mg/l
  
  //Extra Measurements
  i=0;
  //first layer
  sysEM[i]=Solids[i]*1000.0;
  sysEM[NumCel+i]=dy-I0*dy*pow(FilPor0/(FilPor0-(Sigma[i]/rhoD)),2); //resistance as result of accumulation
    
  for (i=1; i < NumCel; i++)
  //other layers
  //preceding layer plus addition of current layer
  {
    sysEM[i]=sysEM[i]+Solids[i]*1000.0;
	//sysEM[NumCel+i]=sysEM[NumCel+i]+ (dy-I0*dy*pow(FilPor0/(FilPor0-(Sigma[i]/rhoD)),2)); //resistance as result of accumulation
	//sysEM[NumCel+i]=sysEM[NumCel+i-1]+ term; //resistance as result of accumulation
	sysEM[NumCel+i]=sysEM[NumCel+i-1]+ (dy-I0*dy*pow(FilPor0/(FilPor0-(Sigma[i]/rhoD)),2)); //resistance as result of accumulation
  }
  

return 0;
}

