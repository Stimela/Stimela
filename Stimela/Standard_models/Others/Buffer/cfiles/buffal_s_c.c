/*
 */


#define S_FUNCTION_NAME  buffal_s_c
#define S_FUNCTION_LEVEL 2

#define B(S,D) mxGetPr(mxGetField(ssGetSFcnParam(S, 0),0,D))[0]

#define x0(S)  mxGetPr(ssGetSFcnParam(S, 1))
#define Mx0(S)  ssGetSFcnParam(S, 1)

#define U(S,D)   mxGetPr(mxGetField(ssGetSFcnParam(S, 2),0,D))[0]

#define P(S,D)   mxGetPr(mxGetField(ssGetSFcnParam(S, 3),0,D))


/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

extern void buffal_Derivatives(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin);
extern void buffal_Update(real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin);
extern void buffal_Outputs(real_T *sys, real_T t, real_T *xC, real_T *xD, real_T *u,
                         mxArray *Bin, mxArray *Uin, mxArray *Pin);


/* Error handling
 * --------------
 *
 * You should use the following technique to report errors encountered within
 * an S-function:
 *
 *       ssSetErrorStatus(S,"Error encountered due to ...");
 *       return;
 *
 * Note that the 2nd argument to ssSetErrorStatus must be persistent memory.
 * It cannot be a local variable. For example the following will cause
 * unpredictable errors:
 *
 *      mdlOutputs()
 *      {
 *         char msg[256];         {ILLEGAL: to fix use "static char msg[256];"}
 *         sprintf(msg,"Error due to %s", string);
 *         ssSetErrorStatus(S,msg);
 *         return;
 *      }
 *
 * See matlabroot/simulink/src/sfuntmpl_doc.c for more details.
 */

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
int CheckPar(S)
{
  // B check fields
  // x0 check real + lengte
  // U check Number + items
  // P check Parameters?!


  return 0;
}
static void mdlInitializeSizes(SimStruct *S)
{

  ssSetNumSFcnParams(S, 4);  /* B,x0,U,P Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    return;
  else
  {
    if (CheckPar(S))
      return;
  }

    ssSetNumContStates(S, (int) B(S,"CStates"));
    ssSetNumDiscStates(S, (int) B(S,"DStates"));

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, (int)  (U(S,"Number")+B(S,"Setpoints")));
    ssSetInputPortDirectFeedThrough(S, 0, (int) B(S,"Direct"));
    ssSetInputPortRequiredContiguous(S, 0, 1); /*direct input signal access*/

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, (int) (U(S,"Number")+B(S,"Measurements")) );

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

  /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR);
   
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, B(S,"SampleTime"));
    ssSetOffsetTime(S, 0, 0.0);
}



#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
    real_T *xC   = ssGetContStates(S);
    real_T *xD   = ssGetRealDiscStates(S);
  
    int i; 
    i = mxGetNumberOfElements(Mx0(S));
    if (i!= (int) (B(S,"CStates")+B(S,"DStates")))
    {
        ssSetErrorStatus(S,"Number of states and number of IC do not match" );
    }
  
    for (i=0; i<(int)B(S,"CStates"); i++)
    {
        xC[i]=x0(S)[i];
    }
  
    for (i=0; i<(int)B(S,"DStates"); i++)
    {
        xD[i]=x0(S)[(int) (B(S,"CStates"))+i];
    }
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T t, *xC, *xD, *u, *sys;

    int i;
    
    t  = ssGetT(S);
    xC = ssGetContStates(S);
    xD = ssGetDiscStates(S);
    u  = ssGetInputPortRealSignal(S,0);
    sys  = ssGetOutputPortRealSignal(S,0);

    buffal_Outputs(sys,t,xC,xD,u,
      ssGetSFcnParam(S, 0),ssGetSFcnParam(S, 2),ssGetSFcnParam(S, 3));
}



#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
    real_T t, *xC, *xD, *u;

    int i;
    
    t  = ssGetT(S);
    xC = ssGetContStates(S);
    xD = ssGetDiscStates(S);
    u  = ssGetInputPortRealSignal(S,0);

    buffal_Update(t,xC,xD,u,
      ssGetSFcnParam(S, 0),ssGetSFcnParam(S, 2),ssGetSFcnParam(S, 3));
  }
#endif /* MDL_UPDATE */



#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {

    real_T t, *xC, *xD, *u, *sys;

    int i;
    
    t  = ssGetT(S);
    xC = ssGetContStates(S);
    xD = ssGetDiscStates(S);
    u  = ssGetInputPortRealSignal(S,0);
    sys  = ssGetdX(S);

    buffal_Derivatives(sys,t,xC,xD,u,
      ssGetSFcnParam(S, 0),ssGetSFcnParam(S, 2),ssGetSFcnParam(S, 3));
    
  }
#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}


/*======================================================*
 * See sfuntmpl_doc.c for the optional S-function methods *
 *======================================================*/

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
