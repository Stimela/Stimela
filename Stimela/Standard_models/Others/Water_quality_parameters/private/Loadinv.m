function [T,reeks]=Loadinv(FileNaam,KolNo)

extensie=FileNaam(length(FileNaam)-2:length(FileNaam));
if upper(extensie)=='MAT'
   load (FileNaam)
   if exist('Matrix')
      T=Matrix(:,1);
      reeks=Matrix(:,KolNo);
   else
      Foutmel(['File format not correct (no variable ''Matrix'' in file)'],'Foutmelding'); 
   end

else
   fid = fopen(FileNaam,'r');

   if fid <0
     error('file error')
   end

   regeltel=0;
   regel = fgetl(fid);
   while(~feof(fid))
      if regel(1)~='%'  % informatieregel
         digits=find((regel~=' ') & (regel~=char(9)));   %spatie, horizontal tab
         punttel=1;
         punten=digits(1);
         for dtel=2:length(digits)
            ruimte=digits(dtel) - digits(dtel-1);
            if ruimte>1
               punttel=punttel+1;
               punten(punttel)=digits(dtel-1);
               punttel=punttel+1;
               punten(punttel)=digits(dtel);
            end
         end
         if (round(length(punten)/2)-length(punten)/2) ~= 0
            punttel=punttel+1;
            punten(punttel)=digits(dtel);
         end
         regeltel=regeltel+1;
         for ktel=2:2:length(punten)
             Matrix(regeltel,ktel/2)=str2num(regel(punten(ktel-1):punten(ktel)));
         end
      end
      regel=fgetl(fid);
   end

   T=Matrix(:,1);
   reeks=Matrix(:,KolNo);

   fclose(fid);

end
