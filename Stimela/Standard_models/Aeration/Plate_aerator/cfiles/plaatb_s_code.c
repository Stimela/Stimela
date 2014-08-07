/*
This is the C-version of the Stimela plaatbe model.

*/
#include "mex.h"
#include "StimelaFcns.c"
#include "CarbonEq_v1.c" 
#include "AerationEq.c"


#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]

#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)

#define P(D)   mxGetPr(mxGetField(Pin,0,D))

void LogPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("plaatb_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}


/************* plaatb specific ****************/

/*
 * Mex Output function
 *
 */
void plaatb_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)

{
double  Tl,Ql,QgTot,QgVers,QgRec, coO2,coCH4,coCO2,coHCO3;
double Popp, Lengte, Breedte, Htot, PercWat, RQ, VWater; 
double  pHo,EGVo,coN2, coH2S, coMn;
int NumCel;
double k2CH4;
double Td, Tg, TijdStap, IonStrength, f;
double K1,K2,Kw, KS;
//int i;

double MrCO2, MrCO3, MrHCO3, MrO2, MrCH4, MrN2, MrH2S;
double Po, R, cgoO2, cgoCH4, cgoCO2, cgoN2, cgoH2S;

  
double kDO2, kDCH4, kDCO2, kDN2, kDH2S;
double DifO2, DifCH4,  DifCO2, DifN2, DifH2S;
double n, k2O2, k2CO2, k2N2, k2H2S;
double T, pw;

//double KFe, p;

double *O2, *dO2, *goO2, *dgoO2,*CH4, *dCH4, *goCH4, *dgoCH4;
double *CO2, *dCO2, *goCO2, *dgoCO2, *Mn, *dMn;
//double *dcgoO2,*dcgoCH4,*dcgoCO2,*dcgoN2,*dcgoH2S,*xcgoO2,*xcgoCH4,*xcgoCO2,*xcgoN2,*xcgoH2S;

double *N2, *dN2, *goN2, *dgoN2, *H2S, *dH2S, *goH2S, *dgoH2S;
//double pFe[20];
  

    

  Tl      = u[U("Temperature")];         //water temperature            [Celsius]
  Ql      = u[U("Flow")];         //water flow                 [m3/h]
  coO2    = u[U("Oxygen")];         //influent concentration O2    [mg/l]
  coCH4   = u[U("Methane")];         //influent concentration CH4   [mg/l]
  coHCO3  = u[U("Bicarbonate")];         //influent concentration HCO3  [mg/l]
  coH2S   = u[U("Hydrogen_sulfide")];        //influent concentration H2S   [mg/l]
  coN2    = u[U("Nitrogen")];        //influent concentration N2    [mg/l]
  coMn	  = u[U("Mnumber")]/1000.0;		//Mnumber [mmol/l]	
  
  pHo     = u[U("pH")];         //influent pH                 [-]
  EGVo    = u[U("Conductivity")];         //influent EGV                [mS/m]
 //QgTot    = u[U("Number")+1]/3600.0; //total airflow [m3/h]
 
  NumCel   = *P("NumCel");   //number of completely mixed reactors [-]
  if (NumCel>20)
  { 
    NumCel=20;
  }
  
  k2CH4    = *P("k2");   //the k2-value of methane [1/s]
  //RQeff    = *P("RQeff");   //the effective air-water ratio
  //VBak     = *P("VBak");   //volume of plaatbe tank
  //Vair     = *P("Vair");    // volume of contained air
  
  QgTot    = *P("QgTot");  //totale luchtdebiet [m3/s]
  QgVers   = *P("QgVers");  //verse luchtdebiet [m3/s]
  QgRec    = *P("QgRec");  //recirculatie luchtdebiet [m3/s]
  
  Popp     = *P("Popp");  //totale plaatoppervlak [m2]
  Lengte   = *P("Lengte");  //lengte van de plaat [m]
  Breedte  = *P("Breedte");  //%breedte van de plaat [m]
  Htot     = *P("Htot");     //%hoogte bellenbed [m]
  PercWat  = *P("PercWat");     //%percentage water in het bellenbed [%/100]
  

  
  
  //LogPr("sys",sys, 16*NumCel);

  //translation x into actual names
  O2   = &xC[0];
  dO2  = &sys[0];
  goO2 = &xC[NumCel];
  dgoO2 = &sys[NumCel];
  CH4  = &xC[2*NumCel];
  dCH4 = &sys[2*NumCel];
  goCH4 = &xC[3*NumCel];
  dgoCH4 = &sys[3*NumCel];
  CO2   = &xC[4*NumCel];
  dCO2  = &sys[4*NumCel];
  goCO2 = &xC[5*NumCel];
  dgoCO2 = &sys[5*NumCel];
  Mn   = &xC[6*NumCel];
  dMn  = &sys[6*NumCel];
  N2    = &xC[7*NumCel];
  dN2   = &sys[7*NumCel];
  goN2  = &xC[8*NumCel];
  dgoN2 = &sys[8*NumCel];
  H2S   = &xC[9*NumCel];
  dH2S  = &sys[9*NumCel];
  goH2S = &xC[10*NumCel];
  dgoH2S = &sys[10*NumCel];
 

/* 
  if (Vair>0)
  {
  
    dcgoO2 = &sys[11*NumCel];
    dcgoCH4 = &sys[11*NumCel+1];
    dcgoCO2 = &sys[11*NumCel+2];
    dcgoN2 = &sys[11*NumCel+3];
    dcgoH2S = &sys[11*NumCel+4];
    xcgoO2 = &xC[11*NumCel];
    xcgoCH4 = &xC[11*NumCel+1];
    xcgoCO2 = &xC[11*NumCel+2];
    xcgoN2 = &xC[11*NumCel+3];
    xcgoH2S = &xC[11*NumCel+4];   
  }
  */
  



  /*Round of air temperature into round numbers */
  Tg     = Tl;               //Air temperature in degrees Celcius
   
  /*Determination of necessary quantities regarding flows and residence times*/
  //Ql       = Ql/3600.0;            // Change flow from m3/h -> m3/s
  //TijdStap = (VBak)/Ql;          // Determination average residence time in one completely mixed vessel

  
  Ql       = Ql/3600.0;              //% Omzetten van het debiet van m3/h -> m3/s
  RQ       = QgTot/Ql;             //% Lucht water verhouding [-]
  VWater   = Popp*(PercWat*Htot);  //% Watervolume in het bellenbed [m3]
  Td       = VWater/Ql;            //% Bepalen van de gemiddelde verblijftijd in de plaatbeluchter
  TijdStap = Td/NumCel;            //% Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat


  /*Relative molecular masses [mg/mol]*/ 
  MrCO2  = 1000.0*44.01;
  MrCO3  = 1000.0*60.01;
  MrHCO3 = 1000.0*61.02;
  MrO2   = 1000.0*31.9988;
  MrCH4  = 1000.0*16.04303; 
  MrN2   = 1000.0*28.0134;
  MrH2S  = 1000.0*34.08;

  /*Constants for determination gas concentrations in air*/
  Po     = 101325.0;
  R      = 8.3143; 
  
  /*Gas concentrations in air (Temperature in Kelvin)*/
  pw     = 1070.0*exp(0.04986*Tg)-525.1;
  
  cgoO2  = (0.20948*(Po-pw)*(MrO2 /1000.0))/(R*(Tg+273.0)); 
  cgoCH4 =  0.0; 
  cgoCO2 = (0.00032*(Po-pw)*(MrCO2/1000.0))/(R*(Tg+273.0));
  cgoN2  = (0.78084*(Po-pw)*(MrN2 /1000.0))/(R*(Tg+273.0));
  cgoH2S =  0.0; 
  

  //Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
  
  kDO2  = 0.02727*exp(-0.0426*Tl)+0.02202;
  kDCH4 = 0.03227*exp(-0.05315*Tl)+0.02352;
  kDCO2 = 1.307*exp(-0.04489*Tl)+0.4015;
  kDN2  = 5.75e-006*pow(Tl,2.0)-0.0004355*Tl+0.023;
  kDH2S = 0.001175*pow(Tl,2.0)-0.1148*Tl+4.688;
  
  //Vergelijkingen voor de diffusiecoëfficiënten, best fit bij 10, 20 en 30 graden Celsius, bruikbaar van 0-40 Celsius
  DifO2  = 1.0/(9.048299e-1 - 1.961736e-2*Tl + 1.076824e-4*pow(Tl,2.0))*1.0e-9;
  DifCH4 = 1.0/(1.081256    - 2.310800e-2*Tl + 1.189257e-4*pow(Tl,2.0))*1.0e-9;
  DifCO2 = 1.0/(9.644559e-1 - 2.058414e-2*Tl + 1.061623e-4*pow(Tl,2.0))*1.0e-9;
  DifN2  = 1.0/(9.874819e-1 - 2.112977e-2*Tl + 1.121742e-4*pow(Tl,2.0))*1.0e-9;
  DifH2S = 1.0/(1.15095     - 2.461722e-2*Tl + 1.265363e-4*pow(Tl,2.0))*1.0e-9;

  //De macht van de diffussiecoefficient
  n     = 1.0;
  k2O2  = k2CH4*pow((DifO2 /DifCH4),n);
  k2CO2 = k2CH4*pow((DifCO2/DifCH4),n);
  k2N2  = k2CH4*pow((DifN2 /DifCH4),n);
  k2H2S = k2CH4*pow((DifH2S/DifCH4),n);
  
  /*Different equilibrium constants (Temperature in Kelvin)*/
  T      = (Tl+273.0);


  
  /*concentrations in [mol/l] (using activities):*/
  
  IonStrength = 0.183*EGVo;
  f = CE_Activity(IonStrength);
  KValues(&K1,&K2,&Kw,&KS,T);
  coCO2=CE_pHM_CO2(pHo,coMn,K1,K2,Kw,f);
   
  
  coO2   = coO2/MrO2;
  coCH4  = coCH4/MrCH4;
  coN2   = coN2/MrN2;
  coH2S  = coH2S/MrH2S;
  cgoO2  = cgoO2/MrO2;
  cgoCH4 = cgoCH4/MrCH4;
  cgoCO2 = cgoCO2/MrCO2;
  cgoN2  = cgoN2/MrN2;
  cgoH2S = cgoH2S/MrH2S; 


  //Oxygen
  //old (with effect of iron on consumption oxygen)
  //sys(1:NumCel)=MatQ1*[coO2;x(1:NumCel)]+k2O2*kDO2*x(NumCel+1:2*NumCel)-k2O2*x(1:NumCel)-0.25*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)];
  //new (without effect of iron on consumption oxygen)
  //sys(1:NumCel)=MatQ1*[coO2;x(1:NumCel)]+k2O2*kDO2*x(NumCel+1:2*NumCel)-k2O2*x(1:NumCel);
  dTransport(dO2,O2,coO2,1/TijdStap,NumCel);
  dReactionX(dO2,goO2,k2O2*kDO2,NumCel);
  dReactionX(dO2,O2,-1*k2O2,NumCel);
  
  
  //Gas concentration oxygen
  //sys(NumCel+1:2*NumCel)=(cgoO2-x(NumCel+1:2*NumCel))./TijdStap-((k2O2*kDO2)/RQeff)*x(NumCel+1:2*NumCel)+(k2O2/RQeff)*x(1:NumCel);
  dTransportGas(dgoO2, goO2, cgoO2, 1/TijdStap, NumCel);
  dReactionX(dgoO2, goO2, -1*k2O2*kDO2/(RQ/NumCel), NumCel);
  dReactionX(dgoO2, O2, k2O2/(RQ/NumCel), NumCel);
  
  
  //Methane
  //sys(2*NumCel+1:3*NumCel)=MatQ1*[coCH4;x(2*NumCel+1:3*NumCel)]+k2CH4*kDCH4*x(3*NumCel+1:4*NumCel)-k2CH4*x(2*NumCel+1:3*NumCel);
  dTransport(dCH4,CH4,coCH4,1/TijdStap,NumCel);
  dReactionX(dCH4,&xC[3*NumCel],k2CH4*kDCH4,NumCel);
  dReactionX(dCH4,CH4,-1*k2CH4,NumCel);
  
  //Gas concentration methane
  //sys(3*NumCel+1)=MatQ6*[cgoCH4;x(3*NumCel+1)]-((k2CH4*kDCH4)/RQeff)*x(3*NumCel+1)+(k2CH4/RQeff)*x(2*NumCel+1);

  dTransportGas(dgoCH4,goCH4,cgoCH4,1/TijdStap,NumCel);
  dReactionX(dgoCH4,goCH4,-1*k2CH4*kDCH4/(RQ/NumCel),NumCel);
  dReactionX(dgoCH4,CH4, k2CH4/(RQ/NumCel), NumCel);
  
  //Carbon dioxide
  //old (with effect of iron and calcium on shift in pH)
  //sys(4*NumCel+1:5*NumCel)=MatQ1*[coCO2;x(4*NumCel+1:5*NumCel)]+k2CO2*kDCO2*x(5*NumCel+1:6*NumCel)-k2CO2*x(4*NumCel+1:5*NumCel)+2*MatQ5*[pFe;x(8*NumCel+1:9*NumCel)]+MatQ5*[qCa;x(10*NumCel+1:11*NumCel)];
  //new (without effect of iron and calcium on shift in pH)
  //sys(4*NumCel+1:5*NumCel)=MatQ1*[coCO2;x(4*NumCel+1:5*NumCel)]+k2CO2*kDCO2*x(5*NumCel+1:6*NumCel)-k2CO2*x(4*NumCel+1:5*NumCel);
  dTransport(dCO2, CO2, coCO2, 1/TijdStap, NumCel);
  dReactionX(dCO2, goCO2, k2CO2*kDCO2, NumCel);
  dReactionX(dCO2, CO2, -1*k2CO2, NumCel);
  
  //Gas concentration carbon dioxide
  //sys(5*NumCel+1)=MatQ6*[cgoCO2;x(5*NumCel+1)]-((k2CO2*kDCO2)/RQeff)*x(5*NumCel+1)+(k2CO2/RQeff)*x(4*NumCel+1);
  
  dTransportGas(dgoCO2, goCO2, cgoCO2, 1/TijdStap, NumCel);
  dReactionX(dgoCO2, goCO2, -1*k2CO2*kDCO2/(RQ/NumCel), NumCel);
  dReactionX(dgoCO2, CO2, k2O2/(RQ/NumCel), NumCel);
  
  //MNumber
  //sys(7*NumCel+1:8*NumCel)=MatQ1*[coHCO3;x(7*NumCel+1:8*NumCel)]
  dTransport(dMn, Mn, coMn, 1/TijdStap, NumCel);
  
   //concentration nitrogen
  //sys(12*NumCel+1:13*NumCel)=MatQ1*[coN2;x(12*NumCel+1:13*NumCel)]+k2N2*kDN2*x(13*NumCel+1:14*NumCel)-k2N2*x(12*NumCel+1:13*NumCel);
  dTransport(dN2, N2, coN2, 1/TijdStap, NumCel);
  dReactionX(dN2, goN2, k2N2*kDN2, NumCel);
  dReactionX(dN2, N2, -1*k2N2, NumCel);
  
  //gas concentration nitrogen
  //sys(13*NumCel+1)=MatQ6*[cgoN2;x(13*NumCel+1)]-((k2N2*kDN2)/RQeff)*x(13*NumCel+1)+(k2N2/RQeff)*x(12*NumCel+1);
  
  dTransportGas(dgoN2, goN2, cgoN2, 1/TijdStap, NumCel);
  dReactionX(dgoN2, goN2, -1*k2N2*kDN2/(RQ/NumCel), NumCel);
  dReactionX(dgoN2, N2, k2N2/(RQ/NumCel), NumCel);
  
  //concentration Sulfic acid
  //sys(14*NumCel+1:15*NumCel)=MatQ1*[coH2S;x(14*NumCel+1:15*NumCel)]+k2H2S*kDH2S*x(15*NumCel+1:16*NumCel)-k2H2S*x(14*NumCel+1:15*NumCel);
  dTransport(dH2S, H2S, coH2S, 1/TijdStap, NumCel);
  dReactionX(dH2S, goH2S, k2H2S*kDH2S, NumCel);
  dReactionX(dH2S, H2S, -1*k2H2S, NumCel);
  
  //gas concentration sulfic acid
  //sys(15*NumCel+1)=MatQ6*[cgoH2S;x(15*NumCel+1)]-((k2H2S*kDH2S)/RQeff)*x(15*NumCel+1)+(k2H2S/RQeff)*x(14*NumCel+1);
 
  dTransportGas(dgoH2S, goH2S, cgoH2S, 1/TijdStap, NumCel);
  dReactionX(dgoH2S, goH2S, -1*k2H2S*kDH2S/(RQ/NumCel), NumCel);
  dReactionX(dgoH2S, H2S, k2H2S/(RQ/NumCel), NumCel);
  
 
  
	//LogPr("coCO2",&coCO2,1);
	//LogPr("f",f,NumCel);
	/*LogPr("O2",O2,NumCel);
	LogPr("dO2",dO2,NumCel);
	LogPr("goO2",goO2,NumCel);
	LogPr("dgoO2",dgoO2, NumCel);
	LogPr("TkDO2",TkDO2,4);
	LogPr("k2O2", &k2O2, 1);
	LogPr("kDO2", &kDO2, 1);
	LogPr("Tl",&Tl,1);
	LogPr("TijdStap", &TijdStap, 1);
	
    LogPr("sys",sys, 16*NumCel);*/
	
}

