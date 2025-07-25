classdef GlobeView < FlightDashboardComponent
    %GLOBEVIEW Provide a view of the aircraft's position on the globe.

    properties ( Access = private )
        % Geographic globe.
        Globe(:, 1) globe.graphics.GeographicGlobe {mustBeScalarOrEmpty}
        % Flight route.
        Route(:, 1) map.graphics.primitive.Line {mustBeScalarOrEmpty}
        % Current point.
        Point(:, 1) map.graphics.primitive.Line {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = GlobeView( model, namedArgs )
            %GLOBEVIEW Construct a GlobeView, given the model and optional
            %name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?GlobeView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model, ...
                "Parent", namedArgs.Parent )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Refresh the component.
            obj.onFlightDataChanged()

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            % Create the globe.
            mainGrid = uigridlayout( obj, [1, 1], "Padding", 0 );
            mainPanel = uipanel( mainGrid, "BorderType", "none" );
            obj.Globe = geoglobe( mainPanel, "Basemap", "satellite" );

            % Add the flight route.
            obj.Route = geoplot3( obj.Globe, NaN, NaN, NaN, ...
                "-", "LineWidth", 3, "HeightReference", "terrain" );
            hold( obj.Globe, "on" )
            obj.Point = geoplot3( obj.Globe, NaN, NaN, NaN, "ro", ...
                "LineWidth", 2, "HeightReference", "terrain" );
            hold( obj.Globe, "off" )

        end % setup

        function update( ~ )
            %UPDATE Refresh the component's graphics.

        end % update

        function onFlightDataChanged( obj, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

            % Update the flight route.
            flightData = obj.Model.FlightData;
            if ~isempty( flightData.Time )
                set( obj.Route, "LatitudeData", flightData.Latitude, ...
                    "LongitudeData", flightData.Longitude, ...
                    "HeightData", flightData.Altitude )
                drawnow()
            else
                set( obj.Route, "LatitudeData", NaN, ...
                    "LongitudeData", NaN, ...
                    "HeightData", NaN )
                drawnow()
            end % if

            % Update the current point.
            obj.onCurrentTimeChanged()

        end % onFlightDataChanged

        function onCurrentTimeChanged( obj, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".

            % Update the current point marker and the camera properties.
            currentTime = obj.Model.CurrentTime;
            currentPoint = obj.Model.FlightData{ ...
                currentTime, ["Latitude", "Longitude", ...
                "Altitude", "Heading"]};

            if ~isempty( currentPoint )
                set( obj.Point, "LatitudeData", currentPoint(1), ...
                    "LongitudeData", currentPoint(2), ...
                    "HeightData", currentPoint(3) )
                drawnow()
                obj.Globe.campos( currentPoint(1), currentPoint(2), ...
                    currentPoint(3) + 1e4 )
                obj.Globe.camheading( currentPoint(4) )
            else
                set( obj.Point, "LatitudeData", NaN, ...
                    "LongitudeData", NaN, ...
                    "HeightData", NaN )
                drawnow()
                obj.Globe.campos( 0, 0, 1e7 )
                obj.Globe.camheading( 0 )
            end % if            

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef