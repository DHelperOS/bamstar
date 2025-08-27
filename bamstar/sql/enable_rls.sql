-- Enable RLS on member tables
ALTER TABLE public.attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_attributes_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_preferences_link ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_preferred_area_groups ENABLE ROW LEVEL SECURITY;