/*
This is the C-version of the Stimela ozone model.

*/


#include "mex.h"
#include "simstruc.h"
#include "StimelaFcns.c"


#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]

#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)

#define P(D)   mxGetPr(mxGetField(Pin,0,D))

void LogPr(char* name, double *d,int n)
{
  FILE *fid;
  int i;

    fid=fopen("ozoncc_s_c.log","at");
	if (fid!=NULL)
	{
      fprintf(fid,"%s",name);
      for (i=0; i<n; i++)
        fprintf(fid,"\t%g",d[i]);

      fprintf(fid,"\n");
      fclose(fid);
	}
}

void ozoncc_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1
/*parameters */
double Hreact, Areact, MeeTe, db0, kUV_Sel, P_kUV, Y, KafbO3_Sel, P_KafbO3;
double ceUVA254_Sel, P_ceUVA254, FactorKLO3, F_BrO3init;
double kCt_BrO3_Sel, P_kCt_BrO3, F_AOC_Sel, P_F_AOC, kEc_Sel, kEc, Ct_lagEc;
int NumCel; 

/* uWQ */
double Tl, Ql, coO3, coDOC, coUVA254, coBrO3, coO3Dos,coO3Dos_kUV;
double coEc, copH, coBrmin, coAOC, Qg, cgoO3, coCt, Kinhib;


double dh, Tg, nu, rho, SurfTen;
double RQ, vl, vb0;
double MrO2, MrO3, MrN2, Po, pw, Tn, kDO3, DifO3, kLO3;
double O3Dos, ceO3Dos, O3Dos_kUV;
double ceO3Dos_kUV, kUV, KafbO3_10, KafbO3, ceUVA254, BrO3init, kCt_BrO3, F_AOC, ceAOC;  
double n, m;

int i;

double alfacountc[20], alfacoc[20];
double *O3, *dO3, *goO3, *dgoO3,*UVA254, *dUVA254, *BrO3, *dBrO3, *Ec, *dEc, *Ct, *dCt;

  
Areact       = *P("Areact");       // Surface Area ozone reactor [m2]
Hreact       = *P("Hreact");       // height of the reactor [m]
MeeTe        = 1.0;			        // For contact chambers co-current is assumed (1=co-current en 0=counter-current)
//Short_Circ   = *P("Short_Circ");  // short circuit flow through the bubble column as part of the total flow [-]
db0          = 0.003;   			// initial bubble diameter [m]
kUV_Sel      = *P("kUV_Sel");      // 1=kUV is given manual and 0=kUV is determined by the model
P_kUV        = *P("kUV");          // UVA254 decay rate [1/s]
Y            = *P("Y");            // Yield factor for ozone use per UVA decrease [(mg/l)/(1/m)]
KafbO3_Sel   = *P("KafbO3_Sel");   // 1=kO3 is given manual and 0=kO3 is determined by the model
P_KafbO3	 = *P("KafbO3");       // slow decay constante O3  
ceUVA254_Sel = *P("ceUVA254_Sel"); // 1=UVAo is given manual and 0=UVAo is determined by the model
P_ceUVA254   = *P("ceUV254");      // effluent value UVA254
FactorKLO3   = 99.0;			   // variable in the equation of Hughmark which varies for a single gas bubble (0.061)
									// and a set of bubbles (0.0187)
//KLO3Init     = *P("KLO3Init");     // when too much ozone is dosed, ozone gas will be present on top of the water surface in the
									// bubble column. Here also gas transfer will take place resulting in a higher kL in the top 
									// compartment, this can be corrected by increasing the kLO3 with kLO3init
F_BrO3init   = *P("F_BrO3init");   // FBrO3,ini constant for initial bromate formation (F*ozone dosage)
kCt_BrO3_Sel = *P("kCt_BrO3_Sel"); // 1=kBrO3 is given manual and 0=kBrO3 is determined by the model
P_kCt_BrO3     = *P("kCt_BrO3")/60.0;     // kBrO3 bromate formation rate constant
F_AOC_Sel    = *P("F_AOC_Sel");    // 1=FACO is given manual and 0=FAOC is determined by the model
P_F_AOC        = *P("F_AOC");        // FAOC constant for AOC formation (F*ozone dosage) [(ug-C/l)/(mg-O3/l)]
kEc_Sel      = *P("kEc_Sel");      // 1=kEc is given manual and 0=kEc is determined by the model
kEc          = *P("kEc")/60.0;          // k inactivation rate for E.coli
Ct_lagEc     = *P("Ct_lagEc")/60.0;     // Ctlag for E.coli
NumCel		 = (int) *P("NumCel");			//number of completely mixed reactors [-] 


if (NumCel > 20) NumCel=20;  /* Limit number of cells, because of limited memory allocation. */

Tl      	= uWQ[U("Temperature")];    // water temperature [Celsius]
Ql      	= uWQ[U("Flow")];           // water flow [m3/h]
coO3    	= uWQ[U("Ozone")];          // influent concentration O3 [mg/l]
coDOC   	= uWQ[U("DOC")];		     // influent concentration DOC [mg/l]
coUVA254	= uWQ[U("UV254")];		     // influent UV value [1/m]
//iniUVA254	= uWQ[U("Initial_UVA254")]; // initial UVA254 value [1/m]
coBrO3  	= uWQ[U("Bromate")];		 // influent Bromate value [ug/l]
coO3Dos 	= uWQ[U("Ozone_dosed")];    // amount of ozone dosed
coO3Dos_kUV = uWQ[U("Ozone_dos_kUV")];  // amount of ozone dosed for kUV
coEc    	= uWQ[U("Ecoli")];  	     // influent pathogen concentration
copH    	= uWQ[U("pH")];	         // influent pH [pH]
coBrmin 	= uWQ[U("Bromide")];        // influent bromide concentration [ug/l]
coAOC   	= uWQ[U("AOC")];            // influent AOC concentration [ug/l]
  
Qg      	= uES[0];       			 // air flow [m3/h]
cgoO3   	= uES[3];       			 // ozone concentration in gas [g/Nm3]

coCt    	= 0.0;                   	 // The initial Ct
Kinhib  	= 0.0001;              		 // Inhibition coefficient Monod constante mg-O3/l
										 // Alex vd Helm also tried 0.00001, however this did not show any improvements

dh		= Hreact/(double)NumCel;

/*Round of air temperature into round numbers */
Tg     	= Tl;                      		 // Air temperature in degrees Celsius
//Tg     	= round(Tg);               		 // The air temperature is rounded into whole degrees
nu     	= (497.0e-6)/pow((42.5+Tl),1.5);// kinematic viscosity m2/s for 0oC until 35oC
rho    	= 1000.0;                    	 // Density of water kg/m3
SurfTen	= -1.47e-4*Tl+7.56e-2;     	 // Surface tension for 0oC until 30oC
  
/* Determination of necessary quantities regarding flows and residence times*/
Ql       = Ql/3600.0;             		 // Convert flow from m3/h -> m3/s
//Ql_MF    = Ql*(1.0-Short_Circ);   		 // Main flow ozonated in reactor
//Ql_SC    = Ql*Short_Circ;       		 // Short circuit flow not ozonated in reactor
Qg       = Qg/3600.0;             		 // Convert gas flow from m3/h -> m3/s
RQ       = Qg/Ql;               		 // RQ waarde
//RQ       = Qg/Ql_MF;            		 // RQ waarde

/*
vl       = [];
for countvl = 1:size(NumCel_All,1);
{
   vlnew   = (Ql_MF*ones(NumCel_All(countvl,1),1))/Areact(countvl,1); // This is wrong, should be linked to QL!!!!!!
   //vlnew   = (Ql*ones(NumCel_All(countvl,1),1))/Areact(countvl,1);
   vl      = cat(1,vl,vlnew);
}
  vl = vl*ones(1,NumCel+1);
*/

