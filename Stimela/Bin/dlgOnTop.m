function dlgOnTop(AddDlgHndl)

if nargin < 1
  AddDlgHndl = [];
end

stTagName = 'StimelaDialogue';
Title = 'Stimela';

DlgHndl = findobj('Name', Title);

TagNo = [];
for cntDH = 1 : length(DlgHndl)
  hndl = DlgHndl(cntDH);
  tagname = get(hndl, 'Tag');
  len = length(stTagName);
  if length(tagname) > len
    if tagname(1 : len) == stTagName
      tagnumber = str2num(tagname(len + 1 : length(tagname)));
      TagNo = [TagNo; [hndl tagnumber]];
    end
  end
end

if ~isempty(AddDlgHndl)
  if isempty(TagNo)
    tagnumber = 0;
  else
    tagnumber = max(TagNo(:, 2)) + 1;
  end
  set(AddDlgHndl, 'Tag', [stTagName num2str(tagnumber)]);
  TagNo = [TagNo; [AddDlgHndl tagnumber]];
end

if ~isempty(TagNo)
 	[dummy, I] = sort(TagNo(:, 2));
  TagNo = TagNo(I, :);
  for cntrow = 1 : length(TagNo(:, 1))
    figure(TagNo(cntrow, 1));
  end
end