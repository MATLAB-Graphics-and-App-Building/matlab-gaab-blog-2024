function varargout = flightDashboard()
%FLIGHTDASHBOARD Application launcher.

% Check the number of output arguments.
nargoutchk( 0, 1 )

% Launch the application.
FDL = FlightDashboardLauncher();

% Return the figure handle, if requested.
if nargout == 1
    varargout{1} = FDL.Figure;
end % if

end % flightDashboard