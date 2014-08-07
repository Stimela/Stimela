function dy=Dhv_fixx(lims,n)
% lims minimale en maximale waarden
% n aantal punten

dl = lims(2)-lims(1);
dln = dl/(n-1);

dn = (10^floor(log10(dln)));
dl = floor(dln/dn)*dn;


dy = ceil(lims(1)/dn)*dn:dl:floor(lims(2)/dn)*dn;


