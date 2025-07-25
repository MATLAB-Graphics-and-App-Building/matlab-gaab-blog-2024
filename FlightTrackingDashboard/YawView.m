classdef YawView < TextAreaView
    %YAWVIEW Provide a view of the yaw at the current time.

    methods

        function obj = YawView( model, namedArgs )
            %YAWVIEW Construct a YawView, given optional name-value
            %arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?YawView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@TextAreaView( model )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Refresh the view.
            obj.onFlightDataChanged()

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            setup@TextAreaView( obj )

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

        function onFlightDataChanged( obj, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

            obj.onCurrentTimeChanged()

        end % onFlightDataChanged

        function onCurrentTimeChanged( obj, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".

            obj.updateTextArea( "Yaw", "Yaw:\n %.2f" + char( 176 ) )

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef