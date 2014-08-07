function Q = st_Variabelen
% all Stimela Tags in the current Stimela enviroment
%  
% Stimela, 2004

% © Kim van Schagen

Q = [];

% add Variabele 		Long Name, 				Short Name, 	Unit, 	SiteName
Q = st_addQComponent(Q, 'Flow',             	'F',   			'm^3/h');
Q = st_addQComponent(Q, 'Temperature',      	'T',   			'^oC');
Q = st_addQComponent(Q, 'Suspended_solids', 	'SS',  			'mg/l');
Q = st_addQComponent(Q, 'Turbidity',        	'TB',  			'FTE');
Q = st_addQComponent(Q, 'DOC',              	'DOC', 			'mg/l');
Q = st_addQComponent(Q, 'Ozone',            	'O3',  			'mg/l');
Q = st_addQComponent(Q, 'Oxygen',           	'O2',  			'mg/l');
Q = st_addQComponent(Q, 'Methane',          	'CH4', 			'mg/l');
Q = st_addQComponent(Q, 'Carbon_dioxide',   	'CO2', 			'mg/l');
Q = st_addQComponent(Q, 'Conductivity',     	'EGV', 			'mS/m');
Q = st_addQComponent(Q, 'Iron2',            	'Fe2', 			'mg/l');
Q = st_addQComponent(Q, 'Iron3',            	'Fe3', 			'mg/l');
Q = st_addQComponent(Q, 'Calcium',          	'Ca',  			'mg/l');
Q = st_addQComponent(Q, 'Magnesium',        	'Mg', 			'mg/l');
Q = st_addQComponent(Q, 'Calcium_carbonate',	'CaCO3', 		'mg/l');
Q = st_addQComponent(Q, 'Nitrogen',         	'N2',  			'mg/l');
Q = st_addQComponent(Q, 'Hydrogen_sulfide', 	'H2S', 			'mg/l');
Q = st_addQComponent(Q, 'Atrazine',         	'Atr', 			'mg/l');
Q = st_addQComponent(Q, 'Ammonia',          	'NH4',			'mg/l');
Q = st_addQComponent(Q, 'Nitrite',          	'NO2', 			'mg/l');
Q = st_addQComponent(Q, 'Nitrate',          	'NO3', 			'mg/l');
Q = st_addQComponent(Q, 'Phosphate',        	'PO4', 			'mg/l');
Q = st_addQComponent(Q, 'Bicarbonate',      	'HCO3', 		'mg/l');
Q = st_addQComponent(Q, 'pH',               	'pH',  			'pH');
Q = st_addQComponent(Q, 'Mnumber',          	'M', 			'mmol/l');
Q = st_addQComponent(Q, 'Pnumber',          	'P', 			'mmol/l');
Q = st_addQComponent(Q, 'Ionstrength',      	'IS',			'mmol/l');
Q = st_addQComponent(Q, 'UV254',            	'UV254', 		'1/m');
Q = st_addQComponent(Q, 'Bromide',          	'Br', 			'mg/l');
Q = st_addQComponent(Q, 'Sulphate',         	'SO4', 			'mg/l');
Q = st_addQComponent(Q, 'Viruses',         	'Vr', 			'-');
Q = st_addQComponent(Q, 'Giardia',          	'Gi', 			'-');
Q = st_addQComponent(Q, 'Cryptosporidium',  	'Cr', 			'-');
Q = st_addQComponent(Q, 'Trichlooretheen',  	'Cl3CH4', 		'mg/l');
Q = st_addQComponent(Q, 'Dichloorpropaan',  	'Cl2CH4', 		'mg/l');
Q = st_addQComponent(Q, 'Volatile_compound',	'VC', 			'mmol/l');
Q = st_addQComponent(Q, 'Acetic_acid', 		'AA',			'mg/l');
Q = st_addQComponent(Q, 'Initiele_UVA254',  	'iniUVA254',		'1/m');
Q = st_addQComponent(Q, 'Bromate',          	'BrO3',			'ug/l');
Q = st_addQComponent(Q, 'Ozone_dosed',      	'O3Dos',		'ug/l');
Q = st_addQComponent(Q, 'Ozone_dos_kUV',    	'O3Dos_kUV',		'ug/l');
Q = st_addQComponent(Q, 'Ecoli',            	'Ec',			'-');
Q = st_addQComponent(Q, 'AOC',              	'AOC',			'ug/l');
Q = st_addQComponent(Q, 'Residualchlorine', 	'clResidual',		'mg/L', 'Residual chlorine');
Q = st_addQComponent(Q, 'Totaltrihalomethanes', 'TTHMs',		'ug/L', 'Total Trihalomethanes');
Q = st_addQComponent(Q, 'Haloaceticacids', 	'HAAs', 		'ug/L', 'Halo acetic acids');

%toevoegen van gebruikers variabelen
Q = My_WaterQualityComponents(Q);
  