vl	   = Ql/Areact;

vb0    = 0.0135*pow(((20000.0*SurfTen)/(rho*db0)),0.5);//=0.0135*(70*2/(100*db0))^0.5; // Bubble velocity moving upwards

/*
  %vb0    = 0.27;                % Belstijgsnelheid in stilstaand water in m/s
  hreact = flipud(cumsum(flipud(dh))-flipud(dh)/2); % Gaat ervan uit dat indien de bellenkolom uit meerdere blokken bestaat
                                                  % deze zijn opgegeven vanaf de ozondoseerschotel, zie opmerking ozoncc_d
                                                  % gedefinieerd voor meestroom
*/ 
  
//The relative molecular weights [g/mol] 
MrO2    = 31.9988;
MrO3    = 31.9988*(3.0/2.0);
MrN2    = 28.0134;

//Constants for calculation gas concentration in air
Po     = 101325.0;               // Po = standard pressure see level [Pa]  
/*
pw     = [  611   657   706   758   814   873   935  1002  1073  1148 ...  // pw = waterdamp pressure 0-50 Celsius [Pa]
             1228  1313  1403  1498  1599  1706  1819  1938  2064  2198 ...
             2339  2488  2645  2810  2985  3169  3363  3567  3782  4008 ...
             4246  4495  4758  5034  5323  5627  5945  6280  6630  6997 ...
             7381  7784  8205  8646  9108  9590 10094 10620 11171 11745 ...
            12344]; 
*/

pw 	   = 1070.0*exp(0.04986*Tg)-525.1;
Tn     = 273.15; // Temperature in degrees Kelvin


for (i=0; i < NumCel; i++) 
{
  alfacountc[i] = ((Po + (i+1.0-0.5)*dh*10000.0-pw)/Po)*(Tn/(Tn+Tg));
  alfacoc[i] = ((Po+(Hreact-((i+1.0-0.5)*dh))*10000.0-pw)/Po)*(Tn/(Tn+Tg));
}


/*  
  %Distributiecoëfficiënten van gassen in water voor 0, 10, 20 en 30 graden Celsius
  %TkD    = [0     ;10    ;20    ;30    ];
  %TkDO3  = [0.641;0.539;0.395;0.259];
  %TkD    = [0    ; 5    ; 10   ; 15   ; 20   ; 25   ; 30   ; 35   ]; % Langlais 1991
  %TkDO3  = [0.64 ; 0.50 ; 0.39 ; 0.31 ; 0.24 ; 0.19 ; 0.15 ; 0.12 ];
    
  %Berekening distributiecoëfficiënten voor tussenliggende temperaturen door lineaire interpolatie
  %kDO3   = INTERP1Q(TkD,TkDO3, Tl);
*/   

kDO3    = exp(-0.45-0.043*Tl); //Langlais 1991
  
// Equations for the diffusion coefficient based on DO3=1.74e-9 at 20oC from Langlais 1991 
// determined with the formula of NERNST EINSTEIN

DifO3	= 5.97e-15*(Tl+273.15)/(nu*rho);


if (FactorKLO3==99.0) // in case ozoncc_s is called from ozoncc the FactorKLO3 is made 0 in ozoncc_i and the kLO3 should be zero
{
    kLO3 = 0.0;	
}
else
{
    kLO3 = (DifO3/db0)*(2.0+FactorKLO3*(pow(((pow((vb0*db0/nu),0.48))*(pow((nu/DifO3),0.34))*pow(((db0*pow(9.81,0.33))/pow(DifO3,0.66)),0.072)),1.61)));

}


O3Dos       = (Qg*cgoO3)/Ql;
ceO3Dos     = coO3Dos+O3Dos;
O3Dos_kUV   = (Qg*cgoO3)/Ql;

