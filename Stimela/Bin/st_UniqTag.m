function TagName = UniqTag(Str);

if nargin < 1
  Str = '';
end

ok = 0;
AppendStr = '0';		% String appended to Str if Str is already used as TagName by another object
cntAppend = 0;			% Number to append as Appendstring
%	Go on until a unique TagName has been found
while ~ok
  Str = [Str AppendStr];		% Check if this string is already used as TagName by another object
  Hndl = findobj('Tag', Str);		% If Hndl is empty: Str is a unique TagName
  if isempty(Hndl)
    ok = 1;
  else
    % Try another AppendString
    cntAppend = cntAppend + 1;
    AppendStr = num2str(cntAppend);
  end
end		% while ~ok

TagName = [Str AppendStr];