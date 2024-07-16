function movSolarSystem(opts)

arguments (Input)
    opts.Save (1,1) logical = false
end

% Orbital data for Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, 
% Neptune
orbRad = [0.39, 0.72, 1, 1.52, 5.2, 9.54 19.2 30.07]*10; % orbital radius [AU*10]
planRad = [0.38, 0.95, 1, 0.53, 11.21, 9.45, 4, 3.88]; % planet radius [RE]
period = [0.24, 0.62, 1, 1.88, 11.87, 29.45, 84.07, 164.9]; % revolution period [yrs]
nplanets = numel(planRad);

% Create empty, black figure that fills 75% of the screen
fig = figure(...
    Name = "Solar System Animation", ...
    Color = "none", ...
    ToolBar = "none", ...
    MenuBar = "none");
sz = groot().ScreenSize(3:4); perc = 0.75;
fig.Position = [(1-perc)/2*sz perc*sz];

% Create axes
ax = axes(...
    Parent = fig, ...
    Visible = false,...
    Projection = "perspective", ...
    CameraViewAngle = 5.4, ...
    NextPlot = "add", ...
    DataAspectRatio = [1 1 1]);

% Simulate sunlight from the origin
light(ax, Style="local", Position=[0 0 0]);

% Initialize points for planets' surfaces and orbit lines
[sx,sy,sz] = sphere(200);
angVals = 0:360;

% Initialize variables for storing rotation/translation matrices for moving
% objects
[h,s,t] = deal(cell(nplanets,1));

% Create yellow Sun at the origin
sun = surf(sx,sy,sz, Parent=ax, Facecolor=[1 1 0], EdgeColor="none");
material(sun, [1 1 1]) % exclude Sun from light effects

% Get colormap to color lines and planets
cmap = lines;

for p = 1:nplanets
    % Create transform object for moving each planet
    h{p} = hgtransform(Parent=ax);

    % Draw planet with opaque surface of random color
    surf(sx,sy,sz, Parent=h{p}, Facecolor=cmap(p,:), EdgeColor="none", SpecularStrength=0);

    % Transform matrix to scale the planet size according to its radius
    s{p} = makehgtform('scale', planRad(p));

    % Transform matrix to initialize planet position
    ang0 = 360*rand;
    pos0 = [orbRad(p)*cosd(ang0) orbRad(p)*sind(ang0) 0];
    t{p} = makehgtform('translate', pos0);

    % Draw orbital line
    line(orbRad(p)*cosd(angVals), orbRad(p)*sind(angVals), Color=cmap(p,:), Parent=ax);
end

% Initialize video frame structure
nframes = 720;
F(nframes) = struct('cdata',[],'colormap',[]);

for iFrame = 1:nframes
    % Move planets
    for p = 1:nplanets
        m = makehgtform('axisrotate',[0 0 1], iFrame*pi/60/period(p));
        h{p}.Matrix = m*t{p}*s{p}; % the transformation is a combination of scaling, translation and rotation
    end

    % Move camera view angle and position
    if iFrame > 90 && iFrame < 240
        ax.CameraViewAngle = 5.4 - (iFrame-90)*0.0307;
    elseif iFrame>=240 && iFrame < 390
        ax.CameraPosition = [0 -5657*sind((iFrame-240)*0.4667) 5657*cosd((iFrame-240)*0.4667)];
        ax.CameraViewAngle = ax.CameraViewAngle - 0.001;
    end

    drawnow;
    if opts.Save, F(iFrame) = getframe(gcf); end 
end

if opts.Save
    v = VideoWriter('solarsystem.avi');
    open(v)
    writeVideo(v,F)
    close(v)
end