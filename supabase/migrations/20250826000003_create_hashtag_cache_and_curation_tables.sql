-- Create the cache table for trending hashtags
CREATE TABLE public.trending_hashtags_cache (
    cache_key TEXT PRIMARY KEY,
    hashtags JSONB NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Add comments to the table and columns
COMMENT ON TABLE public.trending_hashtags_cache IS 'Cache for trending hashtags to reduce load on the main RPC.';
COMMENT ON COLUMN public.trending_hashtags_cache.cache_key IS 'The key for the cache entry, e.g., ''current_trending''.';
COMMENT ON COLUMN public.trending_hashtags_cache.hashtags IS 'A JSONB array of hashtag objects.';
COMMENT ON COLUMN public.trending_hashtags_cache.expires_at IS 'The timestamp when the cache entry expires.';


-- Create the table for daily hashtag curation
CREATE TABLE public.daily_hashtag_curation (
    curation_date DATE PRIMARY KEY,
    trending_hashtags JSONB,
    ai_suggestions JSONB,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Add comments to the table and columns
COMMENT ON TABLE public.daily_hashtag_curation IS 'Stores daily curated hashtags, including trending and AI-suggested ones.';
COMMENT ON COLUMN public.daily_hashtag_curation.curation_date IS 'The date of the curation, serves as the primary key.';
COMMENT ON COLUMN public.daily_hashtag_curation.trending_hashtags IS 'A JSONB array of trending hashtag objects for the day.';
COMMENT ON COLUMN public.daily_hashtag_curation.ai_suggestions IS 'A JSONB array of AI-suggested hashtags for the day.';

-- Optional: Add a trigger to update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_daily_hashtag_curation_updated_at
BEFORE UPDATE ON public.daily_hashtag_curation
FOR EACH ROW
EXECUTE FUNCTION public.set_current_timestamp_updated_at();
