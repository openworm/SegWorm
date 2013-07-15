function [box state] = event2box(state, prevEvent, event, nextEvent)
%EVENT2BOX Convert an event to a box (for plotting with PLOTEVENT).
%
%   [BOX STATE] = EVENT2BOX(STATE, PREVEVENT, EVENT, NEXTEVENT)
%
%   Inputs:
%       state     - the function state (persists across function calls);
%                   a struct with the fields:
%
%                   fieldName      = the name of the event field to use
%                   height         = the event height; if empty, the box is
%                                    as high as the event's field value
%                   width          = the event width; if empty, the box is
%                                    as wide as the event frames
%                                    Note: when plotting disproportionate
%                                    events it is best to use a width of 0.
%                   isInterEvent   = does the box correspond to an inter
%                                    event (i.e. the time between the
%                                    current event and the next event)?
%                   evalFieldNames = the names of the fields to evaluate;
%                                    if any of the functions returns false
%                                    when evaluating a field, the box is
%                                    returned full of NaNs and, therefore,
%                                    not shown; if empty, none of the
%                                    fields are evaluated
%                   evalFieldFuncs = the functions for evaluating the
%                                    evalFieldNames; the functions must be
%                                    of the form:
%
%                                    LOGICAL = EVALFIELDFUNC(FIELDVALUE)
%
%       prevEvent - the previous event, if one exists
%       event     - the current event
%       nextEvent - the next event, if one exists
%
%   Outputs:
%       box   - a box represent the event (xy coordinates x vertices)
%       state - the function state (persists across function calls)
%
% See also PLOTEVENT
%
%
% © Medical Research Council 2012
% You will not remove any copyright or other notices from the Software; 
% you must reproduce all copyright notices and other proprietary 
% notices on any copies of the Software.

% Initialize the variables.
box = nan(2,4);

% Evaluate the event field(s).
evalFieldNames = state.evalFieldNames;
if ~isempty(state.evalFieldNames)
    
    % Evaluate the event field.
    evalFieldFuncs = state.evalFieldFuncs;
    if ~iscell(evalFieldNames)
        if ~evalFieldFuncs(event.(evalFieldNames))
            return;
        end
        
    % Evaluate the event fields.
    else
        for i = 1:length(evalFieldNames)
            func = evalFieldFuncs{i};
            if ~func(event.(evalFieldNames{i}))
                return;
            end
        end
    end
end
    
% Compute the inter-event box.
if state.isInterEvent
    if ~isempty(nextEvent) && nextEvent.start > event.end + 1
        
        % Draw an event-height box.
        if isempty(state.height)
            eventY = event.(state.fieldName);
            
        % Draw the specified box height.
        else
            eventY = state.height;
        end
        
        % Draw an event-wide box.
        if isempty(state.width)
            eventX = [event.end + 1, nextEvent.start - 1];
            
        % Draw the specified box width.
        else
            eventX = [event.end + 1, event.end + 1 + state.width];
        end
        
        % Draw the box.
        box(1,:) = [eventX, fliplr(eventX)];
        box(2,:) = [0, 0, eventY, eventY];
    end
    
% Compute the event box.
else
    
    % Draw an event-height box.
    if isempty(state.height)
        eventY = event.(state.fieldName);
        
        % Draw the specified box height.
    else
        eventY = state.height;
    end
    
    % Draw an event-wide box.
    if isempty(state.width)
        eventX = [event.start, event.end];
        
        % Draw the specified box width.
    else
        eventX = [event.start, event.start + state.width];
    end
    
    % Draw the box.
    box(1,:) = [eventX, fliplr(eventX)];
    box(2,:) = [0, 0, eventY, eventY];
end
end
