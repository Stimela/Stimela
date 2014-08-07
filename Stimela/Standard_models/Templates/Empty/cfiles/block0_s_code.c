
#include "mex.h"
#include "simstruc.h"

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))

extern SimStruct *SS;

void block0_Derivatives(real_T *sysC, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1

  //  ssSetErrorStatus(SS,"Error: ....." );


}

extern void block0_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}

extern void block0_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag=3

  
};
