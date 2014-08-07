function My_models_new

cd(stimFolder('My_models'));


%test bestaat ie
res=2;
modeldescr = 'New_Model';
modelnaam = 'stimmo';

while res==2
   tmp=Editbox(str2mat('model description','model name (6 characters)'),str2mat(modeldescr,modelnaam),'choose model name','h');

  if isempty(tmp)
      return
   end

   modeldescr =strrep(deblank(tmp(1,:)),' ','_');
   modelnaam =strrep(deblank(tmp(2,:)),' ','_');
  

   if length(modelnaam)~=6
      Textbox('The model name should be 6 characters long','Foutmelding');
   else       
     if isdir([stimFolder('My_models') '\' modeldescr])
       Textbox('The model Description already exists','Foutmelding');
     else
       if exist([modelnaam '_i.m'])
         OK = Questbox(['Model ' modelnaam ' exists already, Are you sure you want to continue?'],'Warning');
         if OK==1
           res=1;
         end
       else
         res=1;
       end
     end
  end  
end

[PathNames,DirNames,DescrNames,ModelNames]=getmodelnms;

n=Radiobox([DirNames DescrNames ModelNames],'Choose a template for the new model',1);
if isempty(n)
   return
end

mkdir(modeldescr)

% alles van het standaard model kopieren
chdir(modeldescr)
% copy the empty template
copyBlocks(modelnaam,'block0')
% and the existing items
copyBlocks(modelnaam,deblank(ModelNames(n,:)),deblank(PathNames(n,:)))

addthis(modeldescr,modelnaam);
save_system('My_models');

% en het pad toevoegen voor modellering
path(cd,path);

my_models_open(modeldescr,modelnaam)

function addthis(des,nm)

n = 0;
a = find_system('My_models','Name','0');
while length(a)>0
  n= n+1;
  a = find_system('My_models','Name',num2str(n));
end

pos=get_param('My_models/0','Position');
hoogte=pos(4)-pos(2);
pos(2)=pos(2)+n*1.3*hoogte;
pos(4)=pos(4)+n*1.3*hoogte;
nieuwblok=['My_models/' num2str(n)];
add_block('My_models/0',nieuwblok,'Position',pos);
set_param(nieuwblok,'OpenFcn', ['my_models_open(''' des ''',''' nm ''')']);
set_param(nieuwblok,'BackgroundColor', 'Orange');
set_param(nieuwblok,'MaskDisplay', ['disp(''' des ''')']);

function [pts,drs,fls,mos] = getmodelnms()

drs=[];
fls=[];
mos=[];
pts=[];

%Eerst My_models
[p,s,m]=fillprojnms([stimFolder('My_models')]);
pts = strvcat(pts,p);
fls = strvcat(fls,s);
mos = strvcat(mos,m);
drs = strvcat(drs,ones(size(p,1),1)*['My_models           ']);

d = [stimelaDir '\Stimela\Standard_models'];
f = dir(d);

for i=1:length(f)
    if f(i).isdir
        if f(i).name(1) ~='.' & f(i).isdir
            [p,s,m]=fillprojnms([d '\' f(i).name]);
            pts = strvcat(pts,p);
            fls = strvcat(fls,s);
            mos = strvcat(mos,m);
            drs = strvcat(drs,ones(size(p,1),1)*[f(i).name '           ']);
        end
    end
end

function [pts,fls,nms] = fillprojnms(nm)
f = dir([nm]);

fls=[];
nms=[];
pts=[];
for i=1:length(f)
    if f(i).isdir
        if f(i).name(1) ~='.'
            a=dir([nm '\' f(i).name '\*_d.m']);
            for j = 1:length(a)
              fls = strvcat(fls,f(i).name);
              nms = strvcat(nms,a(j).name(1:6));
              pts = strvcat(pts,[nm '\' f(i).name]);
            end
        end
    end
end
