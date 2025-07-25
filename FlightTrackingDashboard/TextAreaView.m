classdef ( Abstract ) TextAreaView < FlightDashboardComponent
    %TEXTAREAVIEW Superclass for implementation of text area views.

    properties ( GetAccess = protected, SetAccess = private )
        % Rectangular text area.
        TextArea(:, 1) RectangularTextArea {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = private )

    methods

        function obj = TextAreaView( model )
            %TEXTAREAVIEW Construct a TextAreaView object, given the model.

            arguments ( Input )
                model(1, 1) FlightDashboardModel
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@FlightDashboardComponent( model )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.
            
            obj.TextArea = RectangularTextArea( "Parent", obj );

        end % setup        

        function updateTextArea( obj, dataVariable, newText )
            %UPDATETEXTAREA Helper method for updating the text area when
            %the current time is changed.

            arguments ( Input )
                obj(1, 1) TextAreaView
                dataVariable(1, 1) string
                newText(1, 1) string
            end % arguments ( Input )

            t = obj.Model.CurrentTime;
            if dataVariable ~= "Time"
                value = obj.Model.FlightData{t, dataVariable};
            else
                value = string( t, "HH:mm:ss" );
            end % if

            if ~isempty( value )
                obj.TextArea.Value = sprintf( newText, value );
            else
                obj.TextArea.Value = dataVariable;
            end % if

        end % updateTextArea

    end % methods ( Access = protected )

end % classdef