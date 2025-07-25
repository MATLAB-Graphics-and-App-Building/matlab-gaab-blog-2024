classdef PositionChart < matlab.graphics.chartcontainer.ChartContainer
    %POSITIONCHART Show the aircraft's position on a map.

    properties
        FontName(1, 1) string = "Verdana"
    end % properties

    properties
        % Flight path route (latitude, longitude).
        FlightRoute(:, 2) double {mustBeReal} = NaN( 0, 2 )
        % Current point (latitude, longitude).
        CurrentPoint(:, 2) double {mustBeReal, mustHaveZeroOrOneRows} = ...
            NaN( 1, 2 )
    end % properties
    
    properties ( Access = private )
        % Geographic axes.
        GeoAxes(:, 1) matlab.graphics.axis.GeographicAxes ...
            {mustBeScalarOrEmpty}
        % Geographic plot for the flight route.
        FlightRouteLine(:, 1) matlab.graphics.chart.primitive.Line ...
            {mustBeScalarOrEmpty}
        % Geographic plots for the flight marker.
        CurrentPointLine(:, 1) matlab.graphics.chart.primitive.Line
    end % properties ( Access = private )

    methods

        function obj = PositionChart( namedArgs )
            %POSITIONCHART Construct a PositionChart, given optional
            %name-value arguments.

            arguments ( Input )
                namedArgs.?PositionChart
            end % arguments ( Input )

            % Call the superclass constructor.
            f = figure( "Visible", "off" );
            figureCleanup = onCleanup( @() delete( f ) );
            obj@matlab.graphics.chartcontainer.ChartContainer( ...
                "Parent", f )
            obj.Parent = [];

            % Set any user-defined properties.
            set( obj, namedArgs )

        end % constructor

        function varargout = geolimits( obj, varargin )

            [varargout{1:nargout}] = ...
                geolimits( obj.GeoAxes, varargin{:} );

        end % geolimits

        function varargout = geobasemap( obj, varargin )

            [varargout{1:nargout}] = ...
                geobasemap( obj.GeoAxes, varargin{:} );
            
        end % geobasemap

        function varargout = title( obj, varargin )

            [varargout{1:nargout}] = title( obj.GeoAxes, varargin{:} );

        end % title

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the chart's graphics.

            % Create the geoaxes.
            obj.GeoAxes = geoaxes( "Parent", obj.getLayout(), ...
                "Basemap", "streets" );
            hold( obj.GeoAxes, "on" )
            obj.FlightRouteLine = geoplot( NaN, NaN, ...
                "LineWidth", 3, ...
                "Parent", obj.GeoAxes );
            obj.CurrentPointLine(1) = geoplot( NaN, NaN, "ro", ...
                "MarkerFaceColor", "r", ...
                "MarkerSize", 8, ...
                "Parent", obj.GeoAxes );
            obj.CurrentPointLine(2) = geoplot( NaN, NaN, "ro", ...
                "LineWidth", 2, ...
                "MarkerSize", 20, ...
                "Parent", obj.GeoAxes );
            obj.CurrentPointLine(3) = geoplot( NaN, NaN, "r+", ...
                "LineWidth", 2, ...
                "MarkerSize", 20, ...
                "Parent", obj.GeoAxes );
            title( obj.GeoAxes, "Aircraft Location" )

        end % setup

        function update( obj )
            %UPDATE Refresh the chart's graphics.

            % Update the flight marker and path.
            if ~isempty( obj.CurrentPoint )
                set( obj.CurrentPointLine, ...
                    "LatitudeData", obj.CurrentPoint(1), ...
                    "LongitudeData", obj.CurrentPoint(2) )
            else
                set( obj.CurrentPointLine, ...
                    "LatitudeData", NaN, ...
                    "LongitudeData", NaN )
            end % if

            if ~isempty( obj.FlightRoute )
                set( obj.FlightRouteLine, ...
                    "LatitudeData", obj.FlightRoute(:, 1), ...
                    "LongitudeData", obj.FlightRoute(:, 2) )
            else
                set( obj.FlightRouteLine, ...
                    "LatitudeData", NaN, ...
                    "LongitudeData", NaN )
            end % if

            obj.GeoAxes.FontName = obj.FontName;

        end % update

    end % methods ( Access = protected )

end % classdef

function mustHaveZeroOrOneRows( x )
%MUSTHAVEZEROORONEROWS Validate that the input, x, has zero or one rows.

h = height( x );
mustBeInRange( h, 0, 1, "inclusive" )

end % mustHaveZeroOrOneRows