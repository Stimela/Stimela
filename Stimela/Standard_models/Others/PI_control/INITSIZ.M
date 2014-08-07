function sys = initsz(sys0);

if length(sys0)<6
  sys0(6) = 0;
end
if length(sys0)<7
  sys0(7) = 1;
end

sizes = simsizes;

sizes.NumContStates  = sys0(1);
sizes.NumDiscStates  = sys0(2);
sizes.NumOutputs     = sys0(3);
sizes.NumInputs      = sys0(4);
sizes.DirFeedthrough = sys0(6);
sizes.NumSampleTimes = sys0(7);   % at least one sample time is needed

sys = simsizes(sizes);


