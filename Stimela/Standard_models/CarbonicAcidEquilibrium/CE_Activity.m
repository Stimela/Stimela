function f = CE_Activity(IonStrength)
 f = 10.^(-1*(0.5*sqrt(IonStrength)./ ...
                  (sqrt(1e3)+sqrt(IonStrength))-0.00015*IonStrength));

    
