function data=st_LoadTxt(filename)
% inlezen txt file voor plotten in grafieken

data=[];
if exist(filename)==2
  try
    [data] = textread(filename,'','delimiter',' ','commentstyle','shell','emptyvalue',NaN);
  end
end

