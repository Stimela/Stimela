function [V]=st_Varia(TagType);
% [Variables]=st_Varia(TagType)
%   Get all VariabeleLocations for the current Stimela enviroment
%
%   possible TagType
%     LongNames => long names
%     ShortNames => short names
%     SiteNames => names according to site list
%   The list has always the element Variabeles.Number with the number
%   of Tags
%  
% Stimela, 2004

% © Kim van Schagen,

if nargin<1
    TagType='LongNames';
end

A=st_Variabelen;

nummer=length(A);
V=[];
for i =1:nummer
    switch TagType
        case 'LongNames'
            V = setfield(V,A(i).LongName,i);
        case 'ShortNames'
            V = setfield(V,A(i).ShortName,i);
        case 'SiteNames'
            V = setfield(V,A(i).SiteName,i);
        otherwise
            error('Incorrect Argument for st_varia: ''LongNames'', ''ShortNames'' or ''SiteNames''');
    end
end

V.Number = nummer;
            
            
            



