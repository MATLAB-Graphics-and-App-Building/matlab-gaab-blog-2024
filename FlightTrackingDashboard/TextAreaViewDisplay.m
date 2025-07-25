classdef TextAreaViewDisplay < FlightDashboardComponent
    %TEXTAREAVIEWDISPLAY Display the various text area views in a
    %configurable view.

    properties ( Access = private )
        % Main layout grid.
        LayoutGrid(:, 1) matlab.ui.container.GridLayout ...
            {mustBeScalarOrEmpty}
        % Control layout.
        ControlLayout(:, 1) matlab.ui.container.GridLayout ...
            {mustBeScalarOrEmpty}
        % Check box for tiling the views.
        TileCheckBox(:, 1) matlab.ui.control.CheckBox {mustBeScalarOrEmpty}
        % Buttons for switching between the views in single view mode.
        Buttons(:, 1) matlab.ui.control.Button
        % Outer card panel.
        OuterCardPanel(:, 1) uix.CardPanel {mustBeScalarOrEmpty}
        % View grid.
        ViewGrid(:, 1) uix.Grid {mustBeScalarOrEmpty}
        % Inner card panel.
        InnerCardPanel(:, 1) uix.CardPanel {mustBeScalarOrEmpty}
        % Text area views.
        Views(:, 1) TextAreaView
    end % properties ( Access = private )

    methods

        function obj = TextAreaViewDisplay( model, namedArgs )
            %TEXTAREAVIEWDISPLAY Construct a TextAreaViewDisplay object,
            %given the model and optional name-value arguments.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
                namedArgs.?TextAreaViewDisplay
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

            % Set any user-defined properties.
            set( obj, namedArgs )

            % Add the views.
            obj.Views(1) = TimeView( obj.Model, ...
                "Parent", obj.ViewGrid );
            obj.Views(2) = YawView( obj.Model, ...
                "Parent", obj.ViewGrid );
            obj.Views(3) = LatitudeView( obj.Model, ...
                "Parent", obj.ViewGrid );
            obj.Views(4) = LongitudeView( obj.Model, ...
                "Parent", obj.ViewGrid );
            obj.ViewGrid.Heights = [-1, -1];

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            obj.LayoutGrid = uigridlayout( obj, [2, 1], ...
                "RowHeight", ["fit", "1x"] );
            obj.ControlLayout = uigridlayout( obj.LayoutGrid, [1, 3], ...
                "ColumnWidth", repelem( "fit", 3 ), ...
                "ColumnSpacing", 2 );
            obj.TileCheckBox = uicheckbox( "Parent", obj.ControlLayout, ...
                "Value", true, ...
                "Text", "Tile", ...
                "Tooltip", "Tile views in a 2-by-2 grid", ...
                "ValueChangedFcn", @obj.onTileCheckBoxClicked );
            obj.Buttons(1) = uibutton( obj.ControlLayout, ...
                "Text", char( 9664 ), ...
                "Enable", "off", ...
                "Tooltip", "Show the previous view", ...
                "ButtonPushedFcn", @obj.onPreviousViewButtonPushed );
            obj.Buttons(2) = uibutton( obj.ControlLayout, ...
                "Text", char( 9654 ), ...
                "Enable", "off", ...
                "Tooltip", "Show the next view", ...
                "ButtonPushedFcn", @obj.onNextViewButtonPushed );
            obj.OuterCardPanel = uix.CardPanel( ...
                "Parent", obj.LayoutGrid );
            obj.InnerCardPanel = uix.CardPanel( ...
                "Parent", obj.OuterCardPanel );
            obj.ViewGrid = uix.Grid( "Parent", obj.OuterCardPanel );

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

        function onFlightDataChanged( ~, ~, ~ )
            %ONFLIGHTDATACHANGED Respond to the model event
            %"FlightDataChanged".

        end % onFlightDataChanged

        function onCurrentTimeChanged( ~, ~, ~ )
            %ONCURRENTTIMECHANGED Respond to the model event
            %"CurrentTimeChanged".

        end % onCurrentTimeChanged

    end % methods ( Access = protected )

    methods ( Access = private )

        function onTileCheckBoxClicked( obj, ~, ~ )
            %ONTILECHECKBOXCLICKED Toggle between tiled and single mode.

            checked = obj.TileCheckBox.Value;
            if checked
                set( obj.Views, "Parent", obj.ViewGrid, ...
                    "Visible", "on" )
                obj.ViewGrid.Heights = [-1, -1];
                set( obj.Buttons, "Enable", "off" )
                obj.OuterCardPanel.Selection = 2;
            else
                set( obj.Views, "Parent", obj.InnerCardPanel, ...
                    "Visible", "on" )
                set( obj.Buttons, "Enable", "on" )
                obj.OuterCardPanel.Selection = 1;
            end % if

        end % onTileCheckBoxClicked

        function onPreviousViewButtonPushed( obj, ~, ~ )
            %ONPREVIOUSVIEWBUTTONPUSHED Respond to the user clicking the
            %previous view button.

            icp = obj.InnerCardPanel;
            newSelectionIdx = circshift( 1 : numel( icp.Children ), 1 );
            icp.Selection = newSelectionIdx(icp.Selection);

        end % onPreviousViewButtonPushed

        function onNextViewButtonPushed( obj, ~, ~ )
            %ONNEXTVIEWBUTTONPUSHED Respond to the user clicking the next
            %view button.

            icp = obj.InnerCardPanel;
            newSelectionIdx = circshift( 1 : numel( icp.Children ), -1 );
            icp.Selection = newSelectionIdx(icp.Selection);

        end % onNextViewButtonPushed

    end % methods ( Access = private )

end % classdef