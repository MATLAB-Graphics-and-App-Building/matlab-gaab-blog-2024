classdef TimerEventData < event.EventData
    %TIMEREVENTDATA Timer event data.

    properties ( SetAccess = immutable )
        % Last known time.
        LastKnownTime
        % Offset.
        Offset
    end % properties ( SetAccess = immutable )

    methods

        function obj = TimerEventData( lastKnownTime, offset )
            %TIMEREVENTDATA Construct a timer event data object, given the
            %last known time and offset.

            arguments ( Input )
                lastKnownTime(1, 1) double {mustBeReal, mustBeFinite, ...
                    mustBeNonnegative}
                offset(1, 1) double {mustBeReal, ...
                    mustBeFinite, mustBeNonnegative}
            end % arguments ( Input )

            obj.LastKnownTime = lastKnownTime;
            obj.Offset = offset;

        end % constructor

    end % methods

end % classdef