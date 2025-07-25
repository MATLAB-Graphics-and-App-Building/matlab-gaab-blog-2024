classdef RectangularTextArea < ...
        matlab.graphics.chartcontainer.ChartContainer
    %RECTANGULARTEXTAREA Text area for use with a custom dashboard.

    properties
        Value(1, 1) string = ""
    end % properties

    properties ( Access = private )
        % Axes to hold the rectangle.
        Axes(:, 1) matlab.graphics.axis.Axes {mustBeScalarOrEmpty}
        % Rectangle to act as the text area backdrop.
        Rectangle(:, 1) matlab.graphics.primitive.Rectangle ...
            {mustBeScalarOrEmpty}
        % Text box to hold the text.
        TextBox(:, 1) matlab.graphics.primitive.Text {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = RectangularTextArea( namedArgs )
            %RECTANGULARTEXTAREA Create a RectangularTextArea widget, given
            %optional name-value arguments.

            arguments ( Input )
                namedArgs.?RectangularTextArea
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

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            % Create the axes.
            tl = obj.getLayout();
            set( tl, "TileSpacing", "none", "Padding", "tight" )
            obj.Axes = axes( "Parent", tl, ...                   
                "Toolbar", [], ...
                "DataAspectRatio", [1, 1, 1], ...
                "Visible", "off" );
            disableDefaultInteractivity( obj.Axes )

            % Add the rectangle.
            obj.Rectangle = rectangle( "Parent", obj.Axes, ...
                "Position", [0, 0, 1, 1], ...
                "Curvature", [0.15, 0.15], ...
                "FaceColor", "#0072BD", ...
                "LineWidth", 2, ...
                "EdgeColor", "w" );

            % Add the text object.
            obj.TextBox = text( "Parent", obj.Axes, ...
                "Color", "w", ...
                "Position", [0.5, 0.5, 0], ...
                "HorizontalAlignment", "center", ...
                "VerticalAlignment", "middle", ...
                "FontSize", FlightDashboardTheme.LabelFontSize, ...
                "FontName", FlightDashboardTheme.FontName );

        end % setup

        function update( obj )
            %UPDATE Update the component's graphics.

            % Update the text.
            obj.TextBox.String = obj.Value;

        end % update

    end % methods ( Access = protected )

end % classdef