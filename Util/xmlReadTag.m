function values = xmlReadTag(xml, tag)
%XMLREADTAG Read a tag from an XML document.
%
%   VALUES = XMLREADTAG(XML, TAG)
%
%   Inputs:
%       xml - the xml document
%       tag - the period-delimited path for the tag
%
%   Output:
%       values - the values for the given tag
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Translate the tag to a path.
path = [];
i = 1;
while ~isempty(tag)
    [name tag] = strtok(tag, '.');
    if ~isempty(name)
        path{i} = name;
        i = i + 1;
    end
end

% Get the values associated with the tag.
values = char(getElement(xml, path, 1));
end

% Get the values associated with a path.
function values = getElement(element, path, i)

% We've reached the requested node.
values = [];
if i == length(path) + 1
    
    % Search for text (value) nodes.
    k = 1;
    nodes = element.getChildNodes;
    for j = 0:(nodes.getLength - 1)
        if nodes.item(j).getNodeType == element.TEXT_NODE
            value = strtrim(char(nodes.item(j).getNodeValue));
            
            % Add the value to the list.
            if ~isempty(value)
                values{k} = value;
                k = k + 1;
            end
        end
    end

% Search for the next node in the path.
else
    nodes = element.getElementsByTagName(path{i});
    for j = 0:(nodes.getLength - 1)
        
        % Follow the node.
        if nodes.item(j).hasChildNodes
            values = cat(2, values, getElement(nodes.item(j), path, i + 1));
        end
    end
end
end
