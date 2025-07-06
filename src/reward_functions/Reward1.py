def reward_function(params):
    '''
    Reward function 1 to encourage faster laps on the AWS DeepRacer track
    '''

    # Read input parameters
    track_width = params['track_width']
    distance_from_center = params['distance_from_center']
    speed = params['speed']
    progress = params['progress']
    all_wheels_on_track = params['all_wheels_on_track']
    steps = params['steps']
    time_limit = 180  # 3-minute time trial

    # Calculate 3 markers that are at varying distances away from the center line
    marker_1 = 0.1 * track_width
    marker_2 = 0.25 * track_width
    marker_3 = 0.5 * track_width

    # Initialize reward
    reward = 1e-3  # small reward by default if things go wrong

    # Reward if all wheels are on track
    if all_wheels_on_track:
        # Give a higher reward if the car is closer to the center line
        if distance_from_center <= marker_1:
            reward = 1.0
        elif distance_from_center <= marker_2:
            reward = 0.5
        elif distance_from_center <= marker_3:
            reward = 0.1
        else:
            reward = 1e-3  # likely off track
        
        
        if speed > 3.0:  # higher speed
            reward *= 1.5
        elif speed > 2.0:  # moderate speed
            reward *= 1.2
        else:
            reward *= 0.8  # slow speed is discouraged
    
    progress_per_step = progress / steps if steps > 0 else 0
    if progress_per_step > 0.1:
        reward += 2.0  

    if steps > time_limit * 15:  
        reward *= 0.5  
    
    return float(reward)