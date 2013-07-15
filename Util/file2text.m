function strs = file2text(filename, columns)
%FILE2TEXT Read and format a text file for display.
%
%   TEXT = FILE2TEXT(FILENAME, COLUMNS)
%
%   Inputs:
%       filename - the text file to read
%       columns  - the column size in characters
%
%   Outputs:
%       strs - the formatted text strings
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Initialize the format strings and their replacements.
formatStrs = {
    '\rm'  % neutral
    '\t1'  % title 1
    '\t2'  % title 2
    '\t3'  % title 3
    '\w'   % WWW link
    '\biu' % bold, italic, and underlined
    '\bi'  % bold and italic
    '\bu'  % bold and underlined
    '\iu'  % italic and underlined
    '\b'   % bold
    '\i'   % italic
    '\u'   % underlined
    '\f1'  % 8-point font
    '\f2'  % 10-point font
    '\f3'  % 12-point font
    '\f4'  % 16-point font
    '\f5'  % 20-point font
    '\f6'  % 24-point font
    '\f7'  % 32-point font
    '\f8'  % 48-point font
    '\f9'  % 64-point font
    };
formatReps = {
    };

% Read in the file.
numStrs = 0;
strs = [];
file = fopen(filename);
text = textscan(file, '%s');

% Wrap the text.
spacesI = strfind(text, ' ');
textOff = 1;
for i = 2:length(spacesI)
    
    % Should we wrap the line?
    if spacesI(i) - textOff > columns
        
        % The text is too long, interrupt it.
        if spacesI(i - 1) - textOff > columns
            wrapI = textOff + columns - 1;
            
        % Wrap at the previous space.
        else
            wrapI = spacesI(i - 1);
        end
        
        % Add the string.
        numStrs = numStrs + 1;
        strs{numStrs} = text(textOff:wrapI);
        textOff = wrapI + 1;
    end
end

% Wrap the remaining text.
while textOff <= length(text)
    
    % Wrap the line.
    wrapI = textOff + min(columns - 1, length(text) - textOff);
    
    % Add the string.
    numStrs = numStrs + 1;
    strs{numStrs} = text(textOff:wrapI);
    textOff = wrapI + 1;
end

% Format the text strings.
for i = 1:length(strs)
    for j = 1:length(formatStrs)
        strs{i} = strrep(strs{i}, formatStrs{j}, formatReps(j));
    end
end
end
