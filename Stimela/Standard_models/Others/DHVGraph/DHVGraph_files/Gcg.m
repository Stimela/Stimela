function gc=Gcz()

%   set(hDHV,'userdata',[hm(1) ho(5) ho(3) hl(5) hf(7) ho(4) hQuote]);
%   % (Gcz Gct Gcl Gcg Gcp Gcc Gcq)
%   set(gcf,'menubar','none');

gcNo=4;

gc = [];


while isempty(gc)
   
  hm = get(gcf,'children');
  telm = length(hm);

  while telm>0
    if strcmp(get(hm(telm),'type'),'uimenu')
      if strcmp(get(hm(telm),'label'),'&MenuDHV')
        user = get(hm(telm),'userdata');
        if (ishandle(user(gcNo)))
          gc = user(gcNo);
        end
      end
    end
     telm=telm-1;
  end
  
  if (isempty(gc))
    eval('Mdhv','');
  end
  
end

 

   
