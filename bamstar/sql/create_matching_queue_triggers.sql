-- Function to add user to matching queue
CREATE OR REPLACE FUNCTION add_to_matching_queue()
RETURNS TRIGGER AS $$
BEGIN
    -- Add new member to queue
    IF TG_TABLE_NAME = 'member_profiles' THEN
        INSERT INTO matching_queue (user_id, user_type, priority, status)
        VALUES (NEW.user_id, 'member', 7, 'pending');
    END IF;
    
    -- Add new place to queue
    IF TG_TABLE_NAME = 'place_profiles' THEN
        INSERT INTO matching_queue (user_id, user_type, priority, status)
        VALUES (NEW.user_id, 'place', 7, 'pending');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for member profiles
CREATE TRIGGER trg_member_profile_matching_queue
    AFTER INSERT ON member_profiles
    FOR EACH ROW
    EXECUTE FUNCTION add_to_matching_queue();

-- Create trigger for place profiles  
CREATE TRIGGER trg_place_profile_matching_queue
    AFTER INSERT ON place_profiles
    FOR EACH ROW
    EXECUTE FUNCTION add_to_matching_queue();

-- Function to re-queue user when profile is significantly updated
CREATE OR REPLACE FUNCTION requeue_on_profile_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if significant fields changed for member profiles
    IF TG_TABLE_NAME = 'member_profiles' THEN
        IF (OLD.desired_pay_amount != NEW.desired_pay_amount OR
            OLD.desired_working_days != NEW.desired_working_days OR
            OLD.experience_level != NEW.experience_level) THEN
            
            INSERT INTO matching_queue (user_id, user_type, priority, status)
            VALUES (NEW.user_id, 'member', 6, 'pending');
        END IF;
    END IF;
    
    -- Check if significant fields changed for place profiles
    IF TG_TABLE_NAME = 'place_profiles' THEN
        IF (OLD.offered_min_pay != NEW.offered_min_pay OR
            OLD.offered_max_pay != NEW.offered_max_pay OR
            OLD.desired_experience_level != NEW.desired_experience_level) THEN
            
            INSERT INTO matching_queue (user_id, user_type, priority, status)
            VALUES (NEW.user_id, 'place', 6, 'pending');
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create update triggers for re-queuing
CREATE TRIGGER trg_member_profile_requeue
    AFTER UPDATE ON member_profiles
    FOR EACH ROW
    EXECUTE FUNCTION requeue_on_profile_update();

CREATE TRIGGER trg_place_profile_requeue
    AFTER UPDATE ON place_profiles
    FOR EACH ROW
    EXECUTE FUNCTION requeue_on_profile_update();
