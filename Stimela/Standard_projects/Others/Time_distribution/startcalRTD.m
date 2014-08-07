function [cal] = startcalAWWA(FileName)

%clear all

CalInit = 100;
CalPar={'th'};
CalMin = [1e-8];
CalMax = [1e8]; 
CalMagPar = [10000000];%[0.001;0.01;0.1;1;10];
CalNo   = 0;
CalOpt  = [1000 1e-10 1e-7];
count=0;
for n=[800 857 900]%1:10:101
    count=count+1
    CSTR = n;
    for Cali = 1:size(CalMagPar,1)
        MagnitudeCal = CalMagPar(Cali,1);
        CalNo=CalNo+1
     %   MagnitudeCal  = [MagnitudeCal];
     %   CalInit = [CalInit];
        options = optimset('LargeScale','off','Display','iter',...
              'MaxFunEvals',CalOpt(1,1),'TolX',CalOpt(1,2),'TolFun',CalOpt(1,3));
        Cal = lsqnonlin(@calRTD, CalInit/CalMagPar, CalMin, CalMax, options, FileName, MagnitudeCal,CalPar,CSTR)
        F   = calRTD(Cal,FileName,MagnitudeCal,CalPar,CSTR); 
        F   = sum(F.^2);
        CalResult(CalNo,:) = [MagnitudeCal Cal*MagnitudeCal]
        beep
        beep
        beep
    end
    Res(count,:) = [CSTR Cal*MagnitudeCal F];
end
load handel
sound(y,12000)%sound(y,Fs)

save calresult.mat Res

%% Maak een structure met alle relevante gegevens erin
%Calibration.Name    = FileName;
%Calibration.Par     = CalPar;
%Calibration.Init    = CalInit;
%Calibration.MagPar  = CalMagPar;
%Calibration.Min     = CalMin;
%Calibration.Max     = CalMax;
%Calibration.Option  = CalOpt;
%Calibration.Res     = CalResult;

%%eval(['save calresult_' FileName '.mat CalResult'])
%CurrentDate = datestr(datenum(clock),30);
%save(['CalRes_' FileName '_' CurrentDate(1,3:8) '.mat'],'Calibration')
datestr(now)


