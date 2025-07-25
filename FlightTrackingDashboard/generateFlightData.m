function generateFlightData( filename )
%GENERATEFLIGHTDATA Generate artifical flight data and export it to the 
%given file.

arguments ( Input )
    filename(:, 1) string {mustBeScalarOrEmpty} = "FlightPath.csv"
end % arguments ( Input )

% Create a time vector.
Time = (datetime( 2024, 6, 30, 10, 0, 1 ) : seconds( 1 ) : ...
    datetime( 2024, 6, 30, 11, 0, 0 )).';
numObservations = numel( Time );

% Interpolate a great-circle arc between Glasgow and Stansted airports.
GLA = [55.8691, 51.8860];
STN = [-4.4351, 0.2389];
[Latitude, Longitude] = interpm( GLA, STN, 0.005, "gc" );
samplePoints = linspace( 0, 1, numel( Latitude ) );
fineSamplePoints = linspace( 0, 1, numObservations );
LatLon = interp1( samplePoints, [Latitude, Longitude], ...
    fineSamplePoints, "linear" );
Latitude = LatLon(:, 1);
Longitude = LatLon(:, 2);

% Interpolate some sample airspeeds.
TimeAirspeed = [0, 0; 50, 150; 250, 300; 1000, 400; 2000, 400;
    2500, 300; 2750, 250; 2900, 200; 3000, 200; 3200, 130; 3300, 120;
    3600, 0];
samplePoints = linspace( 0, 1, height( TimeAirspeed ) );
TimeAirspeed = interp1( samplePoints, TimeAirspeed, ...
    fineSamplePoints, "linear" );
Airspeed = TimeAirspeed(:, 2);

% Rescale the speeds to make the flight data more realistic (1 hour of
% flight time traversing 300 knots).
Airspeed = 300 * Airspeed / trapz( fineSamplePoints, Airspeed );

% Interpolate some sample altitudes.
TimeAltitude = [0, 0; 1500, 22000; 2200, 22000; 2800, 11000;
    2900, 8000; 3000, 6000; 3600, 0];
samplePoints = linspace( 0, 1, height( TimeAltitude ) );
TimeAltitude = interp1( samplePoints, TimeAltitude, ...
    fineSamplePoints, "linear" );
Altitude = TimeAltitude(:, 2);

% Reset the random number generator.
s = rng();
rngCleanup = onCleanup( @() rng( s ) );
rng( "default" )

% Roll.
Roll = zeros( numObservations, 1 );
numRand = round( 0.25 * numObservations );
randIdx = randi( numObservations, numRand, 1 );
Roll(randIdx) = 0.5 * randn( numRand, 1 );

% Pitch.
TimePitch = [0, 0; 50, 12; 1500, 2; 2200, 2; 2300, -1; 2800, -0.5; ...
    2900, -0.5; 3000, -0.5; 3250, 0; 3500, 1; 3600, 0];
samplePoints = linspace( 0, 1, height( TimePitch ) );
TimePitch = interp1( samplePoints, TimePitch, ...
    fineSamplePoints, "linear" );
Pitch = TimePitch(:, 2);

% Yaw.
Yaw = zeros( numObservations, 1 );
numRand = round( 0.25 * numObservations );
randIdx = randi( numObservations, numRand, 1 );
Yaw(randIdx) = 0.5 * randn( numRand, 1 );

% Create and export the timetable.
tt = timetable( Time, Latitude, Longitude, Airspeed, Altitude, ...
    Roll, Pitch, Yaw );
writetimetable( tt, filename )

end % generateFlightData