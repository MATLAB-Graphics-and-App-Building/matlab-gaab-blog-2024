classdef FlightPathData < matlab.mixin.indexing.RedefinesDot & ...
        matlab.mixin.indexing.RedefinesBrace
    %FLIGHTPATHDATA Stores data for a single flight path.

    properties ( Access = private )
        % Timetable containing flight path data.
        FlightDataTimetable(:, :) timetable ...
            {mustBeFlightDataTimetable} = defaultFlightDataTimetable()
    end % properties ( Access = private )    

    methods

        function obj = FlightPathData( filename )
            %FLIGHTPATHDATA Construct a FlightPathData object.

            arguments ( Input )
                filename(:, 1) string {mustBeFile, ...
                    mustBeScalarOrEmpty} = string.empty( 0, 1 )
            end % arguments ( Input )

            if ~isempty( filename )

                % Import the data.
                obj.FlightDataTimetable = readtimetable( filename );
                tt = obj.FlightDataTimetable;

                % Climb rate (convert from feet/second to feet/minute).
                tt.ClimbRate = [0; 60 * diff( tt.Altitude )];

                % Heading.
                dLongitude = [0; diff( tt.Longitude )];
                LaggedLatitude = [0; tt.Latitude(1:end-1)];
                value = atan2d( sind( dLongitude ) .* ...
                    cosd( LaggedLatitude ), ...
                    cosd( tt.Latitude ) .* sind( LaggedLatitude ) - ...
                    sind( tt.Latitude ) .* cosd( LaggedLatitude ) ...
                    .* cosd( dLongitude ) );
                tt.Heading = 180 - mod( value + 360, 360 );
                tt.Heading(1) = tt.Heading(2); % Backfill first value

                % Slip.
                dHeading = [0; diff( deg2rad( tt.Heading ) )];
                g = 9.81;
                dLatLon  = [0, 0; diff( deg2rad( ...
                    [tt.Latitude, tt.Longitude] ) )];
                tt.Slip = rad2deg( tand( tt.Roll ) - ...
                    dHeading .* sqrt( sum( dLatLon.^2, 2 ) ) / g );               

                % Reassign the data.
                obj.FlightDataTimetable = tt;

            end % if

        end % constructor

        function p = properties( obj )
            %PROPERTIES FlightPathData properties (used for
            %tab-completion).           

            % Check the number of outputs.
            nargoutchk( 0, 1 )

            % List the properties.
            tt = obj.FlightDataTimetable;
            props = string( [tt.Properties.DimensionNames(1), ...
                tt.Properties.VariableNames] );

            if nargout == 0

                % Display the properties.
                for k = 1 : length( props )
                    fprintf( "%s\n", props(k) )
                end % for

            else

                % Return the list of properties.
                p = cellstr( props );

            end % if

        end % properties        

    end % methods

    methods ( Access = protected )

        function varargout = dotReference( obj, indexOp )

            [varargout{1:nargout}] = obj.FlightDataTimetable.(indexOp);

        end % dotReference

        function varargout = dotAssign( ~, ~, varargin ) %#ok<STOUT>

            error( "FlightPathData:DotAssignment", ...
                "FlightPathData objects do not support dot assignment." )

        end % dotAssign

        function n = dotListLength( obj, indexOp, indexContext )

            n = listLength( obj.FlightDataTimetable, ...
                indexOp, indexContext );

        end % dotListLength

        function varargout = braceReference( obj, indexOp )

            [varargout{1:nargout}] = obj.FlightDataTimetable.(indexOp);

        end % braceReference

        function varargout = braceAssign( ~, ~, varargin ) %#ok<STOUT>

            error( "FlightPathData:BraceAssignment", ...
                "FlightPathData objects do not support brace assignment." )

        end % braceAssign

        function n = braceListLength( obj, indexOp, indexContext )

            n = listLength( obj.FlightDataTimetable, ...
                indexOp, indexContext );

        end % braceListLength

    end % methods ( Access = protected )

end % classdef

function mustBeFlightDataTimetable( tt )
%MUSTBEFLIGHTDATATIMETABLE Validate that the input timetable, tt, contains
%flight path data.

% Check the time dimension.
assert( tt.Properties.DimensionNames(1) == "Time", ...
    "FlightPathData:InvalidName", ...
    "Timetable must use 'Time' for the name of the time dimension." )
assert( isa( tt.Time, "datetime" ), "FlightPathData:InvalidTimeType", ...
    "Timetable must use datetime values." )
assert( issorted( tt ), "FlightPathData:Unsorted", ...
    "Timetable must be sorted in chronological order." )

% Check the variable names.
varNames = [string( tt.Properties.DimensionNames(1) ), ...
    string( tt.Properties.VariableNames )];
requiredNames = ["Time", "Latitude", "Longitude", "Altitude", ...
    "Roll", "Pitch", "Yaw", "Airspeed"];
assert( all( ismember( requiredNames, varNames ) ), ...
    "FlightPathData:InvalidVariableNames", ...
    "Timetable must have the variables 'Time', 'Latitude', " + ...
    "'Longitude', 'Altitude', 'Roll', 'Pitch', 'Yaw'" + ...
    ", and 'Airspeed'." )

% Check the variable types and attributes.
varTypes = string( varfun( @class, tt, "OutputFormat", "cell" ) );
assert( all( varTypes == "double" ), "FlightPathData:InvalidTypes", ...
    "Timetable must contain numeric variables of type double." )
data = tt.Variables;
mustBeReal( data )
mustBeFinite( data )

end % mustBeFlightDataTimetable

function tt = defaultFlightDataTimetable()
%DEFAULTFLIGHTDATATIMETABLE Create a default timetable containing flight
%data.

Time = datetime.empty( 0, 1 );
d = double.empty( 0, 1 );
Latitude = d;
Longitude = d;
Altitude = d;
Airspeed = d;
Roll = d;
Pitch = d;
Yaw = d;
ClimbRate = d;
Heading = d;
Slip = d;

tt = timetable( Time, Latitude, Longitude, ...
    Altitude, Airspeed, Roll, Pitch, Yaw, ...
    ClimbRate, Heading, Slip );

end % defaultFlightDataTimetable