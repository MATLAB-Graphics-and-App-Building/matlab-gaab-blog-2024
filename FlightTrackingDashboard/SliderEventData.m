classdef SliderEventData < event.EventData
    %SLIDEREVENTDATA Slider event data.

    properties ( SetAccess = immutable )
        % Slider value.
        Value
    end % properties ( SetAccess = immutable )

    methods

        function obj = SliderEventData( value )
            %SLIDEREVENTDATA Construct a slider event data object, given 
            %the slider value.

            arguments ( Input )
                value(1, 1) double {mustBeReal, mustBeFinite, ...
                    mustBeNonnegative}
            end % arguments ( Input )

            obj.Value = value;
            
        end % constructor

    end % methods

end % classdef