if (ceO3Dos!=0) // In the first BC ozone is dosed
{
    
	if (Qg!=0)
	{
		coO3Dos_kUV=0;
    }
	
	ceO3Dos_kUV = coO3Dos_kUV+O3Dos_kUV;
	
    if (kUV_Sel==0)
	{
        kUV=3.75*exp(-3.443*ceO3Dos_kUV);
    }
	else
	{
	    kUV = P_kUV;
	}
    
	if (KafbO3_Sel==0)
	{
        KafbO3_10=0.0011*pow((coDOC/ceO3Dos),2.0);                //Decay coefficient at 10oC
        KafbO3=(KafbO3_10/(exp(-70000.0/(8.314*(Tn+10.0)))))*exp(-70000.0/(8.314*(Tn+Tl)));
    }
	else
	{
		KafbO3 = P_KafbO3;
	}

    if (ceUVA254_Sel==0)
	{
        ceUVA254=coUVA254-0.914*pow(ceO3Dos,0.5)*pow(coUVA254,0.5);
    }
	else
	{
		ceUVA254 = P_ceUVA254;
	}
	
	BrO3init = F_BrO3init*ceO3Dos;
	coBrO3 = coBrO3+BrO3init;
	
    if (kCt_BrO3_Sel==0)
	{
        kCt_BrO3=2.74e-7*pow(copH,5.82)*pow(coBrmin,0.73)*pow(1.035,(Tl-20.0)); //(ug-BrO3/mg-O3)*1/min
        kCt_BrO3=kCt_BrO3*1.0/60.0;                                   // (ug-BrO3/mg-O3)*1/s
    }
	else
	{
		kCt_BrO3 = P_kCt_BrO3;
	}

    if (F_AOC_Sel==0)
	{
        F_AOC=3.55e15*exp(-80500.0/(8.314*(Tn+Tl)));
    }
	else
	{
		F_AOC=P_F_AOC;
	}
	
	if (Qg!=0)
	{
		ceAOC=F_AOC*O3Dos*coDOC+coAOC;
	}
	else
	{
		ceAOC=coAOC;
	}
	
	
    if (kEc_Sel==0)
	{
        kEc=4.49*exp(3.305*ceO3Dos); // (l/mg-O3)*1/min*1/s
        kEc=kEc*1.0/60.0;            // (l/mg-O3)*1/s*1/s
    }
	
    /*
	else
	{
		kEc_lag    = kEc*ones(NumCel,1);
	}
	*/
}
else // In the first BC NO ozone is dosed
{
    ceO3Dos_kUV = 0.0;
    kUV         = 0.0;
    KafbO3      = 0.0;
    ceUVA254    = coUVA254;
    coBrO3      = coBrO3;
    kCt_BrO3    = 0.0;
    F_AOC       = 0.0;
    ceAOC       = coAOC;
    kEc         = 0.0;
    //kEc_lag     = kEc*ones(NumCel,1);
}


//MatQ1 = Matrix1(1,NumCel);

//Hom empircal constants 
n=1.0;
m=2.0;

//   concentrations in [mol/l] (make use of activities):
//	 coO3   = coO3/(1000*MrO3);
//   concentrations in [mmol/l] (make use of activities):
//   coO3   = coO3/MrO3;


//translation x into actual names
O3   		= &xC[0];
dO3  		= &sys[0];
goO3		= &xC[NumCel];
dgoO3 		= &sys[NumCel];
UVA254		= &xC[2*NumCel];
dUVA254		= &sys[2*NumCel];
BrO3		= &xC[3*NumCel];
dBrO3		= &sys[3*NumCel];
Ec			= &xC[4*NumCel];
dEc			= &sys[4*NumCel];
Ct			= &xC[5*NumCel];
dCt			= &sys[5*NumCel];


