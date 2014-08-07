function [Cycle_On, Cycle_Off, Status, Errstr] = selCycle(OnOff, noCycle)
%
%======================================================================================
% [Cycle_On, Cycle_Off, Status, Errstr] = selCycle(OnOff, noCycle);
%======================================================================================
%
% (Function)
% Select one particular cycle from a series of cycles. Each cycle is characterised by
% a series of ones followed by a series of zeros. selCycle returns the indices of the
% selected cycle.
%
% (Inputs)
% OnOff     : vector containing zeros and ones
%	            1 = Cycle_On period
%             0 = Cycle_Off period
%             1 after 0 = start of new cycle
% noCycle   : Cycle to be selected
%
% (Outputs)
% Cycle_On  : indices of the elements in the OnOff-vector that make up the Cycle_Off
%             period (series of ones in the selected cycle)
% Cycle_Off : indices of the elements in the OnOff-vector that make up the Cycle_Off
%             period (series of zeros in the selected cycle after the Cycle_Off period)
% Status    : -1 = the OnOff vector contains less cycles than noCycle
%                  (value of noCycle is too large)
%             0  = error
%             1  = ok
%
%
% © Adriën van den Berge, July 7th 2000

%--------------------------------------------------------------------------------------


try		% launch error handling
    
  %	Initialisation
	Status = 0;
	indOnOff = 1;		% index in OnOff
	Cycle_On = [];
	Cycle_Off = [];
    Errstr = [];
  
  %	Initialise cntCycles: counts the number of cycles in OnOff
	if OnOff(indOnOff) == 0
   	cntCycles = 0;
	elseif OnOff(indOnOff) == 1
   	Cycle_On = [Cycle_On; [indOnOff]];
	  cntCycles = 1;
	end
  indOnOff = indOnOff + 1;

%	Run through vector OnOff: find cycle noCycle and fill Cycle_On and Cycle_Off
  %	Keep running until cycle noCycle is found or the end of vector OnOff is reached
  while (cntCycles <= noCycle) & (indOnOff < length(OnOff))
    
    % Detect start of new cycle(a change in OnOff from 0 to 1)
    if ((OnOff(indOnOff) - OnOff(indOnOff-1)) == 1)
   	  cntCycles = cntCycles + 1;
    end
    
    %	Detect cycle numero noCycle and fill Cycle_On and Cycle_Off with the corresponding indices
   	if cntCycles == noCycle
    	if OnOff(indOnOff) == 1
        Cycle_On = [Cycle_On; [indOnOff]];
	    elseif OnOff(indOnOff) == 0
   	    Cycle_Off = [Cycle_Off; [indOnOff]];
      end
	    Status = 1;
    end
    
    % Check next element in vector OnOff
	  indOnOff = indOnOff + 1;
	end		% while

% Too few cycles in OnOff?
	if cntCycles < noCycle
	  Status = -1;
	end



%====================== Error handling ==============================================
catch
  Status = 0;
  Errstr = lasterr;
end		% try ... catch ...