function Res = PIDupdate(obj,t,s,x)
% new timepoint for the PID controller
% t - current time
% s - setpoint
% x - measurement

% fout
e = s-x;

if isnan(obj.lastT)
  disp('Init PID controller');
  
  obj.lastT = t;
  obj.IPart = obj.y0 - obj.P*e;
end 

if obj.lastT>t
  disp('Resetting PID controller');

  obj.lastT = t;
  obj.IPart = obj.y0 - obj.P*e;
end

% integrator
dt = (t-obj.lastT);
if dt>obj.I/2
  % maximale tijdstap voor de integrator
  dt = obj.I/2;
end
obj.IPart = obj.IPart + obj.P/obj.I*e*dt;
obj.lastT=t;

%controle min/max
obj.y = obj.IPart+obj.P*e;
if obj.y < obj.ymin
  obj.y = obj.ymin;
  obj.IPart = obj.ymin - obj.P*e;
end
if obj.y > obj.ymax
  obj.y = obj.ymax;
  obj.IPart = obj.ymax - obj.P*e;
end

Res = obj;


