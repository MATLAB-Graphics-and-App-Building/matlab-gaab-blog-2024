classdef FlightDashboardTheme
    %FLIGHTDASHBOARDTHEME Define common theme properties.

    properties ( Constant )
        % Font family name.
        FontName(1, 1) string = "Verdana"
        % Panel title font size.
        TitleFontSize(1, 1) double {mustBePositive} = 16
        % Label font size.
        LabelFontSize(1, 1) double {mustBePositive} = 14
        % Panel title color.
        PanelTitleColor {validatecolor} = "#0072BD"
        % Panel title text color.
        PanelTitleTextColor {validatecolor} = "w"
    end % properties ( Constant )
 
end % classdef