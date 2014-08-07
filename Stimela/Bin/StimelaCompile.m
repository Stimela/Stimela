function StimelaCompile(dr,nm)
% compile of a single Stimela module

dr0=cd;

if nargin<1
    dr=cd;
end

if exist(dr)
  cd(dr);
else
    dr = cd;
end

if nargin<2
    d=dir;
    for n=1:size(d,1)
        i = strfind(d(n).name,'_s_c.c');
        if ~isempty(i)
            nm = d(n).name(1:i-1);
           
            StComp(dr,nm);

        end
    end
else
    StComp(dr,nm);
end

cd(dr0);



function StComp(dr,nm)

% vrijgeven 
clear([nm '_s_c'])

% oude dingen weggooien
delifexists(['..\' nm '_s_c.dll'])
delifexists([nm '_s_c.dll'])
delifexists(['..\' nm '_s_c.mexw32'])
delifexists([nm '_s_c.mexw32'])

vr = ver('matlab');
if vr(1).Version(1)=='6'
  try
    mex([nm '_s_c.c'], [nm '_s_code.c']);
    copyfile([nm '_s_c.dll'],['..\' nm '_s_c.dll']);
  catch
    disp('error while compiling')
  end
end
if vr(1).Version(1)=='7'
  try
    % voor de zekerheid
    mex([nm '_s_c.c'], [nm '_s_code.c']);
    copyfile([nm '_s_c.mexw32'],['..\' nm '_s_c.mexw32'])
  catch
    disp(['Error while compiling ' nm '_s_c'])
  end
end

function delifexists(nm)

if exist(nm)>0
  delete(nm)
end