/*
 * Mex Updates function
 *
 */
 void plaatb_Update(creal_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}


/*
 *  Mex Derivatives function
 *
 */
 
 void plaatb_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
double  Tl,Ql,QgTot,QgVers,QgRec, coO2,coCH4,coCO2,coHCO3;
double Popp, Lengte, Breedte, Htot, PercWat, RQ, VWater; 
double  pHo,EGVo,coN2, coH2S, coMn;
int NumCel;
double k2CH4;
double Td, Tg, TijdStap, IonStrength, f;
double K1,K2,Kw, KS;
int i;

double MrCO2, MrO2, MrCH4, MrN2, MrH2S;
double Po, R, cgoO2, cgoCH4, cgoCO2, cgoN2, cgoH2S;

double kDO2, kDCH4, kDCO2, kDN2, kDH2S;
double DifO2, DifCH4,  DifCO2, DifN2, DifH2S;
double n, k2O2, k2CO2, k2N2, k2H2S;
double T, pw, CO2eff, Mneff, testpH;


//double KFe, p;

double *O2, *goO2, *CH4, *goCH4;
double *CO2,  *goCO2,  *Mn;
double *N2,  *goN2,  *H2S,  *goH2S;
//double pFe[20];
  


  Tl      = u[U("Temperature")];         //water temperature            [Celsius]
  Ql      = u[U("Flow")];         //water flow                 [m3/h]
  coO2    = u[U("Oxygen")];         //influent concentration O2    [mg/l]
  coCH4   = u[U("Methane")];         //influent concentration CH4   [mg/l]
  coHCO3  = u[U("Bicarbonate")];         //influent concentration HCO3  [mg/l]
  coH2S   = u[U("Hydrogen_sulfide")];        //influent concentration H2S   [mg/l]
  coN2    = u[U("Nitrogen")];        //influent concentration N2    [mg/l]
  coMn	  = u[U("Mnumber")]/1000.0;		//Mnumber [mmol/l]	
  
  pHo     = u[U("pH")];         //influent pH                 [-]
  EGVo    = u[U("Conductivity")];         //influent EGV                [mS/m]
 
  
  
  NumCel   = *P("NumCel");   //number of completely mixed reactors [-]
  if (NumCel>20)
  { 
    NumCel=20;
  }
  
   k2CH4    = *P("k2");   //the k2-value of methane [1/s]
  //RQeff    = *P("RQeff");   //the effective air-water ratio
  //VBak     = *P("VBak");   //volume of plaatbe tank
  //Vair     = *P("Vair");    // volume of contained air
  
  QgTot    = *P("QgTot");  //totale luchtdebiet [m3/s]
  QgVers   = *P("QgVers");  //verse luchtdebiet [m3/s]
  QgRec    = *P("QgRec");  //recirculatie luchtdebiet [m3/s]
  
  Popp     = *P("Popp");  //totale plaatoppervlak [m2]
  Lengte   = *P("Lengte");  //lengte van de plaat [m]
  Breedte  = *P("Breedte");  //%breedte van de plaat [m]
  Htot     = *P("Htot");     //%hoogte bellenbed [m]
  PercWat  = *P("PercWat");     //%percentage water in het bellenbed [%/100]
  



  //translation x into actual names
  O2   = &xC[0];
  goO2 = &xC[NumCel];
  CH4  = &xC[2*NumCel];
  goCH4 = &xC[3*NumCel];
  CO2   = &xC[4*NumCel];
  goCO2 = &xC[5*NumCel];
  Mn   = &xC[6*NumCel];
  N2    = &xC[7*NumCel];
  goN2  = &xC[8*NumCel];
  H2S   = &xC[9*NumCel];
  goH2S = &xC[10*NumCel];


  
  //LogPr("O2",O2,NumCel);
  
  /*Round of air temperature into round numbers */
  Tg     = Tl;               //Air temperature in degrees Celcius
  
  /*Determination of necessary quantities regarding flows and residence times*/
  Ql       = Ql/3600.0;              //% Omzetten van het debiet van m3/h -> m3/s
  RQ       = QgTot/Ql;             //% Lucht water verhouding [-]
  VWater   = Popp*(PercWat*Htot);  //% Watervolume in het bellenbed [m3]
  Td       = VWater/Ql;            //% Bepalen van de gemiddelde verblijftijd in de plaatbeluchter
  TijdStap = Td/NumCel;            //% Bepalen van de gemiddelde verblijftijd in één volledig gemengd vat




  /*Relative molecular masses [mg/mol]*/ 
  MrCO2  = 1000.0*44.01;
  MrO2   = 1000.0*31.9988;
  MrCH4  = 1000.0*16.04303; 
  MrN2   = 1000.0*28.0134;
  MrH2S  = 1000.0*34.08;

  /*Constants for determination gas concentrations in air*/
  Po     = 101325.0;
  R      = 8.3143; 
  
   /*Gas concentrations in air (Temperature in Kelvin)*/
  pw     = 1070.0*exp(0.04986*Tg)-525.1;
  
  cgoO2  = (0.20948*(Po-pw)*(MrO2 /1000.0))/(R*(Tg+273.0)); 
  cgoCH4 =  0.0; 
  cgoCO2 = (0.00032*(Po-pw)*(MrCO2/1000.0))/(R*(Tg+273.0));
  cgoN2  = (0.78084*(Po-pw)*(MrN2 /1000.0))/(R*(Tg+273.0));
  cgoH2S =  0.0; 
  

  //Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
  
  kDO2  = 0.02727*exp(-0.0426*Tl)+0.02202;
  kDCH4 = 0.03227*exp(-0.05315*Tl)+0.02352;
  kDCO2 = 1.307*exp(-0.04489*Tl)+0.4015;
  kDN2  = 5.75e-006*pow(Tl,2.0)-0.0004355*Tl+0.023;
  kDH2S = 0.001175*pow(Tl,2.0)-0.1148*Tl+4.688;
  
  
  //Vergelijkingen voor de diffusiecoëfficiënten, best fit bij 10, 20 en 30 graden Celsius, bruikbaar van 0-40 Celsius
  DifO2  = 1.0/(9.048299e-1 - 1.961736e-2*Tl + 1.076824e-4*pow(Tl,2.0))*1.0e-9;
  DifCH4 = 1.0/(1.081256    - 2.310800e-2*Tl + 1.189257e-4*pow(Tl,2.0))*1.0e-9;
  DifCO2 = 1.0/(9.644559e-1 - 2.058414e-2*Tl + 1.061623e-4*pow(Tl,2.0))*1.0e-9;
  DifN2  = 1.0/(9.874819e-1 - 2.112977e-2*Tl + 1.121742e-4*pow(Tl,2.0))*1.0e-9;
  DifH2S = 1.0/(1.15095     - 2.461722e-2*Tl + 1.265363e-4*pow(Tl,2.0))*1.0e-9;
  
   //De macht van de diffussiecoefficient
  n     = 1.0;
  k2O2  = k2CH4*pow((DifO2 /DifCH4),n);
  k2CO2 = k2CH4*pow((DifCO2/DifCH4),n);
  k2N2  = k2CH4*pow((DifN2 /DifCH4),n);
  k2H2S = k2CH4*pow((DifH2S/DifCH4),n);

  
  /*Different equilibrium constants (Temperature in Kelvin)*/
  T      = (Tl+273.0);


  
  /*concentrations in [mol/l] (using activities):*/
  
  IonStrength = 0.183*EGVo;
  f = CE_Activity(IonStrength);
  KValues(&K1,&K2,&Kw,&KS,T);
  coCO2=CE_pHM_CO2(pHo,coMn,K1,K2,Kw,f);
  
  
  
  coO2   = coO2/MrO2;
  coCH4  = coCH4/MrCH4;
  coN2   = coN2/MrN2;
  coH2S  = coH2S/MrH2S;
  cgoO2  = cgoO2/MrO2;
  cgoCH4 = cgoCH4/MrCH4;
  cgoCO2 = cgoCO2/MrCO2;
  cgoN2  = cgoN2/MrN2;
  cgoH2S = cgoH2S/MrH2S; 



  /*Stimela water quality outputs*/
  sys[U("Oxygen")]=           O2[NumCel-1]*MrO2;
  sys[U("Methane")]=          CH4[NumCel-1]*MrCH4;
  sys[U("Carbon_dioxide")]=   CO2[NumCel-1]*MrCO2;
  sys[U("Mnumber")]=      Mn[NumCel-1]*1000.0;
  CO2eff  = CO2[NumCel-1];
  Mneff   = Mn[NumCel-1];
  sys[U("pH")]=               CE_CO2M_pH(CO2eff, Mneff, K1, K2, Kw, f,pHo);
  //testpH = sys[U("pH")];
  //sys[U("Iron2")]=           (coFe2*(1-PercFe)+x(9*NumCel))*MrFe;
  //sys(U.Iron3)=              x(10*NumCel)*MrFe;
  //sys(U.Calcium)=            (coCa2*(1-PercCa)+x(11*NumCel))*MrCa;
  sys[U("Nitrogen")]=         N2[NumCel-1]*MrN2;
  sys[U("Hydrogen_sulfide")]= H2S[NumCel-1]*MrH2S;
  //sys(U.Clcium_carbonate)=x(12*NumCel)*MrCaCO3;
  
  //LogPr("CO2eff",&CO2eff,1);
  //LogPr("testpH",&testpH,1);
  
  	
	/*Determine additional outputs*/

    for (i=0; i < NumCel; i++)
    {
	sys[U("Number")+2+i]=MrO2*O2[i];
	sys[U("Number")+3+NumCel+i]=MrO2*goO2[i];
	sys[U("Number")+4+2*NumCel+i]=MrO2*kDO2*goO2[i];
	sys[U("Number")+5+3*NumCel+i]=MrCH4*CH4[i];
	sys[U("Number")+6+4*NumCel+i]=MrCH4*goCH4[i];
	sys[U("Number")+7+5*NumCel+i]=MrCH4*kDCH4*goCH4[i];
	sys[U("Number")+8+6*NumCel+i]=MrCO2*CO2[i];
	sys[U("Number")+9+7*NumCel+i]=MrCO2*goCO2[i];
	sys[U("Number")+10+8*NumCel+i]=MrCO2*kDCO2*goCO2[i];
	sys[U("Number")+11+9*NumCel+i]=MrN2*N2[i];
	sys[U("Number")+12+10*NumCel+i]=MrN2*goN2[i];
	sys[U("Number")+13+11*NumCel+i]=MrN2*kDN2*goN2[i];
	sys[U("Number")+14+12*NumCel+i]=MrH2S*H2S[i];
	sys[U("Number")+15+13*NumCel+i]=MrH2S*goH2S[i];
	sys[U("Number")+16+14*NumCel+i]=MrH2S*kDH2S*goH2S[i];
	}
  
}



