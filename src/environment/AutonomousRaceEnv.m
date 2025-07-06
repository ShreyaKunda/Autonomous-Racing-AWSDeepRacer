classdef AutonomousRaceEnv < rl.env.MATLABEnvironment
    % AutonomousRaceEnv: Environment for autonomous racing with time trials.

    properties
        % Track and car parameters
        TrackWidth = 10;            % Width of the track
        MaxSpeed = 5;               % Maximum speed of the car
        TimeLimit = 180;            % Time limit in seconds (3 minutes)

        % State and action spaces
        CurrentState               % Current state: [distance_from_center, speed, steering_angle, progress]
        ActionSpace                % Continuous actions: [throttle, steering]
        ObservationSpace           % Observations: [distance_from_center, speed, steering_angle, progress]
        
        % Simulation parameters
        Steps                      % Number of steps taken
        IsOffTrack                 % Boolean indicating if the car is off the track
        AllWheelsOnTrack = true;   % Boolean for car stability
        Progress = 0;              % Percentage of track completed
    end

    properties (Access = private)
        % Internal simulation state
        TrackCenter = 0;           % Centerline of the track (0 = on center)
        LapComplete = false;       % Indicator for lap completion
    end

    methods
        % Constructor
        function this = AutonomousRaceEnv()
            % Define action and observation spaces
            actionInfo = rlNumericSpec([2 1], 'LowerLimit', [-1; -30], 'UpperLimit', [1; 30]);
            observationInfo = rlNumericSpec([4 1], ...
                'LowerLimit', [-5; 0; -30; 0], ...
                'UpperLimit', [5; 5; 30; 100]);
            
            % Call the superclass constructor
            this = this@rl.env.MATLABEnvironment(observationInfo, actionInfo);

            % Initialize the environment
            this.ActionSpace = actionInfo;
            this.ObservationSpace = observationInfo;
            this.CurrentState = [0; 0; 0; 0]; % [distance_from_center, speed, steering_angle, progress]
            this.Steps = 0;
            this.IsOffTrack = false;
        end

        % Reset the environment
        function [initialObservation, info] = reset(this)
            % Reset the simulation to the starting state
            this.CurrentState = [0; 0; 0; 0];
            this.Steps = 0;
            this.IsOffTrack = false;
            this.LapComplete = false;
            this.Progress = 0;
            this.AllWheelsOnTrack = true;

            initialObservation = this.CurrentState;
            info = []; % Additional environment information (if needed)
        end

        % Step function
        function [nextObservation, reward, isDone, info] = step(this, action)
            % Extract action inputs
            throttle = action(1);        % Throttle value: [-1, 1]
            steering_angle = action(2);  % Steering angle: [-30, 30]

            % Simulate dynamics
            speed = max(0, min(this.CurrentState(2) + throttle, this.MaxSpeed)); % Update speed based on throttle
            distance_from_center = this.CurrentState(1) + 0.1 * steering_angle; % Simulate track position

            % Update progress
            progress = this.CurrentState(4) + speed * 0.01; % Progress proportional to speed
            this.Progress = progress;

            % Check for off-track condition
            if abs(distance_from_center) > this.TrackWidth / 2
                this.IsOffTrack = true;
                this.AllWheelsOnTrack = false;
            else
                this.IsOffTrack = false;
                this.AllWheelsOnTrack = true;
            end

            % Update the state
            this.CurrentState = [distance_from_center; speed; steering_angle; progress];
            this.Steps = this.Steps + 1;

            % Compute the reward
            params = struct(...
                'track_width', this.TrackWidth, ...
                'distance_from_center', distance_from_center, ...
                'speed', speed, ...
                'progress', progress, ...
                'all_wheels_on_track', this.AllWheelsOnTrack, ...
                'steps', this.Steps, ...
                'steering_angle', steering_angle, ...
                'is_offtrack', this.IsOffTrack ...
            );
            reward = this.rewardFunction(params);

            % Determine if the episode is done
            if progress >= 100 || this.IsOffTrack || this.Steps >= this.TimeLimit * 15
                isDone = true;
            else
                isDone = false;
            end

            % Return the next observation and info
            nextObservation = this.CurrentState;
            info = []; % Additional information (if needed)
        end

        % Reward function
        function reward = rewardFunction(this, params)
            % Reward logic from the provided reward function
            track_width = params.track_width;
            distance_from_center = params.distance_from_center;
            speed = params.speed;
            progress = params.progress;
            all_wheels_on_track = params.all_wheels_on_track;
            steps = params.steps;
            steering_angle = abs(params.steering_angle);
            is_offtrack = params.is_offtrack;

            % Calculate markers at varying distances from the center line
            marker_1 = 0.1 * track_width;
            marker_2 = 0.25 * track_width;
            marker_3 = 0.5 * track_width;

            % Initialize reward
            reward = 1e-3;

            if all_wheels_on_track
                % Reward based on distance from center
                if distance_from_center <= marker_1
                    reward = 1.0;
                elseif distance_from_center <= marker_2
                    reward = 0.5;
                elseif distance_from_center <= marker_3
                    reward = 0.1;
                else
                    reward = 1e-3;
                end

                % Speed-based reward
                if speed > 3.0
                    reward = reward * 1.5;
                elseif speed > 2.0
                    reward = reward * 1.2;
                else
                    reward = reward * 0.8;
                end

                % Steering penalty
                if steering_angle > 20
                    reward = reward * 0.7;
                elseif steering_angle > 10
                    reward = reward * 0.9;
                end
            end

            % Off-track penalty
            if is_offtrack
                reward = 1e-3;
            end

            % Progress-based reward
            if steps > 0
                progress_per_step = progress / steps;
                if progress_per_step > 0.1
                    reward = reward + 2.0;
                end
            end
        end
    end
end
