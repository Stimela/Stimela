#include "mex.h"
#include "simstruc.h"
#include "CarbonEq_v1.c"
#include "StimelaFcns.c"

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))

//ErrorMessages (will stop simulation) :
// StimelaSetErrorMessage("Error:bladiebla");

void LogPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("biofil_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}


void biofil_Derivatives(real_T *sysC, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1
  
  /*parameters */
  double MuMax15_DOC, AlfaT_DOC, KsDOC, KsPO4, KsO2, Y_DOC, Y_O2, Y_CO2, Y_PO4;
  double B_DOC, Lbed, Diam, FilPor, Surf, D1_DOC,D2_DOC, PercBDOC, dy;
  
  int NumCel,i; 
  
  /* uWQ */
  double Temp, Flow,  DOC, NBDOC, O2, PO4, EGV, pH, Mn;
  
  double TempK, IonStrength, f;
  double K1,K2,Kw,KS;
  double CO2, HCO3, vel, VelReal, nu, Do2, Sc, kf, ko2, ds;
  
  double pHs[20],AlfapH_DOC[20],Monod_DOC[20],Monod_o2[20],Monod_po4[20], muDOC[20] ;//, q[20]test1[20];

  
  double *doc, *ddoc, *docs, *ddocs,*xDOC, *dxDOC, *o2, *do2, *o2s, *do2s, *co2, *dco2;
  double *co2s, *dco2s, *hco3, *dhco3, *hco3s, *dhco3s, *po4, *dpo4, *po4s, *dpo4s;

  //LogPr("outputs-1",NULL,0);
  
  NumCel		 = (int) *P("NumCel");			//number of completely mixed reactors [-] 
  MuMax15_DOC    = *P("MuMax15_DOC");          // maximum growth rate biomass [1/s]
  AlfaT_DOC      = *P("AlfaT_DOC");            // temperature correction factor [-]
  KsDOC          = *P("KsDOC");                // Monod constant for substrate DOC [g/m3]
  KsPO4          = *P("KsPO4");                // Monod constant for substrate PO4 [g/m3]
  KsO2           = *P("KsO2");                 // Monod constant for substrate O2 [g/m3]
  Y_DOC          = *P("Y_DOC");                // maximum yield [ng ATP/g substrate (DOC)]
  Y_O2           = *P("Y_O2");                 // yield O2 [mg O2/mg C]
  Y_CO2          = *P("Y_CO2");                // yield CO2 [mg CO2/mg C]
  Y_PO4          = *P("Y_PO4");                // yield PO4 [mg PO4/mg C]
  B_DOC          = *P("B_DOC");                // decay rate biomass [1/s]
  Lbed           = *P("Lbed");                 // bed height [m]
  Diam           = *P("Diam")/1000.0;          // grain size [m]
  FilPor         = *P("FilPor")/100.0;         // filter porosity [-]
  Surf           = *P("Surf");                 // surface area filter bed [m2]



  D1_DOC		 = 0.0;
  D2_DOC		 = 0.0;
  /*
  for (i=0; i < NumCel; i++) 
  { 
    q[i]=1.0e-15;
  }
  */

  Temp      	 = uWQ[U("Temperature")];      // water temperature [Celsius]
  Flow      	 = uWQ[U("Flow")];             // water flow [m3/h]


  PercBDOC       = *P("PercBDOC")/100.0;         // percentage biodegradable DOC [%]
  DOC     	     = uWQ[U("DOC")]*PercBDOC;       // biodegradable DOC concentration [mg/L]
  NBDOC     	 = uWQ[U("DOC")]*(1.0-PercBDOC); // non-biodegradable DOC concentration [mg/L]
  O2      	     = uWQ[U("Oxygen")];              // oxygen concentration [mg/L]
  PO4     	     = uWQ[U("Phosphate")];           // phosphate concentration [mg/L]
  EGV     	     = uWQ[U("Conductivity")];        // Electrical conductivity [mS/m]
  pH     	     = uWQ[U("pH")];                  // pH [-]
  Mn     	     = uWQ[U("Mnumber")];             // m number [-]

  dy		     = Lbed/(double)NumCel;         // height per layer [m]
  
  TempK 	     = Temp + 273.15;
  IonStrength    = 0.183*EGV;
  f 		     = CE_Activity(IonStrength);
  KValues(&K1,&K2,&Kw,&KS,TempK);
  CO2            =CE_pHM_CO2(pH,Mn,K1,K2,Kw,f)*44.0; //in mg/l
  HCO3           =CE_pHM_HCO3(pH,Mn,K1,K2,Kw,f)*61.0;//in mg/l
  
  LogPr("HCO3",&HCO3,1);
  

  
  vel            = Flow/(Surf*3600.0); 				//surface filtration velocity
  VelReal        = vel/FilPor;  						//pore velocity
  nu     	     = (497.0e-6)/pow((42.5+Temp),1.5);    // kinematic viscosity m2/s for 0oC until 35oC
  Do2			 = 1.0/(9.048299e-1 - 1.961736e-2*Temp + 1.076824e-4*pow(Temp,2))*1.0e-9; //zie afstudeerrapport alex
  Sc             = nu/Do2;
  kf             = (2.0+1.1*pow((Diam*vel/nu),0.6)*pow(Sc,0.33))*Do2/Diam; //zie rapport david visscher
  ko2            = 6.0/Diam*(1.0-FilPor)*kf;
 


  //translation x into actual names 
  doc		= &xC[0];//+q[0];
  ddoc		= &sysC[0];
  docs		= &xC[NumCel];//+q[0];
  ddocs		= &sysC[NumCel];
  xDOC		= &xC[2*NumCel];//+q[0];
  dxDOC		= &sysC[2*NumCel];
  o2		= &xC[3*NumCel];
  do2		= &sysC[3*NumCel];
  o2s		= &xC[4*NumCel];
  do2s		= &sysC[4*NumCel];
  co2		= &xC[5*NumCel];
  dco2		= &sysC[5*NumCel];
  co2s		= &xC[6*NumCel];
  dco2s		= &sysC[6*NumCel];
  hco3		= &xC[7*NumCel];
  dhco3		= &sysC[7*NumCel];
  hco3s		= &xC[8*NumCel];
  dhco3s	= &sysC[8*NumCel];
  po4		= &xC[9*NumCel];
  dpo4		= &sysC[9*NumCel];
  po4s		= &xC[10*NumCel];
  dpo4s		= &sysC[10*NumCel];
  
  for (i=0; i < NumCel; i++) 
  {  
  
    pHs[i]		  = CE_CO2HCO3_pH(co2s[i]/44.0,hco3s[i]/61.0,K1,K2,Kw,f);
	//AlfapH_DOC[i] = 1.0/(1.0+0.041*pow(10.0,abs(8.4-pHs[i])));
	AlfapH_DOC[i] 	  = 1.0/(1.0+0.041*pow(10.0,(8.4-pHs[i])));
	Monod_DOC[i]  = docs[i]/(docs[i]+KsDOC);
    Monod_o2[i]   = o2s[i]/(o2s[i]+KsO2);
	Monod_po4[i]  = po4s[i]/(po4s[i]+KsPO4);
	muDOC[i]      = exp(log(AlfaT_DOC)*(Temp-15.0))*AlfapH_DOC[i]*MuMax15_DOC*MIN(MIN(Monod_DOC[i],Monod_o2[i]),Monod_po4[i]);
  }
  //LogPr("t",&t,1);
  
  //LogPr("pHs",pHs,NumCel);
  //LogPr("AlfapH_DOC",AlfapH_DOC,NumCel);
  //LogPr("test1",test1,NumCel);
  //LogPr("Monod_DOC",Monod_DOC,NumCel);
  //LogPr("Monod_o2",Monod_o2,NumCel);
  //LogPr("Monod_po4",Monod_po4,NumCel);
  //LogPr("muDOC",muDOC,NumCel);
  
  ds=0.0001;
  
  //ddoc
  //sys(1:NumCel)= MatQ*[DOC;doc]-ko2*(doc-docs);
  dTransport(ddoc, doc, DOC, VelReal/dy, NumCel);
  dReactionX(ddoc, doc, -ko2, NumCel);
  dReactionX(ddoc, docs, ko2, NumCel);
  
  //LogPr("ddoc-1",ddoc, NumCel);
  
  //ddocs
  //sys(NumCel+1:2*NumCel)= (ko2*(doc-docs)-muDOC.*xDOC./Y_DOC)/(ds*6*(1-FilPor)/Diam);
  for (i =0;i<NumCel;i++)
  {
    ddocs[i] = (ko2*(doc[i]-docs[i])-muDOC[i]*xDOC[i]/Y_DOC)/(ds*6.0*(1-FilPor)/Diam);
  }
  
  //dxDOC
  //sys(2*NumCel+1:3*NumCel)=((1-D1_DOC)*muDOC-B_DOC-D2_DOC).*xDOC;
  for (i =0;i<NumCel;i++)
  {
    dxDOC[i] = ((1.0-D1_DOC)*muDOC[i]-B_DOC-D2_DOC)*xDOC[i] ;
  }
  
  //do2 
  //sys(3*NumCel+1:4*NumCel)= MatQ*[O2;o2]-ko2*(o2-o2s);
  dTransport(do2, o2, O2,VelReal/dy, NumCel);
  dReactionX(do2, o2, -ko2, NumCel);
  dReactionX(do2, o2s, ko2, NumCel);
  
  //LogPr("dO2-1",do2, NumCel);
  
  //do2s
  //sys(4*NumCel+1:5*NumCel)= (ko2*(o2-o2s)-muDOC.*xDOC./Y_DOC*(Y_O2))/(ds*6*(1-FilPor)/Diam);
  for (i =0;i<NumCel;i++)
  {
    do2s[i] = (ko2*(o2[i]-o2s[i])-muDOC[i]*xDOC[i]/Y_DOC*Y_O2)/(ds*6.0*(1-FilPor)/Diam);
  }
  
  //dco2
  //sys(5*NumCel+1:6*NumCel)= MatQ*[CO2;co2]-ko2*(co2-co2s);
  dTransport(dco2, co2, CO2,VelReal/dy, NumCel);
  dReactionX(dco2, co2, -ko2, NumCel);
  dReactionX(dco2, co2s, ko2, NumCel);
  
  //LogPr("dcO2-1",dco2, NumCel);
  
  //dco2s
  //sys(6*NumCel+1:7*NumCel)= (ko2*(co2-co2s)+muDOC.*xDOC./Y_DOC*(Y_CO2))/(ds*6*(1-FilPor)/Diam);
  for (i =0;i<NumCel;i++)
  {
    dco2s[i] = (ko2*(co2[i]-co2s[i])-muDOC[i]*xDOC[i]/Y_DOC*Y_CO2)/(ds*6.0*(1-FilPor)/Diam);
  }
  
  //dhco3
  //sys(7*NumCel+1:8*NumCel)= MatQ*[HCO3;hco3]-ko2*(hco3-hco3s);
  dTransport(dhco3, hco3, HCO3,VelReal/dy, NumCel);
  dReactionX(dhco3, hco3, -ko2, NumCel);
  dReactionX(dhco3, hco3s, ko2, NumCel);
  
  //LogPr("dhco3-1",dhco3, NumCel);
  
  //dhco3s
  //sys(8*NumCel+1:9*NumCel)= ko2*(hco3-hco3s); %-muDOC.*xDOC./Y_DOC*(2*61/14))/(ds*6*(1-FilPor)/Diam);
  for (i =0;i<NumCel;i++)
  {
    dhco3s[i] = ko2*(hco3[i]-hco3s[i]);
  }
  
  //dpo4
  //sys(9*NumCel+1:10*NumCel)= MatQ*[PO4;po4]-ko2*(po4-po4s);
  dTransport(dpo4, po4, PO4, VelReal/dy, NumCel);
  dReactionX(dpo4, po4, -ko2, NumCel);
  dReactionX(dpo4, po4s, ko2, NumCel);
  
  //LogPr("dpo4-1",dpo4, NumCel);
  
  //dpo4s
  //sys(10*NumCel+1:11*NumCel)= (ko2*(po4-po4s)-muDOC.*xDOC/Y_DOC*(Y_PO4))/(ds*6*(1-FilPor)/Diam);
  for (i =0;i<NumCel;i++)
  {
    dpo4s[i] = (ko2*(po4[i]-po4s[i])-muDOC[i]*xDOC[i]/Y_DOC*Y_PO4)/(ds*6.0*(1-FilPor)/Diam);
  }

}

extern void biofil_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


void biofil_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag=3
  
  int NumCel,i; 
  
  double Temp, EGV;
  double CO2out, HCO3out, pHout, Mnout, PercBDOC, NBDOC;
  
  double *doc, *docs, *xDOC,  *o2, *o2s, *co2;
  double *co2s, *hco3, *hco3s, *po4, *po4s;
  
  double TempK, IonStrength, f;
  double K1,K2,Kw,KS;
  

  NumCel		 = (int) *P("NumCel");			//number of completely mixed reactors [-] 

  
  //LogPr("outputs-0",NULL,0);
  
  
  Temp      	 = uWQ[U("Temperature")];      // water temperature [Celsius]
  EGV     	     = uWQ[U("Conductivity")];        // Electrical conductivity [mS/m]

  
  doc		= &xC[0];
  docs		= &xC[NumCel];
  xDOC		= &xC[2*NumCel];
  o2		= &xC[3*NumCel];
  o2s		= &xC[4*NumCel];
  co2		= &xC[5*NumCel];
  co2s		= &xC[6*NumCel];
  hco3		= &xC[7*NumCel];
  hco3s		= &xC[8*NumCel];
  po4		= &xC[9*NumCel];
  po4s		= &xC[10*NumCel];
  
  //LogPr("outputs-1",NULL,0);
  
  CO2out 	= co2[NumCel-1]/44.0;         //in mmol/l
  HCO3out   = hco3[NumCel-1]/61.0; 	   //in mmol/l
  
  //LogPr("CO2out",&CO2out, 1);
  //LogPr("HCO3out",&HCO3out, 1);

  
  //LogPr("outputs-2",NULL,0);
  
  TempK 	     = Temp + 273.15;
  IonStrength    = 0.183*EGV;
  f 		     = CE_Activity(IonStrength);
  KValues(&K1,&K2,&Kw,&KS,TempK);
  
  //LogPr("outputs-3",NULL,0);
  
  pHout 	= CE_CO2HCO3_pH(CO2out,HCO3out,K1,K2,Kw,f);
  Mnout 	= CE_pHHCO3_M(pHout,HCO3out,K1,K2,Kw,f);
  
  //LogPr("outputs-4",NULL,0);
  
  PercBDOC  = *P("PercBDOC")/100.0;         // percentage biodegradable DOC [%]
  NBDOC     = uWQ[U("DOC")]*(1.0-PercBDOC); // non-biodegradable DOC concentration [mg/L]
  
  //LogPr("NBDOC", &NBDOC, 1);
  
  //LogPr("outputs-5",NULL,0);
  
  sysWQ[U("Mnumber")]			= Mnout;
  sysWQ[U("pH")]				= pHout;
  sysWQ[U("Carbon_dioxide")] 	= co2[NumCel-1];  		//in mg/L
  sysWQ[U("Bicarbonate")]		= hco3[NumCel-1]; 		//in mg/L
  sysWQ[U("DOC")]				= doc[NumCel-1]+NBDOC; //in mg/L
  sysWQ[U("Oxygen")]			= o2[NumCel-1];			//in mg/L
  sysWQ[U("Phosphate")]			= po4[NumCel-1];		//in mg/L
  
 
  //Determine extra measurements
  //sys(U.Number+1:U.Number+11*NumCel) = x(1:11*NumCel);

  for (i=0; i < NumCel; i++)
  {
    sysEM[i]=doc[i];     
	sysEM[NumCel+i]=docs[i];  
	sysEM[2*NumCel+i]=xDOC[i]; 
	sysEM[3*NumCel+i]=o2[i]; 
	sysEM[4*NumCel+i]=o2s[i];
	sysEM[5*NumCel+i]=co2[i];
	sysEM[6*NumCel+i]=co2s[i]; 
	sysEM[7*NumCel+i]=hco3[i];
	sysEM[8*NumCel+i]=hco3s[i];
	sysEM[9*NumCel+i]=po4[i];
	sysEM[10*NumCel+i]=po4s[i];
	
  }
  
    //LogPr("outputs-6",NULL,0);

  
};
