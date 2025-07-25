classdef HorizonView < FlightInstrumentView
    %HORIZONVIEW Provides a view of the current climb rate.

    properties ( GetAccess = {?matlab.unittest.TestCase, ...
            ?FlightInstrumentView}, SetAccess = protected )
        % Airspeed indicator.
        Instrument
    end % properties ( GetAccess = {?matlab.unittest.TestCase, ...
    % ?FlightInstrumentView}, SetAccess = protected )

    methods

        function obj = HorizonView( model, namedArgs )
            %HORIZONVIEW Construct a HorizonView object, given the
            %model and optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?HorizonView
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
            obj.Instrument = uiaerohorizon( obj.Grid );

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

            panelTitle = "Pitch: %.1f" + char( 176 ) + ...
                " | Roll: %.1f" + char( 176 );
            obj.updateInstrument( ["Pitch", "Roll"], panelTitle )

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef