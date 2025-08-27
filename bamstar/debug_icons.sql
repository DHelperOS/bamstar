-- Check if emojis are properly stored in the database
SELECT id, type, name, icon_name 
FROM public.attributes 
WHERE type = 'INDUSTRY' 
ORDER BY id 
LIMIT 8;

-- Check all types
SELECT type, COUNT(*) as total, COUNT(icon_name) as with_icons
FROM public.attributes 
GROUP BY type
ORDER BY type;