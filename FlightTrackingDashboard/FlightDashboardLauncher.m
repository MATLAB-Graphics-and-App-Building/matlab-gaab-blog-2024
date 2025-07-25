classdef FlightDashboardLauncher < handle
    %FLIGHTDASHBOARDLAUNCHER Launcher for the flight dashboard application.

    properties ( SetAccess = private )
        % Application figure window.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
    end % properties ( SetAccess = private )

    properties ( Access = private )
        % Main horizontal layout.
        MainHBox(:, 1) uix.HBoxFlex {mustBeScalarOrEmpty}
        % Left-hand side vertical layout.
        LeftVBox(:, 1) uix.VBoxFlex {mustBeScalarOrEmpty}
        % Right-hand side vertical layout.
        RightVBox(:, 1) uix.VBoxFlex {mustBeScalarOrEmpty}
        % Vertical boxes for the flight instruments.
        InstrumentGrid(:, 1) uix.Grid
        % Map view.
        MapView(:, 1) MapView {mustBeScalarOrEmpty}
        % Layout toggle buttons.
        LayoutToggleButtons(:, 1) matlab.ui.container.toolbar.ToggleTool
    end % properties ( Access = private )

    properties ( Access = private )
        % Application data model.
        Model(:, 1) FlightDashboardModel {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = FlightDashboardLauncher( f )
            %FLIGHTDASHBOARDLAUNCHER Launch the application.

            arguments ( Input )
                f(1, 1) matlab.ui.Figure = ...
                    uifigure( "Name", "Flight Dashboard", ...
                    "AutoResizeChildren", "off" )
            end % arguments ( Input )

            % Store the figure.
            obj.Figure = f;

            % Check for the required dependencies.
            v = ver( "layout" );
            if isempty( v )
                uialert( obj.Figure, "This application requires " + ...
                    "<a href=""https://www.mathworks.com/" + ...
                    "matlabcentral/fileexchange/" + ...
                    "47982-gui-layout-toolbox"">" + ...
                    "GUI Layout Toolbox</a>. Please install this" + ...
                    " toolbox and restart the application.", ...
                    "Flight Dashboard: Missing Dependency", ...
                    "Interpreter", "html", ...
                    "CloseFcn", @( ~, ~ ) delete( obj.Figure ) )
                return
            end % if

            % Add figure-level controls.
            tb = uitoolbar( obj.Figure );
            iconPath = fullfile( dashboardRoot(), "Images", "Import.png" );
            uipushtool( tb, "Tooltip", "Import flight data...", ...
                "Icon", iconPath, ...
                "ClickedCallback", @obj.onImportButtonPushed )
            iconPath = fullfile( dashboardRoot(), "Images", "Clear.png" );
            uipushtool( tb, "Tooltip", "Clear flight data", ...
                "Icon", iconPath, ...
                "ClickedCallback", @obj.onClearButtonPushed )
            iconPath = fullfile( dashboardRoot(), ...
                "Images", "Invert.png" );
            uipushtool( tb, "Tooltip", "Invert theme", ...
                "Icon", iconPath, ...
                "ClickedCallback", @obj.onThemeButtonPushed )
            iconPath = fullfile( dashboardRoot(), "Images", "Gauge.png" );
            obj.LayoutToggleButtons(1) = uitoggletool( tb, ...
                "Tooltip", instrumentTooltip(), ...
                "State", "off", ...
                "Icon", iconPath, ...
                "ClickedCallback", @obj.onFlightInstrumentsToggled );
            iconPath = fullfile( dashboardRoot(), "Images", "Globe.png" );
            obj.LayoutToggleButtons(2) = uitoggletool( tb, ...
                "Tooltip", globeTooltip(), ...
                "State", "off", ...
                "Icon", iconPath, ...
                "ClickedCallback", @obj.onGlobeToggled );

            % Create the model.
            obj.Model = FlightDashboardModel();

            % Create the main layout.
            mainVBox = uix.VBox( "Parent", obj.Figure, ...
                "Spacing", 5 );
            obj.MainHBox = uix.HBoxFlex( "Parent", mainVBox, ...
                "Spacing", 5 );

            % Define the left-hand vertical layout.
            obj.LeftVBox = uix.VBoxFlex( "Parent", obj.MainHBox );

            % Add the attitude view.
            AircraftAttitudeView( obj.Model, "Parent", obj.LeftVBox );

            % Insert a grid for the flight instruments.
            obj.InstrumentGrid = uix.Grid( "Parent", obj.LeftVBox, ...
                "Padding", 5, ...
                "Spacing", 5 );
            obj.LeftVBox.Heights = [-3, -2];
            minimizeCallback = @( rowNum ) ...
                @( s, e ) onInstrumentMinimized( obj, s, e, rowNum );
            AirspeedView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 1 ) );
            TurnView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 2 ) );
            HorizonView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 1 ) );
            HeadingView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 2 ) );
            AltitudeView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 1 ) );
            ClimbRateView( obj.Model, "Parent", obj.InstrumentGrid, ...
                "MinimizeFcn", minimizeCallback( 2 ) );
            obj.InstrumentGrid.Heights = [-1, -1];

            % Add the time controls.
            controlLayout = uix.HBox( "Parent", mainVBox );
            uix.Empty( "Parent", controlLayout );
            TimeController( obj.Model, "Parent", controlLayout );
            uix.Empty( "Parent", controlLayout );
            controlLayout.Widths = [-1, -2, -1];
            mainVBox.Heights = [-1, 40];

            % Add the map and globe views.
            obj.RightVBox = uix.VBoxFlex( "Parent", obj.MainHBox );
            GlobeView( obj.Model, "Parent", obj.RightVBox );
            lowerHBox = uix.HBoxFlex( "Parent", obj.RightVBox );
            obj.MapView = MapView( obj.Model, "Parent", lowerHBox );
            TextAreaViewDisplay( obj.Model, "Parent", lowerHBox );
            obj.RightVBox.Heights = [-2, -1];
            lowerHBox.Widths = [-3, -2];

        end % constructor

    end % methods

    methods ( Access = private )

        function onImportButtonPushed( obj, ~, ~ )
            %ONIMPORTBUTTONPUSHED Import new flight path data.

            % Prompt the user to select a file.
            [file, path] = uigetfile( "*.csv", ...
                "Select a file containing flight path data" );
            filepath = fullfile( path, file );
            figure( obj.Figure )

            % Attempt to import the new data.
            try
                obj.Model.import( filepath )
            catch e
                uialert( obj.Figure, e.message, ...
                    "Flight Dashboard: Import Error" )
            end % try/catch

        end % onImportButtonPushed

        function onClearButtonPushed( obj, ~, ~ )
            %ONCLEARBUTTONPUSHED Clear flight path data.

            % Confirm that the user wants to clear the flight data.
            response = uiconfirm( obj.Figure, ...
                "Are you sure you want to clear all flight data?", ...
                "Flight Dashboard: Clear Flight Data", ...
                "Icon", "question", ...
                "Options", ["Clear data", "Cancel"], ...
                "DefaultOption", "Cancel" );

            % Clear the data.
            if response == "Clear data"
                obj.Model.reset()
            end % if

        end % onClearButtonPushed

        function onThemeButtonPushed( obj, ~, ~ )
            %ONTHEMEBUTTONPUSHED Toggle the theme.

            if obj.Figure.Theme.Name == "Light Theme"
                obj.Figure.Theme = "dark";                
            else
                obj.Figure.Theme = "light";                
            end % if

        end % onThemeButtonPushed

        function onFlightInstrumentsToggled( obj, s, ~ )
            %ONFLIGHTINSTRUMENTSTOGGLED Expand or contract the flight
            %instruments and attitude view.

            expanded = s.State == "on";
            if expanded
                s.Tooltip = "Restore the default layout";
                obj.MainHBox.Widths = [-1, 0];
                obj.RightVBox.Visible = "off";
                obj.LayoutToggleButtons(2).Enable = "off";
            else
                s.Tooltip = instrumentTooltip();
                obj.MainHBox.Widths = [-1, -1];
                obj.RightVBox.Visible = "on";
                obj.LayoutToggleButtons(2).Enable = "on";
            end % if

        end % onFlightInstrumentsToggled

        function onGlobeToggled( obj, s, ~ )
            %ONGLOBETOGGLED Expand or contract the globe view.

            expanded = s.State == "on";
            if expanded
                s.Tooltip = "Restore the default layout";
                obj.MainHBox.Widths = [0, -1];
                obj.RightVBox.Heights = [-1, 0];
                obj.LeftVBox.Visible = "off";
                obj.LayoutToggleButtons(1).Enable = "off";
            else
                s.Tooltip = instrumentTooltip();
                obj.MainHBox.Widths = [-1, -1];
                obj.RightVBox.Heights = [-2, -1];
                obj.LeftVBox.Visible = "on";
                obj.LayoutToggleButtons(1).Enable = "on";
            end % if

        end % onGlobeToggled

        function onInstrumentMinimized( obj, s, ~, rowNum )
            %ONINSTRUMENTMINIMIZED Minimize the flight instrument panel.

            % Toggle the status of all panels in the same row.
            instrumentIdx = find( ...
                obj.InstrumentGrid.Contents == s.Parent );
            inRow1 = ismember( instrumentIdx, [1, 3, 5] );
            if inRow1
                set( obj.InstrumentGrid.Contents([1, 3, 5]), ...
                    "Minimized", ~s.Minimized )
            else
                set( obj.InstrumentGrid.Contents([2, 4, 6]), ...
                    "Minimized", ~s.Minimized )
            end % if

            % Evaluate the new box panel height.
            if s.Minimized
                newHeight = 22;
            else
                newHeight = -1;
            end % if

            % Expand or collapse the corresponding grid row.
            obj.InstrumentGrid.Heights(rowNum) = newHeight;

        end % onInstrumentMinimized

    end % methods ( Access = private )

end % classdef

function tip = instrumentTooltip()

tip = "Expand the attitude view and flight instruments";

end % instrumentTooltip

function tip = globeTooltip()

tip = "Expand the geoglobe view";

end % globeTooltip