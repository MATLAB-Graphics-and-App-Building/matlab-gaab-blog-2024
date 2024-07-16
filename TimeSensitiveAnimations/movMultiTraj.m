function movMultiTraj(opts)
%MOVMULTITRAJ Example animation.
%
%   movMultiTraj(opts) creates an animation that can be optionally
%   exported to a video file. To save the animation to a file call the 
%   function as follows: movMultiTraj(Save=true)

arguments (Input)
    opts.Save (1,1) logical = false
end

% Load two particles moving at different speeds and time resolutions
if ~isfile('particles.mat')
    websave('particles.mat','https://blogs.mathworks.com/graphics-and-apps/files/particles.mat');
end
load('particles.mat')

% Define movie duration, frame rate, and calculate total number of frames
videoDuration = 10; % physical seconds
fps = 60;
nFrames = videoDuration*fps;

% Retime particle2 and particle2 so that each timestep corresponds to 
% consecutive frames
tSimEnd = particle1.Time(end); % == particle2.Time(end)
dt = tSimEnd/nFrames;
particle1 = retime(particle1,'regular','linear','TimeStep',dt);
particle2 = retime(particle2,'regular','linear','TimeStep',dt);

% Initialize axes for all graphics children
ax = axes(...
    NextPlot = "add", ...
    XLim = [-1 1], ...
    YLim = [-1 1]);

% Initialize scatter plots
h(1) = hgtransform(Parent=ax);
h(2) = hgtransform(Parent=ax);
scatter(particle1.x(1), particle1.y(1), 'filled', Parent=h(1));
scatter(particle2.x(1), particle2.y(1), 'filled', Parent=h(2));

if opts.Save
    % Initialize video frame structure
    F(nFrames) = struct('cdata',[],'colormap',[]);
    F(1) = getframe(gcf);
end

for iFrame = 2:nFrames
    % Calculate translation from the position in the first frame
    translationVector1 = [particle1.x(iFrame)-particle1.x(1) particle1.y(iFrame)-particle1.y(1) 0];
    translationVector2 = [particle2.x(iFrame)-particle2.x(1) particle2.y(iFrame)-particle2.y(1) 0];
    % Calculate translation matrix
    translationMatrix1 = makehgtform('translate', translationVector1);
    translationMatrix2 = makehgtform('translate', translationVector2);
    % Apply translation to the scatter objects
    h(1).Matrix = translationMatrix1;
    h(2).Matrix = translationMatrix2;
    drawnow
    if opts.Save, F(iFrame) = getframe(gcf); end
end

if opts.Save
    v = VideoWriter('multitraj.avi');
    v.FrameRate = fps;
    open(v)
    writeVideo(v,F)
    close(v)
end