function Data = loadData(FileName, ColNumb)
% Stimela function for loading extra data from text file

Extension = lower(FileName(length(FileName)-2 : length(FileName)));

if Extension == 'mat'
%	Load data from Mat-file
  
  try
    load(FileName);
   	if exist('Matrix')
      Data = Matrix(:,ColNumb(2:length(ColNumb)));
   	else
      h = errordlg('Matrix with measurement data in *.mat-file must have name "Matrix"', 'Stimela', 'on');
      dlgOnTop(h);
      Data = [];
   	end
  catch
    h = errordlg(['Can not load file: ' FileName], 'Stimela', 'on');
    dlgOnTop(h);
    Data = [];
  end
  
else
%	Load measurements from ASCII-file
  fid = fopen(FileName,'r');		% open as read-only
	if fid < 0
    h = errordlg(['Can not open file: ' FileName], 'Stimela', 'on');
    dlgOnTop(h);
    Data = [];
    
  else
    Data = [];					% matrix with data read from file
    LineNumb = 0;				% number of line in file (usefull for error messages)
    Data_row = 0;				% row in which the read data is stored
    
    while (~feof(fid))
      %	Read next line from file
      LineNumb = LineNumb + 1;
      Line = fgetl(fid);
      
      % Skip empty lines and lines with comments
      dbline = deblank(Line);
      if (length(dbline) > 0)
      if (dbline(1) ~= '%')
        Data_row = Data_row + 1;
        %	Indices of non-blank characters
        indChar = find(Line ~= ' ');
        %	Find beginnings of words
        indBeginOfWord = [indChar(1)];
        for cntChar = 2 : length(indChar)
          if (indChar(cntChar) - indChar(cntChar-1)) > 1
            indBeginOfWord = [indBeginOfWord indChar(cntChar)];
          end
        end
        
        % Find endings of words
        indEndOfWord = [indChar(length(indChar))];
        for cntChar = (length(indChar) - 1) : -1 : 1
          if (indChar(cntChar + 1) - indChar(cntChar)) > 1
            indEndOfWord = [indChar(cntChar) indEndOfWord ];
          end
        end
        
        NumberOfWords = length(indBeginOfWord);
        if NumberOfWords >= max(ColNumb)
        % There are enough words (=columns) on the line
          %	Read words that are in the columns with the desired information
          for cntCol = 1 : length(ColNumb)
            Word = '';
            
            %	Read word
            for cntChar = indBeginOfWord(ColNumb(cntCol)) : indEndOfWord(ColNumb(cntCol))
              if Line(cntChar) == ','
              	%	Convert comma's to points
                Word = [Word '.'];
              else
                %	Append character to word
                Word = [Word Line(cntChar)];
              end
            end
            
            %	Check word
            if length(find(Word == '.')) > 1
              % More than one point in word (which should be a string-number)
              Word = '';
              h = warndlg(['More than one decimal separator ("." and/or ",") in  column ' num2str(cntCol)...
                  ' on line ' num2str(LineNumb) ' in file ' FileName], 'Stimela', 'on');
			        dlgOnTop(h);
            end
            
            % Convert word to number (non-numeric characters or '' give: [])
            Number = str2num(Word);
            % Store number in Data matrix
            if isempty(Number)
              Data(Data_row, cntCol) = -inf;
              h = warndlg(['Wrong number format on line ' num2str(LineNumb) ' in file ' FileName...
                  '. Data on this line has been ignored'], 'Stimela', 'on');
			        dlgOnTop(h);
            else
              Data(Data_row, cntCol) = Number;
            end
          end		% next cntCol
        end		% if NumberOfWords >= max(ColNumb)
      end		% next line
    end
    end		% while (~feof(fid))
    
    if isempty(Data)
    %	Everything went wrong
    else
    	%	Find rows with all valid numbers (no '-inf')
    	[rowD, colD] = size(Data);
	    indRowOK = [];		% indices of rows with all valid numbers
  	  for cntrow = 1 : rowD
    	  if ~any(Data(cntrow, :) == -inf)
      	  indRowOK = [indRowOK cntrow];
	      end
  	  end
    	
	    % Heal the matrix with data
      Data = Data(indRowOK, :);
      
    end		% if isempty(Data)
    
  end		% if fid < 0
end		% if Extension == 'mat'
