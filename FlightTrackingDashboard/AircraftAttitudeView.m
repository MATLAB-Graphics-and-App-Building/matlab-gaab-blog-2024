classdef AircraftAttitudeView < FlightDashboardComponent
    %AIRCRAFTATTITUDEVIEW Provide a view of the aircraft's attitude.

    properties ( Access = private )
        % Aircraft chart.
        Chart(:, 1) AircraftChart {mustBeScalarOrEmpty}
        % Dropdown menu for the exaggeration factor.
        ExaggerationDropdown(:, 1) matlab.ui.control.DropDown ...
            {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = AircraftAttitudeView( model, namedArgs )
            %AIRCRAFTATTITUDEVIEW Construct an AircraftAttitudeView, given
            %the model and optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?AircraftAttitudeView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

            % Refresh the component.
            obj.onFlightDataChanged()

            % Set any user-defined properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component.

            % Create the chart.
            mainGrid = uigridlayout( obj, [2, 2], ...
                "RowHeight", ["fit", "1x"], ...
                "ColumnWidth", ["1x", "fit"] );
            uilabel( "Parent", mainGrid, ...
                "Text", "Exaggeration", ...
                "HorizontalAlignment", "right", ...
                "FontSize", FlightDashboardTheme.LabelFontSize, ...
                "FontName", FlightDashboardTheme.FontName );
            obj.ExaggerationDropdown = uidropdown( "Parent", mainGrid, ...
                "Items", (1:3) + "x", ...                
                "ItemsData", 1:3, ...                
                "Value", 1, ...
                "Tooltip", "Select the exaggeration factor", ...
                "FontName", FlightDashboardTheme.FontName, ...
                "FontSize", FlightDashboardTheme.LabelFontSize );
            obj.Chart = AircraftChart( "Parent", mainGrid );
            title( obj.Chart, "Attitude", ...
                "FontName", FlightDashboardTheme.FontName, ...
                "FontSize", FlightDashboardTheme.TitleFontSize )
            obj.Chart.Layout.Column = [1, 2];            
            title( obj.Chart, "Aircraft Attitude", ...
                "FontSize", FlightDashboardTheme.TitleFontSize, ...
                "FontName", FlightDashboardTheme.FontName )

        end % setup

        function update( ~ )
            %UPDATE Update the component.

        end % update

        function onFlightDataChanged( obj, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

            obj.Chart.reset()
            obj.onCurrentTimeChanged()

        end % onFlightDataChanged

        function onCurrentTimeChanged( obj, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".

            t = obj.Model.CurrentTime;
            rollPitchYaw = obj.Model.FlightData{t, ...
                ["Roll", "Pitch", "Yaw"]};
            dropdown = obj.ExaggerationDropdown;
            exaggeration = dropdown.ItemsData(dropdown.ValueIndex);

            if ~isempty( rollPitchYaw )
                obj.Chart.setAttitude( rollPitchYaw(1), ...
                    rollPitchYaw(2), rollPitchYaw(3), exaggeration )
            end % if

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

end % classdef