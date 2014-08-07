function obj = PID(varargin)
% PID controller for Matlab
% initialize : Controller = PID(P,I,D,y0,ymin,ymax);
% control : Controller = timestep(Controller,t,e);
% output  : y = output(Controller);
%
% Constructor for a PID class object.
%

%% © 2009, Kim van Schagen

if nargin==0 % Used when objects are loaded from disk
  obj = init_fields;
  obj = class(obj, 'PID');
  return;
end
firstArg = varargin{1};
if isa(firstArg, 'PID') %  used when objects are passed as arguments
  obj = firstArg;
  return;
end

% We must always construct the fields in the same order,
% whether the object is new or loaded from disk.
% Hence we call init_fields to do this.
obj = init_fields; 

% attach class name tag, so we can call member functions to
% do any initial setup
obj = class(obj, 'PID'); 

% Now the real initialization begins
obj.P = varargin{1};
obj.I = varargin{2};
obj.D = varargin{3};

if nargin>3
  obj.y0 = varargin{4};
end
if nargin>4
  obj.ymin = varargin{5};
end
if nargin>5
  obj.ymax = varargin{6};
end


%%%%%%%%% 

function obj = init_fields()
% Initialize all fields to PID values 
obj.P = 1;
obj.I = 1;
obj.D = 0;
obj.lastT = NaN;
obj.IPart = 0;
obj.y0 = 0;
obj.ymin = -inf;
obj.ymax = inf;
obj.y = 0;
