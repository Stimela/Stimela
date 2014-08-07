function My_projects_new

cd(stimFolder('My_projects'));


%test bestaat ie
res=2;
while res==2
   projectnaam=Editbox('project name','Stimela_project','choose project name','h');
      
   if isempty(projectnaam)
      return
   end
   
   projectnaam =strrep(projectnaam,' ','_');
   
   if isdir([stimFolder('My_projects') '\' projectnaam])
      Textbox('The project already exists','Foutmelding');
   else
      res=1;
   end
end

[PathNames, DirNames,ProjNames]=getprojnms;

n=Radiobox([DirNames ProjNames],'Choose a template for the new project',1);
if isempty(n)
   return
end

mkdir(projectnaam)


% alles van het standaard project kopieren
sourcefile=[deblank(PathNames(n,:)) '\' deblank(ProjNames(n,:)) '\*.*'];
destfile  = [stimFolder('My_projects') '\' projectnaam '\'];
copyfile(sourcefile,destfile,'f');
% end de subdir met StimelaData
sourcefile=[deblank(PathNames(n,:)) '\' deblank(ProjNames(n,:)) '\' st_StimelaDataDir '*.*'];
destfile  = [stimFolder('My_projects') '\' projectnaam '\' st_StimelaDataDir ];
copyfile(sourcefile,destfile,'f');

% hernoem hoofbestand naar nieuw bestand!
if ~strcmpi(deblank(ProjNames(n,:)),projectnaam)
  sourcefile=[stimFolder('My_projects') '\' projectnaam '\' deblank(ProjNames(n,:)) '.mdl'];
  destfile  = [stimFolder('My_projects') '\' projectnaam '\' projectnaam '.mdl'];
  movefile(sourcefile,destfile,'f')
end

addthis(projectnaam);
save_system('My_projects');

my_projects_open(projectnaam)

function addthis(nm)

n = 0;
a = find_system('My_projects','Name','0');
while length(a)>0
  n= n+1;
  a = find_system('My_projects','Name',num2str(n));
end

pos=get_param('My_projects/0','Position');
hoogte=pos(4)-pos(2);
pos(2)=pos(2)+n*1.3*hoogte;
pos(4)=pos(4)+n*1.3*hoogte;
nieuwblok=['My_projects/' num2str(n)];
add_block('My_projects/0',nieuwblok,'Position',pos);
set_param(nieuwblok,'OpenFcn', ['my_projects_open(''' nm ''')']);
set_param(nieuwblok,'BackgroundColor', 'lightBlue');
set_param(nieuwblok,'MaskDisplay', ['disp(''' nm ''')']);

function [pts,drs,fls] = getprojnms()

drs=[];
fls=[];
pts=[];

p=fillprojnms(stimFolder('My_projects'));
fls = strvcat(fls,p);
drs = strvcat(drs,ones(size(p,1),1)*['My_projects           ']);
pts =  strvcat(pts,ones(size(p,1),1)*stimFolder('My_projects'));

nm = [stimelaDir '\Stimela\Standard_projects'];
f = dir(nm);
for i=1:length(f)
    if f(i).isdir
        if f(i).name(1) ~='.' & f(i).isdir
            p=fillprojnms([nm '\' f(i).name]);
            fls = strvcat(fls,p);
            drs = strvcat(drs,ones(size(p,1),1)*[f(i).name '           ']);
            pts =  strvcat(pts,ones(size(p,1),1)*[nm '\' f(i).name]);
        end
    end
end

function fls = fillprojnms(nm)
f = dir(nm);

fls=[];
for i=1:length(f)
    if f(i).isdir
        if f(i).name(1) ~='.'
            fls = strvcat(fls,f(i).name);
        end
    end
end
