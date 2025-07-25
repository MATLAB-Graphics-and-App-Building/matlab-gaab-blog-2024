classdef ( Abstract ) FlightInstrumentView < FlightDashboardComponent
    %FLIGHTINSTRUMENTVIEW Superclass for concrete flight instrument view
    %implementation.

    properties ( Dependent )
        % Minimization status of the box panel.
        Minimized
        % Box panel callback: MinimizeFcn.
        MinimizeFcn        
    end % properties ( Dependent )

    properties ( GetAccess = protected, SetAccess = private )
        % Box panel.
        BoxPanel(:, 1) uix.BoxPanel {mustBeScalarOrEmpty}
        % Intermediate panel.
        MiddlePanel(:, 1) matlab.ui.container.Panel {mustBeScalarOrEmpty}
        % Inner grid.
        Grid(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = private )

    properties ( Abstract, GetAccess = {?matlab.unittest.TestCase, ...
            ?FlightInstrumenView}, SetAccess = protected )
        % Flight instrument.
        Instrument(:, 1) matlab.graphics.Graphics {mustBeScalarOrEmpty}
    end % properties ( Abstract, GetAccess = {...
    % ?matlab.unittest.TestCase, ?FlightInstrumentView}, ...
    % SetAccess = protected )

    methods

        function obj = FlightInstrumentView( model )
            %FLIGHTINSTRUMENTVIEW Construct a FlightInstrumentView object,
            %given the model.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

        end % constructor

        function value = get.Minimized( obj )

            value = obj.BoxPanel.Minimized;

        end % get.Minimized

        function set.Minimized( obj, value )

            obj.BoxPanel.Minimized = value;

        end % set.Minimized

        function value = get.MinimizeFcn( obj )

            value = obj.BoxPanel.MinimizeFcn;

        end % get.MinimizeFcn

        function set.MinimizeFcn( obj, value )

            obj.BoxPanel.MinimizeFcn = value;

        end % set.MinimizeFcn        

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component.

            % Add a box panel.
            obj.BoxPanel = uix.BoxPanel( "Parent", obj, ...
                "BorderType", "none", ...
                "TitleColor", FlightDashboardTheme.PanelTitleColor, ...
                "ForegroundColor", ...
                FlightDashboardTheme.PanelTitleTextColor, ...
                "FontSize", FlightDashboardTheme.TitleFontSize, ...
                "FontName", FlightDashboardTheme.FontName );
            obj.MiddlePanel = uipanel( "Parent", obj.BoxPanel, ...
                "BorderType", "none" );
            obj.Grid = uigridlayout( obj.MiddlePanel, [1, 1] );

        end % setup

        function updateInstrument( obj, dataVariables, panelTitle )
            %UPDATEINSTRUMENT Helper method for updating the flight
            %instrument when the current time is changed.

            arguments ( Input )
                obj(1, 1) FlightInstrumentView
                dataVariables(1, :) string
                panelTitle(1, 1) string
            end % arguments ( Input )

            t = obj.Model.CurrentTime;
            dataVariablesNoSpaces = erase( dataVariables, " " );
            currentValues = obj.Model.FlightData{t, dataVariablesNoSpaces};

            if ~isempty( currentValues )
                for k = 1 : numel( dataVariablesNoSpaces )
                    obj.Instrument.(dataVariablesNoSpaces(k)) = ...
                        currentValues(k);
                end % for
                valuesCell = num2cell( currentValues );
                obj.BoxPanel.Title = sprintf( panelTitle, valuesCell{:} );
            else
                for k = 1 : numel( dataVariablesNoSpaces )
                    obj.Instrument.(dataVariablesNoSpaces(k)) = 0;
                end % for
                obj.BoxPanel.Title = join( dataVariables, " | " );
            end % if

        end % updateInstrument

    end % methods ( Access = protected )    

end % classdef