function [K1,K2,Kw,Ks] = KValues(Temp)
% KValues depending on activity
 
 K1=10.^(3 - 356.3094 -.06091964.*Temp + 21834.37./Temp  ...
        + 126.8339.*log10(Temp) - 1684915./(Temp.^2));
 K2=10.^(3 - 107.8871 -.03252849.*Temp + 5151.79./Temp ...
        + 38.92561.*log10(Temp) - 563713.9./(Temp.^2));
 Kw= 10.^(6 - 4787.3./Temp - 7.1321.*log10(Temp) - 0.010365.*Temp +22.801);

 Ks= 10.^(6 + 9.2536 - 0.032449.*Temp -2386.038./Temp);

    
