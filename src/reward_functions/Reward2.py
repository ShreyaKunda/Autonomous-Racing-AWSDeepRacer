def reward_function(params):
    '''
    Reward function 2 for a time trial: Complete as many laps as possible while maintaining control.
    '''

    # Read input parameters
    track_width = params['track_width']
    distance_from_center = params['distance_from_center']
    speed = params['speed']
    progress = params['progress']
    all_wheels_on_track = params['all_wheels_on_track']
    steps = params['steps']
    steering_angle = abs(params['steering_angle'])  # absolute value of the steering angle
    is_offtrack = params['is_offtrack']
    time_limit = 180  # 3-minute time trial
    
    # Calculate markers at varying distances from the center line
    marker_1 = 0.1 * track_width
    marker_2 = 0.25 * track_width
    marker_3 = 0.5 * track_width

    # Initialize reward
    reward = 1e-3  # Small reward if things go wrong by default

    # If all wheels are on the track, reward based on the distance from the center line
    if all_wheels_on_track:
        # Encourage staying close to the center of the track
        if distance_from_center <= marker_1:
            reward = 1.0
        elif distance_from_center <= marker_2:
            reward = 0.5
        elif distance_from_center <= marker_3:
            reward = 0.1
        else:
            reward = 1e-3  # Likely off track or at the edge

        # Speed-based reward
        if speed > 3.0:  # High speed but controllable
            reward *= 1.5
        elif speed > 2.0:  # Moderate speed
            reward *= 1.2
        else:  # Too slow
            reward *= 0.8

        # Penalize sharp steering angles to avoid erratic behavior
        if steering_angle > 20:  # More than 20 degrees of steering
            reward *= 0.7  # Penalize
        elif steering_angle > 10:
            reward *= 0.9  # Slight penalty for moderate turns

    # Additional penalty if the car goes off-track
    if is_offtrack:
        reward = 1e-3  # Minimal reward when the car is off the track

    # Reward consistent progress: high progress per step indicates efficient lap completion
    progress_per_step = progress / steps if steps > 0 else 0
    if progress_per_step > 0.1:
        reward += 2.0  # Bonus reward for steady progress

    # Penalize if too many steps are taken (slow progress) without finishing a lap
    if steps > time_limit * 15:
        reward *= 0.5  # Discourage taking too long to finish a lap

    # Encourage controlled speed by penalizing erratic, high-speed turns
    if speed > 3.0 and steering_angle > 15:
        reward *= 0.5  # Reduce reward if the car is going too fast and steering too much

    return float(reward)