//Generic functions for use in the Stimela - S functions
#include <math.h>

/*================= All versions =================*/

/*------------ Mathematical ------------*/

// Not in use (MSparnaaij 15-3-2012)
double round(double x)
{
  double y;

   y = floor(x+0.5);
   
   return y;
}

// Not in use (MSparnaaij 15-3-2012)
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

double sum(double x[],int NumCel)
{
  int i;
  double y;
  
  y = 0;
  
  for (i =0;i<NumCel;i++) {
    y = y+x[i];
  }
  return y;
}

void cumsum(double y[], double x[], int NumCel)
{
  int i;
  y[0]=x[0];
    
  for (i =1;i<NumCel;i++) {
   y[i]=y[i-1]+x[i];
  }
}  

/*------------ Derivative through ... ------------*/

void dTransport(double sys[], double x[], double xin, double v, int NumCel)
{
  //derivative through transport
  int i;
  
  sys[0] = v*(xin-x[0]);
  for (i =1;i<NumCel;i++) {
    sys[i] = v*(x[i-1]-x[i]);
  }
}

void dReactionX(double sys[], double x[], double K, int NumCel)
{
  //derivative through reaction 
  //add to current derivative
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*x[i];
  }
}

void dReactionI(double sys[], double x[], double K, int NumCel)
{
  //derivative through reaction 
  //add to current derivative
  //for countercurrent
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*x[NumCel-1-i];
  }
}

void dMassTrans(double sys[], double x[], double xin, double K, int NumCel)
{
  //derivative through masstransport difference
  // add to current derivative
  int i;
  
  sys[0] = sys[0] + K*(xin-x[0]);
  for (i =1;i<NumCel;i++) {
    sys[i] = sys[i] + K*(x[i-1] -x[i]);
  }
}

void dTransportGas(double sys[], double x[], double xin, double v, int NumCel)
{
  //derivative through transport
  int i;
  
  sys[0] = v*(xin-x[0]);
  for (i =1;i<NumCel;i++) {
    sys[i] = v*(xin-x[i]);
  }
}

void dReactionXi(double sys[], double x[], double K, double Ki[], int NumCel)
{
  //derivative through reaction 
  //add to current derivative
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*Ki[i]*x[i];
  }
}


void dReactionIi(double sys[], double x[], double K, double Ki[], int NumCel)
{
  //derivative through reaction 
  //add to current derivative
  //for countercurrent
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*Ki[i]*x[NumCel-1-i];
  }
}

void dMonodi(double sys[], double x[], double K, double KMonod, double xMonod[], int NumCel)
{
  //derivative through Monod reaction 
  //add to current derivative
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*x[i]*(xMonod[i]/(KMonod+xMonod[i]));
  }
}

// Not in use (MSparnaaij 15-3-2012)
void dMonodip(double sys[], double x[], double K, double Kt, double KMonod, double xMonod[], int NumCel)
{
  //derivative through Monod reaction 
  //add to current derivative
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*(x[i]-Kt)*(xMonod[i]/(KMonod+xMonod[i]));
  }
}

void dMonod(double sys[], double K, double KMonod, double xMonod[], int NumCel)
{
  //derivative through Monod reaction 
  //add to current derivative
  int i;
  
  for (i =0;i<NumCel;i++) {
    sys[i] = sys[i] + K*(xMonod[i]/(KMonod+xMonod[i]));
  }
}


/*=============== Specific versions ===============*/

// interp1Q has two versions which differ in the return rule.

// ozoncc, ozonox, biofil, enkfil
double interp1Q(double x[], double y[],int nx, double xi)
{
  int i;
  
  if (xi<=x[0]) {
    return y[0];
  }
	
  if (xi>=x[nx-1]) {
    return y[nx-1];
  }

  i=1;
  while (x[i]<xi) {
    i=i+1;
  }
  
  return y[i-1] + (xi-x[i-1])/(x[i]-x[i-1])*y[i];
}

// cascad, plaatb
// Not in use (MSparnaaij 15-3-2012)
double interp1Q_cas(double x[], double y[],int nx, double xi)
{
  int i;
  
  if (xi<=x[0]) {
    return y[0];
  }
	
  if (xi>=x[nx-1]) {
    return y[nx-1];
  }

  i=1;
  while (x[i]<xi) {
    i=i+1;
  }
  
  return y[i-1] + ((y[i]-y[i-1])/(x[i]-x[i-1]))*(xi-x[i-1]);
}