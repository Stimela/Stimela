
#include "mex.h"
#include "simstruc.h"

#define B(D) mxGetPr(mxGetField(Bin,0,D))[0]
#define U(D)   ((int) mxGetPr(mxGetField(Uin,0,D))[0]-1)
#define P(D)   mxGetPr(mxGetField(Pin,0,D))

//ErrorMessages (will stop simulation) :
// StimelaSetErrorMessage("Error:bladiebla");


void wsgetq_Derivatives(real_T *sysC, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  // flag=1


}

extern void wsgetq_Update(real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag =2 vullen xD;


}

extern void wsgetq_Outputs(real_T *sysWQ, real_T *sysEM, real_T t, real_T *xC, real_T *xD, real_T *uWQ, real_T *uES,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin)
{
  //flag=3
  int uNumber;
  
  uNumber = (int) *P("uNumber") - 1;

  sysEM[0] = uWQ[uNumber];
  
};
