classdef ClimbRateView < FlightInstrumentView
    %CLIMBRATEVIEW Provides a view of the current climb rate.

    properties ( GetAccess = {?matlab.unittest.TestCase, ...
            ?FlightInstrumentView}, SetAccess = protected )
       % Airspeed indicator.
       Instrument
    end % properties ( GetAccess = {?matlab.unittest.TestCase, ...
    % ?FlightInstrumentView}, SetAccess = protected )

    methods

        function obj = ClimbRateView( model, namedArgs )
            %CLIMBRATEVIEW Construct a ClimbRateView object, given the 
            %model and optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?ClimbRateView
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
            obj.Instrument = uiaeroclimb( obj.Grid );

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

            panelTitle = "Climb Rate: %.0f ft/min";
            obj.updateInstrument( "Climb Rate", panelTitle )

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef