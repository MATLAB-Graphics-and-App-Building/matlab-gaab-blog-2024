classdef TimeController < FlightDashboardComponent
    %TIMECONTROLLER Provide controls for changing the current time.

    properties ( Access = private )
        % Playback controls.
        Controls(:, 1) PlaybackControls {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = TimeController( model, namedArgs )
            %TIMECONTROLLER Construct a TimeController, given the model and
            %optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?TimeController
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Refresh the component.
            obj.onCurrentTimeChanged()

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            obj.Controls = PlaybackControls( "Parent", obj, ...                
                "CurrentTimeSelectedFcn", @obj.onCurrentTimeSelected, ...
                "TimerTickedFcn", @obj.onTimerTicked, ...
                "PlaybackStoppedFcn", @obj.onPlaybackStopped );

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.


        end % update

        function onCurrentTimeChanged( obj, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".            

            % Retrieve the current time.
            currentTime = obj.Model.CurrentTime;

            % Evaluate the last known time.
            lastKnownTime = seconds( currentTime - ...
                min( obj.Model.FlightData.Time ) );
            if isempty( lastKnownTime )
                lastKnownTime = NaN;
            end % if

            obj.Controls.selectTime( lastKnownTime )              

        end % onCurrentTimeChanged

        function onFlightDataChanged( obj, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

            modelHasData = ~isempty( obj.Model.FlightData.Time );

            if modelHasData
                time = obj.Model.FlightData.Time;
                [mn, mx] = bounds( time );
                timeLimits = seconds( [0, mx - mn] );
                lastKnownTime = seconds( obj.Model.CurrentTime - mn );
                if isempty( lastKnownTime )
                    lastKnownTime = NaN;
                end % if
            else
                timeLimits = [0, 1];
                lastKnownTime = 0;
            end % if

            obj.Controls.selectTimeLimits( ...
                modelHasData, timeLimits, lastKnownTime )               

        end % onFlightDataChanged

    end % methods ( Access = protected )

    methods ( Access = private )        

        function onTimerTicked( obj, ~, e )
            %ONTIMERTICKED Respond to the event "TimerTicked".

            % Compute the start and finish times.
            [minTime, maxTime] = bounds( obj.Model.FlightData.Time );
            if isempty( minTime ), return, end

            oldTime = minTime + seconds( e.LastKnownTime );
            newTime = oldTime + seconds( e.Offset );

            % Update the model's CurrentTime property.            
            if newTime >= maxTime                
                obj.Model.CurrentTime = maxTime;
            else
                obj.Model.CurrentTime = newTime;
            end % if

        end % onTimerTicked

        function onCurrentTimeSelected( obj, ~, e )
            %ONCURRENTTIMESELECTED Respond to the event
            %"CurrentTimeSelected".

            % Set the model's CurrentTime property.
            mn = min( obj.Model.FlightData.Time );
            if isempty( mn ), return, end
            obj.Model.CurrentTime = mn + seconds( e.Value );

        end % onCurrentTimeSelected

        function onPlaybackStopped( obj, ~, ~ )
            %ONPLAYBACKSTOPPED Respond to the event "PlaybackStopped".

           mn = min( obj.Model.FlightData.Time );
           if isempty( mn ), return, end
           obj.Model.CurrentTime = mn;

        end % onPlaybackStopped

    end % methods ( Access = private )

end % classdef