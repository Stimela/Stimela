
#include "mex.h"

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]

#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)

#define P(D)   mxGetPr(mxGetField(Pin,0,D))



void buffWQ_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1

  double A=1;

  sys[U("Temperature")]=1;


}

extern void buffWQ_Update(creal_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}

void buffWQ_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag=3
  int i;

  // direct feedthrough
  for (i=0;i<U("Number")+1;i++)
    sys[i]=u[i];
  for (i=0;i<B("Measurements");i++)
    sys[U("Number")+1+i]=0.0;


  sys[U("Temperature")]=1;

};
