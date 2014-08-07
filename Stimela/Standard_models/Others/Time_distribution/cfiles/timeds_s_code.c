
#include "mex.h"

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]

#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)

#define P(D)   mxGetPr(mxGetField(Pin,0,D))



void timeds_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1

  double th,dt,NumCel;
  int n ;
  
  NumCel=P("NumCel")[0];
  th=P("th")[0];

  dt=th/NumCel;
  
  sys[0]=(u[U("Conductivity")]-xC[0])/dt;
  for (n=1;n<NumCel;n++)
  {
    sys[n]=(xC[n-1]-xC[n])/dt;
  };

}

extern void timeds_Update(creal_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}

void timeds_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag=3
  int i;
  double NumCel;
  
  NumCel=P("NumCel")[0];


  // direct feedthrough
  for (i=0;i<U("Number")+1;i++)
    sys[i]=u[i];
  for (i=0;i<B("Measurements");i++)
    sys[U("Number")+1+i]=0.0;

    sys[U("Conductivity")] = xC[(int)NumCel-1];
    
};