if (MeeTe==1)  // CO-CURRENT
{

//Ozone
//sys(1:NumCel)=(vl./dh).*MatQ1*[coO3;x(1:NumCel)]+kLO3.*RQ.*(vl/(vb0+vl))*(6/db0).*(alfacoc*kDO3.*x(NumCel+1:2*NumCel)-x(1:NumCel))-KafbO3*x(1:NumCel)-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*Y.*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
dTransport(dO3,O3,coO3,vl/dh,NumCel);
dReactionXi(dO3,goO3,kLO3*RQ*(vl/(vb0+vl))*(6.0/db0)*kDO3,alfacoc,NumCel);
dReactionX(dO3,O3,-kLO3*RQ*(vl/(vb0+vl))*(6.0/db0),NumCel);
dReactionX(dO3,O3,-KafbO3,NumCel);



//dMonodip(dO3,UVA254,-kUV*Y,ceUVA254,Kinhib,O3,NumCel);
/*
  for (i =0;i<NumCel;i++)
  {
    dO3[i] = dO3[i] -kUV*(UVA254[i]-ceUVA254)*Y*(O3[i]/(Kinhib+O3[i]));
  }
*/

dMonodi(dO3,UVA254,-kUV*Y,Kinhib,O3,NumCel);
dMonod(dO3,kUV*Y*ceUVA254,Kinhib,O3,NumCel);

//Ozone concentration in gas
//sys(NumCel+1:2*NumCel)=((vb0+vl)./dh).*MatQ1*[cgoO3;x(NumCel+1:2*NumCel)]-kLO3*(6/db0).*(alfa*kDO3.*x(NumCel+1:2*NumCel)-x(1:NumCel));
dTransport(dgoO3, goO3, cgoO3, (vb0+vl)/dh, NumCel);
dReactionXi(dgoO3, goO3, -kLO3*(6.0/db0)*kDO3,alfacoc, NumCel);
dReactionX(dgoO3, O3, kLO3*(6.0/db0), NumCel);

//UV254
//sys(2*NumCel+1:3*NumCel)=(vl./dh).*MatQ1*[coUVA254;x(2*NumCel+1:3*NumCel)]-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*(x(1:NumCel)./(Kinhib+x(1:NumCel)));

dTransport(dUVA254, UVA254, coUVA254, vl/dh, NumCel);
dMonodi(dUVA254,UVA254,-kUV,Kinhib,O3,NumCel);
dMonod(dUVA254,(-kUV*-ceUVA254),Kinhib,O3,NumCel);

/*
dUVA254[0] = (vl/dh)*(coUVA254 - UVA254[0]);
for (i=1; i<NumCel; i++)
{
	dUVA254[i] = (vl/dh)*(UVA254[i-1]-UVA254[i]);
}

for (i =0;i<NumCel;i++)
{
	dUVA254[i] = dUVA254[i] - kUV*(UVA254[i]-ceUVA254)*Y*(O3[i]/(Kinhib+O3[i]));
}
*/

//Bromate
//sys(3*NumCel+1:4*NumCel)=(vl./dh).*MatQ1*[coBrO3;x(3*NumCel+1:4*NumCel)]+kCt_BrO3*x(1:NumCel);
dTransport(dBrO3, BrO3, coBrO3, vl/dh, NumCel);
dReactionX(dBrO3, O3, kCt_BrO3, NumCel);

//Ec
//  %sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc_lag.*x(1:NumCel).*x(4*NumCel+1:5*NumCel); % Delayed Chick-Watson
//sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc.*m.*x(4*NumCel+1:5*NumCel).*x(1:NumCel).^n.*(cumsum(dh(:,1)./vl(:,1))).^(m-1); % Hom
dTransport(dEc,Ec,coEc,vl/dh,NumCel);
for (i =0;i<NumCel;i++)
  {
    dEc[i] = dEc[i] -kEc*m*Ec[i]*pow(O3[i],n)*pow((dh/vl),(m-1));
  }

//Ct
//sys(5*NumCel+1:6*NumCel)=(vl./dh).*MatQ1*[coCt;x(5*NumCel+1:6*NumCel)]+x(1:NumCel);
dTransport(dCt, Ct, coCt, vl/dh, NumCel);
dReactionX(dCt, O3, 1.0, NumCel);
}
else
{

//Ozone
//Countercurrent
//sys(1:NumCel)=(vl./dh).*MatQ1*[coO3;x(1:NumCel)]+kLO3.*RQ.*(vl(:,1)./(vb0-vl(:,1)))*(6/db0).*(alfacountc*kDO3.*flipud(x(NumCel+1:2*NumCel))-x(1:NumCel))-KafbO3*x(1:NumCel)-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*Y.*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
dTransport(dO3,O3,coO3,vl/dh,NumCel);
dReactionIi(dO3,goO3,kLO3*RQ*(vl/(vb0-vl))*(6.0/db0)*kDO3,alfacountc,NumCel);
dReactionX(dO3,O3,-kLO3*RQ*(vl/(vb0-vl))*(6.0/db0),NumCel);
dReactionX(dO3,O3,-KafbO3,NumCel);
dMonodi(dO3,UVA254,-kUV*Y,Kinhib,O3,NumCel);
dMonod(dO3,kUV*Y*ceUVA254,Kinhib,O3,NumCel);

//Ozone concentration in gas
//sys(NumCel+1:2*NumCel)=((vb0-vl)./dh).*MatQ1*[cgoO3;x(NumCel+1:2*NumCel)]-kLO3*(6/db0).*(alfacoc*kDO3.*x(NumCel+1:2*NumCel)-flipud(x(1:NumCel)));
//sys(NumCel+1:2*NumCel)=((vb0+vl)./dh).*MatQ1*[cgoO3;x(NumCel+1:2*NumCel)]-kLO3*(6/db0).*(alfa*kDO3.*x(NumCel+1:2*NumCel)-x(1:NumCel));
dTransport(dgoO3, goO3, cgoO3, ((vb0-vl)/dh), NumCel);
dReactionXi(dgoO3, goO3, -kLO3*(6.0/db0)*kDO3,alfacoc, NumCel);
dReactionI(dgoO3, O3, kLO3*(6.0/db0), NumCel);

//UV254
//countercurrent
//sys(2*NumCel+1:3*NumCel)=(vl./dh).*MatQ1*[coUVA254;x(2*NumCel+1:3*NumCel)]-kUV.*(x(2*NumCel+1:3*NumCel)-ceUVA254).*(x(1:NumCel)./(Kinhib+x(1:NumCel)));
dTransport(dUVA254, UVA254, coUVA254, vl/dh, NumCel);
dMonodi(dUVA254,UVA254,-kUV,Kinhib,O3,NumCel);
dMonod(dUVA254,(-kUV*-ceUVA254),Kinhib,O3,NumCel);

//Bromate
//countercurrent
//sys(3*NumCel+1:4*NumCel)=(vl./dh).*MatQ1*[coBrO3;x(3*NumCel+1:4*NumCel)]+kCt_BrO3*x(1:NumCel);
dTransport(dBrO3, BrO3, coBrO3, vl/dh, NumCel);
dReactionX(dBrO3, O3, kCt_BrO3, NumCel);

//Ec
//countercurrent
//sys(4*NumCel+1:5*NumCel)=(vl./dh).*MatQ1*[coEc;x(4*NumCel+1:5*NumCel)]-kEc.*m.*x(4*NumCel+1:5*NumCel).*x(1:NumCel).^n.*(cumsum(dh(:,1)./vl(:,1))).^(m-1); % Hom
dTransport(dEc,Ec,coEc,vl/dh,NumCel);
for (i =0;i<NumCel;i++)
  {
    dEc[i] = dEc[i] -kEc*m*Ec[i]*pow(O3[i],n)*pow((dh/vl),(m-1));
  }

//Ct
//countercurrent
//sys(5*NumCel+1:6*NumCel)=(vl./dh).*MatQ1*[coCt;x(5*NumCel+1:6*NumCel)]+x(1:NumCel);
dTransport(dCt, Ct, coCt, vl/dh, NumCel);
dReactionX(dCt, O3, 1.0, NumCel);
}

}

extern void ozoncc_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}

void ozoncc_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES, 
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{

//flag=3
int NumCel,i; 

double coO3Dos, coO3Dos_kUV, ceO3Dos_kUV, O3Dos_kUV;
double Tl, Ql, Qg, cgoO3, F_AOC_Sel, P_F_AOC, F_AOC, coDOC, coAOC, O3Dos, ceO3Dos, Tn, ceAOC;

double *O3, *goO3, *UVA254,  *BrO3, *Ec, *Ct ;


NumCel		 = (int) *P("NumCel");			//number of completely mixed reactors [-] 


F_AOC_Sel    = *P("F_AOC_Sel");    // 1=FACO is given manual and 0=FAOC is determined by the model
P_F_AOC      = *P("F_AOC");        // FAOC constant for AOC formation (F*ozone dosage) [(ug-C/l)/(mg-O3/l)]

Tl      	 = uWQ[U("Temperature")];    // water temperature [Celsius]
Ql      	 = uWQ[U("Flow")];           // water flow [m3/h]
coDOC   	 = uWQ[U("DOC")];		     // influent concentration DOC [mg/l]
coAOC   	 = uWQ[U("AOC")];            // influent AOC concentration [ug/l]
coO3Dos 	 = uWQ[U("Ozone_dosed")];    // amount of ozone dosed
coO3Dos_kUV  = uWQ[U("Ozone_dos_kUV")];  // amount of ozone dosed for kUV

Qg      	 = uES[0];       			 // air flow [m3/h]
cgoO3   	 = uES[3];       			 // ozone concentration in gas [g/Nm3]

Ql       	 = Ql/3600.0;             		 // Convert flow from m3/h -> m3/s
Qg       	 = Qg/3600.0;             		 // Convert gas flow from m3/h -> m3/s

Tn     		 = 273.15; // Temperature in degrees Kelvin


O3Dos        = (Qg*cgoO3)/Ql;
ceO3Dos     = coO3Dos+O3Dos;
O3Dos_kUV   = (Qg*cgoO3)/Ql;

if (ceO3Dos!=0) // In the first BC ozone is dosed
{
	ceO3Dos_kUV = coO3Dos_kUV+O3Dos_kUV;
	
	if (F_AOC_Sel==0)
	{
        F_AOC=3.55e15*exp(-80500.0/(8.314*(Tn+Tl)));
    }
	else
	{
		F_AOC=P_F_AOC;
	}
	
	if (Qg!=0)
	{
		ceAOC=F_AOC*O3Dos*coDOC+coAOC;
	}
	else
	{
		ceAOC=coAOC;
	}
}
else // In the first BC NO ozone is dosed
{
	ceAOC       = coAOC;
}



//translation x into actual names
O3   		= &xC[0];
goO3		= &xC[NumCel];
UVA254		= &xC[2*NumCel];
BrO3		= &xC[3*NumCel];
Ec			= &xC[4*NumCel];
Ct			= &xC[5*NumCel];

sysWQ[U("Ozone")]			= O3[NumCel-1];
sysWQ[U("UV254")]			= UVA254[NumCel-1];   
sysWQ[U("Bromate")] 		= BrO3[NumCel-1];   
sysWQ[U("Ecoli")]			= Ec[NumCel-1];
sysWQ[U("AOC")]				= ceAOC;
sysWQ[U("Ozone_dosed")]		= ceO3Dos;
sysWQ[U("Ozone_dos_kUV")]	= ceO3Dos_kUV;   


for (i=0; i < NumCel; i++)
  {
    sysEM[i]=O3[i];     
	sysEM[NumCel+i]=goO3[i];  
	sysEM[2*NumCel+i]=UVA254[i]; 
	sysEM[3*NumCel+i]=BrO3[i]; 
	sysEM[4*NumCel+i]=Ec[i];
	sysEM[5*NumCel+i]=Ct[i]/60.0;
  }

  
};
