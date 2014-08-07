function varargout = epaTable(action, varargin)

if ~nargin
%     action	= 'testImport';
    action	= 'testGet';
    
elseif isequal(action, 'fcnhandle')
    varargout{1}	= str2func(['epaTable_' varargin{1}]);
    return
end

if nargout
    varargout	= cell(1, nargout);
    [varargout{:}]= feval(['epaTable_' action], varargin{:});
else
    feval(['epaTable_' action], varargin{:});
end

% _________________________________________________________
% _sub0
    function epaTable_sub0
        
    end  % _sub0
end  % <main>


%__________________________________________________________
%% #getCTValue
%
function CTValue = epaTable_getCTValue(action, T, pH, varargin)

CTValue = [];

if exist(epaTable_matFlNm, 'file')
    CTdata = load(epaTable_matFlNm);
    try
        CTdata.giardia;
    catch 
        warning('No giardia data available.')
        return;
    end
    try
        CTdata.viruses;
    catch 
        warning('No viruses data available.')
        return;
    end
else
    warning('No CTdata found! Make sure the dat is imported before use.');
    return;
end

switch action
    case 'giardia'
        Cl = varargin{1};
        CTValue = epaTable_getCTValue_giardia(CTdata, T, pH, Cl);
    case 'viruses'
        CTValue = epaTable_getCTValue_viruses(CTdata, T, pH);
    otherwise
        error('Unknown type given. Available types are: giardia & viruses.')
end

% _________________________________________________________
% _getCTValue_giardia
    function CTValue = epaTable_getCTValue_giardia(CTdata, T, pH, Cl)
        CTValue = [];
        Trng = CTdata.giardia.Trng;
        pHrng = CTdata.giardia.pHrng;
        ClRng = CTdata.giardia.ClRng;
        
        Tind = epaTable_getCTValue_getInd(T, Trng, true);
        pHind = epaTable_getCTValue_getInd(pH, pHrng, false);
        ClInd = epaTable_getCTValue_getInd(Cl, ClRng, false);
        
        row = (Tind - 1)*length(ClRng) + ClInd;
        col = pHind;
        
        CTValue = CTdata.giardia.data(row, col);
    end  % _getCTValue_giardia
% _________________________________________________________
% _getCTValue_viruses
    function CTValue = epaTable_getCTValue_viruses(CTdata, T, pH)
        CTValue = [];
        Trng = CTdata.viruses.Trng;
        pHrng = CTdata.viruses.pHrng;
        
        Tind = epaTable_getCTValue_getInd(T, Trng, true);
        pHind = epaTable_getCTValue_getInd(pH, pHrng, false);
    
        row = Tind;
        col = pHind;
        
        CTValue = CTdata.viruses.data(row, col);        
    end  % _getCTValue_viruses
% _________________________________________________________
% _getCTValue_getInd
    function ind = epaTable_getCTValue_getInd(value, rng, isMin)
        difValues = abs(rng-value);
        minValue = min(difValues);
             
        indices = find(difValues == minValue);
        
        if length(indices) == 1
            ind = indices;
        else
            values = rng(indices);
            if isMin
                [dummy, i] = min(values);
            else
                [dummy, i] = max(values);
            end
            ind = indices(i);
        end        
    end  % _getCTValue_sub1
% _________________________________________________________
% _getCTValue_sub1
    function epaTable_getCTValue_sub1
        
    end  % _getCTValue_sub1
end  % #getCTValue

%__________________________________________________________
%% #import
%
function epaTable_import(action, xlsFlNm, parRng, dataRng)

if exist(epaTable_matFlNm, 'file')
    CTdata = load(epaTable_matFlNm);
else
    CTdata = struct;
end

[parNum,txt,raw] = xlsread(xlsFlNm, action, parRng);

[dataNum,txt,raw] = xlsread(xlsFlNm, action, dataRng);

switch action
    case 'giardia'
        CTdata = epaTable_import_giardia(CTdata, parNum, dataNum);
    case 'viruses'
        CTdata = epaTable_import_viruses(CTdata, parNum, dataNum);
    otherwise
        error('.')
end

