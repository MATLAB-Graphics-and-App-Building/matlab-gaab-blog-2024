classdef MapView < FlightDashboardComponent
    %MAPVIEW Show the aircraft's position on a map.

    properties ( Access = private )
        % Position chart.
        Chart(:, 1) PositionChart {mustBeScalarOrEmpty}
        % Basemap dropdown menu.
        BasemapDropdown(:, 1) matlab.ui.control.DropDown ...
            {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    properties ( Constant )
        % Basemap list.
        Basemaps = ["streets-light", "streets-dark", ...
            "streets", "satellite", "topographic", ...
            "landcover", "colorterrain", "grayterrain", ...
            "bluegreen", "grayland", "darkwater", "none"]
    end % properties ( Constant )

    methods

        function obj = MapView( model, namedArgs )
            %MAPVIEW Construct a MapView object, given the model and
            %optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?MapView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Refresh the view.
            obj.onFlightDataChanged()

        end % constructor

        function geobasemap( obj, basemap )

            arguments ( Input )
                obj(1, 1) MapView
                basemap(1, 1) string {mustBeBasemap}
            end % arguments ( Input )

            obj.BasemapDropdown.Value = basemap;
            obj.Chart.geobasemap( basemap )

        end % geobasemap

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            mainGrid = uigridlayout( obj, [2, 2], ...
                "RowHeight", ["fit", "1x"], ...
                "ColumnWidth", ["1x", "fit"] );
            uilabel( "Parent", mainGrid, ...
                "Text", "Basemap", ...
                "HorizontalAlignment", "right", ...
                "FontName", FlightDashboardTheme.FontName, ...
                "FontSize", FlightDashboardTheme.LabelFontSize );
            initialBasemap = "streets-dark";
            obj.BasemapDropdown = uidropdown( "Parent", mainGrid, ...
                "Items", MapView.Basemaps, ...
                "Tooltip", "Select the geographic basemap", ...
                "Value", initialBasemap, ...
                "FontName", FlightDashboardTheme.FontName, ...
                "FontSize", FlightDashboardTheme.LabelFontSize, ...
                "ValueChangedFcn", ...
                @( s, ~ ) geobasemap( obj.Chart, s.Value ) );
            obj.Chart = PositionChart( "Parent", mainGrid, ...
                "FontName", FlightDashboardTheme.FontName );
            obj.Chart.geobasemap( initialBasemap )
            obj.Chart.Layout.Column = [1, 2];
            title( obj.Chart, "Flight Route", ...
                "FontSize", FlightDashboardTheme.TitleFontSize, ...
                "FontName", FlightDashboardTheme.FontName )

        end % setup

        function update( obj )
            %UPDATE Refresh the component's graphics.

            % Respond to theme changes by switching the geographic basemap
            % in use.
            f = ancestor( obj, "figure" );
            if isempty( f )
                return
            else
                themeName = f.Theme.Name;
                if themeName == "Light Theme"
                    obj.geobasemap( "streets-light" )
                else
                    obj.geobasemap( "streets-dark" )
                end % if
            end % if

        end % update

        function onFlightDataChanged( obj, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

            flightData = obj.Model.FlightData;
            latLon = [flightData.Latitude, flightData.Longitude];
            obj.Chart.FlightRoute = latLon;
            obj.onCurrentTimeChanged()

        end % onFlightDataChanged

        function onCurrentTimeChanged( obj, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".

            t = obj.Model.CurrentTime;
            latLon = obj.Model.FlightData{t, ["Latitude", "Longitude"]};
            obj.Chart.CurrentPoint = latLon;

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef

function mustBeBasemap( str )
%MUSTBEBASEMAP Validate that the input, str, represents a valid basemap.

mustBeMember( str, MapView.Basemaps )

end % mustBeBasemap