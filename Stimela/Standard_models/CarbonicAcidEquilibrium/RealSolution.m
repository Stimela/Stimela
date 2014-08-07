function Solution = RealSolution(AllSolutions)

n = find(isreal(AllSolutions))
if length(n)>1
  Solution = find(max(AllSolutions(n)));
elseif length(n)==0
  error('solution imaginary')
else
  Solution = AllSolution(n);