save(epaTable_matFlNm, '-struct', 'CTdata');
% _________________________________________________________
% _import_giardia
    function CTdata = epaTable_import_giardia(CTdata, parNum, dataNum)
        CTdata.giardia = [];
        
        % Get the ranges from the data
        Trng    = parNum(1, 1:end);
        pHrng   = parNum(2, 1:end);
        ClRng   = parNum(3, 1:end);
        
        % Remove all NaN
        Trng(isnan(Trng)) = [];
        pHrng(isnan(pHrng)) = [];
        ClRng(isnan(ClRng)) = [];
        
        % Put the ranges in the structure
        CTdata.giardia.Trng = Trng;
        CTdata.giardia.pHrng = pHrng;
        CTdata.giardia.ClRng = ClRng;
        
        % Put the data in the structure
        CTdata.giardia.data = dataNum;
    end  % _import_giardia
% _________________________________________________________
% _import_viruses
    function CTdata = epaTable_import_viruses(CTdata, parNum, dataNum)
        CTdata.viruses = [];
        
        % Get the ranges from the data
        Trng    = parNum(1, 1:end);
        pHrng   = parNum(2, 1:end);
        
        % Remove all NaN
        Trng(isnan(Trng)) = [];
        pHrng(isnan(pHrng)) = [];
        
        % Put the ranges in the structure
        CTdata.viruses.Trng = Trng;
        CTdata.viruses.pHrng = pHrng;
   
        % Put the data in the structure
        CTdata.viruses.data = dataNum;
    end  % _import_viruses
% _________________________________________________________
% _import_sub1
    function epaTable_import_sub1
        
    end  % _import_sub1

end  % #import

%__________________________________________________________
%% #matFlNm
%
function matFlnNm = epaTable_matFlNm
matFlnNm = 'CTdata.mat';
end  % #matFlNm

%__________________________________________________________
%% #testGet
%
function epaTable_testGet

% Giardia
CTValues = [];

%Exact
CTValues{end+1,1} = epaTable_getCTValue('giardia', 15, 7, 1.4);
CTValues{end,2} = 78;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Between
CTValues{end+1,1} = epaTable_getCTValue('giardia', 12.5, 7.25, 0.9);
CTValues{end,2} = 134;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Lower
CTValues{end+1,1} = epaTable_getCTValue('giardia', 0, 4, 0.1);
CTValues{end,2} = 137;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Upper
CTValues{end+1,1} = epaTable_getCTValue('giardia', 30, 10, 5);
CTValues{end,2} = 97;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};

CTValues = CTValues';

fprintf('Value(get)\t Value(real)\t Match\n')
fprintf('%3u\t\t\t %3u\t\t\t %1u\n', CTValues{:})

% Viruses
CTValues = [];

%Exact
CTValues{end+1,1} = epaTable_getCTValue('viruses', 15, 7);
CTValues{end,2} = 4;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Between
CTValues{end+1,1} = epaTable_getCTValue('viruses', 12.5, 7.25);
CTValues{end,2} = 6;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Lower
CTValues{end+1,1} = epaTable_getCTValue('viruses', 0, 4);
CTValues{end,2} = 12;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};
%Upper
CTValues{end+1,1} = epaTable_getCTValue('viruses', 30, 11);
CTValues{end,2} = 15;
CTValues{end,3} = CTValues{end,2} == CTValues{end,1};

CTValues = CTValues';

fprintf('Value(get)\t Value(real)\t Match\n')
fprintf('%3u\t\t\t %3u\t\t\t %1u\n', CTValues{:})

end  % #testGet


%__________________________________________________________
%% #testImport
%
function epaTable_testImport

epaTable('import','giardia','C:\Users\M.Sparnaaij\Documents\TU\CT3000-09\epaInputTable.xlsx','A1:N3','A5:G88');
epaTable('import','viruses','C:\Users\M.Sparnaaij\Documents\TU\CT3000-09\epaInputTable.xlsx','A1:H2','A4:H9');

end  % #testImport


%__________________________________________________________
%% #qqq
%
function epaTable_qqq

end  % #qqq


%__________________________________________________________
%% #rrr
%
function out = epaTable_rrr(action, varargin)

out = [];

switch action
    case 'fcnhandle'
        out		= eval(['@epaTable_rrr_', varargin{1}]);
    case 'sss'
        % _rrr_sss
        
        % _rrr_sss END
    otherwise
        error('.')
end

% _________________________________________________________
% _rrr_sub1
    function epaTable_rrr_sub1
        
    end  % _rrr_sub1

end  % #rrr


