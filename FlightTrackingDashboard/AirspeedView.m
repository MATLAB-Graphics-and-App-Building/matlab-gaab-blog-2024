classdef AirspeedView < FlightInstrumentView
    %AIRSPEEDVIEW Provides a view of the current airspeed.

    properties ( GetAccess = {?matlab.unittest.TestCase, ...
            ?FlightInstrumentView}, SetAccess = protected )
       % Airspeed indicator.
       Instrument
    end % properties ( GetAccess = {?matlab.unittest.TestCase, ...
    % ?FlightInstrumentView}, SetAccess = protected )

    methods

        function obj = AirspeedView( model, namedArgs )
            %AIRSPEEDVIEW Construct an AirspeedView object, given the model
            %and optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?AirspeedView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightInstrumentView( model )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Refresh the view.
            obj.onCurrentTimeChanged()

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            setup@FlightInstrumentView( obj )
            obj.Instrument = uiaeroairspeed( obj.Grid, ...
                "Limits", [40, 580], ...
                "ScaleColorLimits", ...
                [0, 160; 100, 540; 540, 560; 560, 580 ] );

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

            panelTitle = "Airspeed: %.1f knots";
            obj.updateInstrument( "Airspeed", panelTitle )

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef