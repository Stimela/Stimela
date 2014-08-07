// functions used for aeration

double fi(double z, double a, double EGV)
{
  double fiF, I;
  
  fiF = 0;
  
  EGV = EGV/1000.0;
  I = 0.183*EGV; //[mol/l] approximation formula
  if ((I>=0) & (I<0.1)) {
    fiF=pow(10,(-0.5*pow(z,2)*(pow(I,0.5)/(1+0.33*a*pow(I,0.5)))));
  } else {
    if ((0.1<=I) & (I<=0.5)) {
      fiF=pow(10,(-0.5*pow(z,2)*((pow(I,0.5)/1+0.33*a*pow(I,0.5))-0.2*I)));
    }	
  }
  
  return fiF;

}	
  