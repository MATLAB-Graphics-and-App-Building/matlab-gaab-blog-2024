classdef FlightDashboardModel < handle
    %FLIGHTDASHBOARDMODEL Application data model for the flight dashboard.

    properties ( SetAccess = private )
        % Flight path data.
        FlightData(1, 1) FlightPathData = FlightPathData()
    end % properties ( SetAccess = private )

    properties ( Dependent )
        % The current time.
        CurrentTime(:, 1) datetime {mustBeScalarOrEmpty}
    end % properties ( Dependent )

    properties ( Access = private )
        % Internal storage for the CurrentTime property.
        CurrentTime_(:, 1) datetime {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    events ( NotifyAccess = private )
        % The flight data has been changed.
        FlightDataChanged
        % The current time has been changed.
        CurrentTimeChanged
    end % events ( NotifyAccess = private )

    methods

        function obj = FlightDashboardModel( filename )
            %FLIGHTDASHBOARDMODEL Create a model object, given the name of
            %a file containing flight data.

            arguments ( Input )
                filename(1, :) string {mustBeFile, ...
                    mustBeScalarOrEmpty} = string.empty( 1, 0 )
            end % arguments ( Input )

            if ~isempty( filename )
                obj.import( filename )
            end % if

        end % constructor

        function import( obj, filename )
            %IMPORT Import a new file containing flight data.

            arguments ( Input )
                obj(1, 1) FlightDashboardModel
                filename(1, :) string {mustBeFile, ...
                    mustBeScalarOrEmpty} = string.empty( 1, 0 )
            end % arguments ( Input )

            obj.FlightData = FlightPathData( filename );
            obj.CurrentTime = obj.FlightData.Time(1);
            obj.notify( "FlightDataChanged" )

        end % import

        function reset( obj )
            %RESET Clear flight data from the model.

            obj.FlightData = FlightPathData();
            obj.notify( "FlightDataChanged" )

        end % reset

        function value = get.CurrentTime( obj )

            value = obj.CurrentTime_;

        end % get.CurrentTime

        function set.CurrentTime( obj, value )

            if isempty( value )

                % Set the current time to empty.
                obj.CurrentTime_ = datetime.empty( 0, 1 );

            else

                % Check the time vector in the flight data.
                t = obj.FlightData.Time;

                if ~isempty( t )

                    % Clip the proposed time if necessary.
                    [mn, mx] = bounds( t );
                    value = min( max( mn, value ), mx );

                    % Find the nearest time point in the data and update
                    % the current time.
                    [~, minIdx] = min( abs( t - value ) );
                    obj.CurrentTime_ = t(minIdx);

                else

                    % Set the current time to empty.
                    obj.CurrentTime_ = datetime.empty( 0, 1 );

                end % if

            end % if

            % Notify the event.
            obj.notify( "CurrentTimeChanged" )

        end % set.CurrentTime

    end % methods

end % classdef