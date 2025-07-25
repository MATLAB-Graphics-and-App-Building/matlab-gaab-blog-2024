classdef PlaybackControls < ...
        matlab.ui.componentcontainer.ComponentContainer
    %PLAYBACKCONTROLS Widget providing playback controls.

    properties ( Access = private )
        % Play button.
        PlayButton(:, 1) matlab.ui.control.Button {mustBeScalarOrEmpty}
        % Pause button.
        PauseButton(:, 1) matlab.ui.control.Button {mustBeScalarOrEmpty}
        % Stop button.
        StopButton(:, 1) matlab.ui.control.Button {mustBeScalarOrEmpty}
        % Current time slider.
        CurrentTimeSlider(:, 1) matlab.ui.control.Slider ...
            {mustBeScalarOrEmpty}
        % Time label.
        TimeLabel(:, 1) matlab.ui.control.Label {mustBeScalarOrEmpty}
        % Speed spinner.
        SpeedSpinner(:, 1) matlab.ui.control.Spinner {mustBeScalarOrEmpty}
        % Playback timer.
        Timer(:, 1) timer {mustBeScalarOrEmpty}        
    end % properties ( Access = private )

    properties ( Access = private )
        % Last known time (seconds).
        LastKnownTime(1, 1) double {mustBeReal, mustBeNonInf} = NaN
        % Logical flag for enabling/disabling callbacks.
        CallbacksDisabled(1, 1) logical = false
    end % private properties

    events ( NotifyAccess = private, HasCallbackProperty )        
        CurrentTimeSelected
        TimerTicked
        PlaybackStopped
    end % events ( NotifyAccess = private, HasCallbackProperty)

    methods

        function obj = PlaybackControls( namedArgs )
            %PLAYBACKCONTROLS Construct a PlaybackControls object,
            %given optional name-value pair arguments.

            arguments ( Input )                
                namedArgs.?PlaybackControls
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                "Parent", [], ...
                "Units", "normalized", ...
                "Position", [0, 0, 1, 1] )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

        function delete( obj )
            %DELETE Destroy the timer when the widget is destroyed.

            if obj.Timer.Running == "on"
                stop( obj.Timer )
            end % if

            delete( obj.Timer )

        end % delete

        function selectTime( obj, t )
            %SELECTTIME Select the given time, t.

            arguments ( Input )
                obj(1, 1) PlaybackControls
                t(1, 1) double {mustBeReal, mustBeNonInf}
            end % arguments ( Input )

            % Store the given time.
            obj.LastKnownTime = t;

            % Disable the callbacks during this operation.
            obj.CallbacksDisabled = true;
            callbackCleanup = onCleanup( ...
                @() set( obj, "CallbacksDisabled", false ) );

            % Stop the timer if necessary.
            maxTime = obj.CurrentTimeSlider.Limits(2);
            if obj.LastKnownTime > maxTime
                obj.LastKnownTime = maxTime;
                if obj.Timer.Running == "on"
                    stop( obj.Timer )
                end % if
            end % if

            % Update the slider and time label.
            if ~isnan( obj.LastKnownTime )
                obj.CurrentTimeSlider.Value = obj.LastKnownTime;
                obj.TimeLabel.Text = string( seconds( ...
                    obj.LastKnownTime ), "mm:ss" );
            else
                obj.CurrentTimeSlider.Value = 0;
                obj.TimeLabel.Text = "00:00";
            end % if
            
        end % selectTime

        function selectTimeLimits( obj, enableControls, timeLimits, ...
                lastKnownTime )
            %SELECTTIMELIMITS Select a new set of time limits for the
            %slider.

            arguments ( Input )
                obj(1, 1) PlaybackControls
                enableControls(1, 1) logical
                timeLimits(1, 2) double {mustBeReal, mustBeFinite, ...
                    mustBeNonnegative, mustBeIncreasing}
                lastKnownTime(1, 1) double {mustBeReal, mustBeFinite, ...
                    mustBeNonnegative}
            end % arguments ( Input )

             % Stop the timer.
            obj.Timer.stop()

            % Enable/disable the controls.
            if enableControls
                set( [obj.PlayButton, obj.CurrentTimeSlider, ...
                    obj.SpeedSpinner], "Enable", "on" )
            else
                set( [obj.PlayButton, obj.PauseButton, ...
                    obj.StopButton, obj.CurrentTimeSlider, ...
                    obj.TimeLabel, obj.SpeedSpinner], "Enable", "off" )
            end % if

            % Update the slider limits and value.            
            obj.CurrentTimeSlider.Limits = timeLimits;
            obj.selectTime( lastKnownTime )         

        end % selectTimeLimits     

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the widget's graphics.

            % Create the main grid.
            mainGrid = uigridlayout( "Parent", obj, ...
                "RowHeight", 22, ...
                "ColumnWidth", {22, 22, 22, "fit", "1x", "fit"}, ...
                "ColumnSpacing", 5 );

            % Play button.
            playIcon = fullfile( dashboardRoot(), "Images", ...
                "Start.png" );
            obj.PlayButton = uibutton( mainGrid, ...
                "BackgroundColor", "w", ...
                "Tooltip", "Start playback", ...
                "Text", "", ...
                "Icon", playIcon, ...
                "ButtonPushedFcn", @obj.onPlayButtonPushed );

            % Pause button.
            pauseIcon = fullfile( dashboardRoot(), "Images", ...
                "Pause.png" );
            obj.PauseButton = uibutton( mainGrid, ...
                "BackgroundColor", "w", ...
                "Enable", "off", ...
                "Tooltip", "Pause playback", ...
                "Text", "", ...
                "Icon", pauseIcon, ...
                "ButtonPushedFcn", @obj.onPauseButtonPushed );

            % Stop button.
            stopIcon = fullfile( dashboardRoot(), "Images", ...
                "Stop.png" );
            obj.StopButton = uibutton( mainGrid, ...
                "BackgroundColor", "w", ...
                "Enable", "off", ...
                "Tooltip", "Stop playback", ...
                "Text", "", ...
                "Icon", stopIcon, ...
                "ButtonPushedFcn", @obj.onStopButtonPushed );

            % Time display.
            obj.TimeLabel = uilabel( "Parent", mainGrid, ...               
                "HorizontalAlignment", "center", ...
                "Text", "00:00" );

            % Slider for the current time.
            obj.CurrentTimeSlider = uislider( "Parent", mainGrid, ...
                "Tooltip", "Adjust the current time", ...
                "Limits", [0, 100], ...
                "MinorTicks", [], ...
                "MajorTicks", [], ...
                "BusyAction", "cancel", ...
                "Interruptible", "on", ...
                "ValueChangedFcn", @obj.onCurrentTimeSliderMoved );

            % Spinner for controlling the playback speed.
            obj.SpeedSpinner = uispinner( "Parent", mainGrid, ...
                "Tooltip", "Adjust the playback speed", ...
                "Limits", [1, 10], ...
                "Step", 1, ...
                "Value", 1, ...
                "ValueDisplayFormat", "%.0f  x", ...
                "HorizontalAlignment", "left" );

            % Create the timer.
            obj.Timer = timer( "ExecutionMode", "fixedRate", ...
                "Period", 1, ...
                "TimerFcn", @obj.onTimerExecuting );

        end % setup

        function update( ~ )
            %UPDATE Update the widget's graphics.

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onTimerExecuting( obj, ~, ~ )
            %OMTIMEREXECUTING Timer callback.

            % Check whether the user has dragged the slider.
            if obj.CurrentTimeSlider.Value ~= obj.LastKnownTime
                return
            end % if

            % Otherwise, notify the event and share the relevant data.            
            offset = obj.SpeedSpinner.Value * obj.Timer.Period;
            timerData = TimerEventData( obj.LastKnownTime, offset );
            obj.notify( "TimerTicked", timerData )            

        end % onTimerExecuting

        function onPlayButtonPushed( obj, ~, ~ )
            %ONPLAYBUTTONPUSHED Respond to the user pushing the play
            %button.

            % Update the controls.
            obj.PlayButton.Enable = "off";
            set( [obj.PauseButton, obj.StopButton, ...
                obj.CurrentTimeSlider, obj.TimeLabel, ...
                obj.SpeedSpinner], "Enable", "on" )

            % Start the timer.
            if obj.Timer.Running == "off"
                start( obj.Timer )
            end % if

        end % onPlayButtonPushed

        function onPauseButtonPushed( obj, ~, ~ )
            %ONPAUSEBUTTONPUSHED Respond to the user pushing the pause
            %button.

            % Stop the timer.
            obj.Timer.stop()

            % Update the controls.
            set( [obj.PlayButton, obj.StopButton, ...
                obj.CurrentTimeSlider], "Enable", "on" )
            obj.PauseButton.Enable = "off";            

        end % onPauseButtonPushed

        function onStopButtonPushed( obj, ~, ~ )
            %ONSTOPBUTTONPUSHED Respond to the user pushing the stop
            %button.

            % Stop the timer.
            obj.Timer.stop()

            % Update the controls.
            set( [obj.PauseButton, obj.StopButton], "Enable", "off" )
            set( [obj.PlayButton, obj.CurrentTimeSlider], "Enable", "on" )            

            % Reset the current time.
            obj.notify( "PlaybackStopped" )

        end % onStopButtonPushed

        function onCurrentTimeSliderMoved( obj, ~, ~ )
            %ONCURRENTTIMESLIDERMOVED Respond to the user dragging the
            %current time slider.

            % Exit if callbacks are disabled.
            if obj.CallbacksDisabled
                return
            end % if

            % Notify the event.
            sliderData = SliderEventData( obj.CurrentTimeSlider.Value );
            obj.notify( "CurrentTimeSelected", sliderData )

        end % onCurrentTimeSliderMoved

    end % methods ( Access = private )

end % classdef

function mustBeNonInf( t )
%MUSTBENONINF Validate that the input, t, is not +Inf or -Inf.

assert( ~ismember( t, [Inf, -Inf] ), ...
    "PlaybackControls:mustBeNonInf:DetectedInfiniteValue", ...
    "The value must not be Inf or -Inf." )

end % mustBeNonInf

function mustBeIncreasing( x )
%MUSTBEINCREASING Validate that the input, x, is increasing.

validateattributes( x, "double", "increasing" )

end % mustBeIncreasing