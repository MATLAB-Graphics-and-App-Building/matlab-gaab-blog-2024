function d = dashboardRoot()
%DASHBOARDROOT Root folder for the flight dashboard application.

arguments ( Output )
    d(1, 1) string {mustBeFolder}
end % arguments ( Output )

d = fileparts( mfilename( "fullpath" ) );

end % dashboardRoot