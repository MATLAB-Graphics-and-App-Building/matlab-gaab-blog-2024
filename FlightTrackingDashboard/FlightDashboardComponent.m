classdef FlightDashboardComponent < ...
        matlab.ui.componentcontainer.ComponentContainer
    %FLIGHTDASHBOARDCOMPONENT Superclass for flight dashboard view and
    %controller implementation.

    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) FlightDashboardModel {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )

    properties ( GetAccess = private, SetAccess = immutable )
        % Listener for the model event "FlightDataChanged".
        FlightDataChangedListener(:, 1) event.listener ...
            {mustBeScalarOrEmpty}
        % Listener for the model event "CurrentTimeChanged".
        CurrentTimeChangedListener(:, 1) event.listener ...
            {mustBeScalarOrEmpty}
    end % properties ( GetAccess = private, SetAccess = immutable )

    methods

        function obj = FlightDashboardComponent( model, namedArgs )
            %FLIGHTDASHBOARDCOMPONENT Construct the component, given the
            %model.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.Parent(:, 1) matlab.graphics.Graphics ...
                    {mustBeScalarOrEmpty} = []
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                "Parent", namedArgs.Parent, ...
                "Units", "normalized", ...
                "Position", [0, 0, 1, 1] )

            % Store the model.
            obj.Model = model;

            % Create the listeners.
            weakObj = matlab.lang.WeakReference( obj );
            obj.FlightDataChangedListener = listener( obj.Model, ...
                "FlightDataChanged", ...
                @( s, e ) weakObj.Handle.onFlightDataChanged( s, e ) );
            obj.CurrentTimeChangedListener = listener( obj.Model, ...
                "CurrentTimeChanged", ...
                @( s, e ) weakObj.Handle.onCurrentTimeChanged( s, e ) );

        end % constructor

    end % methods

    methods ( Abstract, Access = protected )

        onFlightDataChanged( obj, s, e )
        onCurrentTimeChanged( obj, s, e )

    end % methods ( Abstract, Access = protected )

end % classdef