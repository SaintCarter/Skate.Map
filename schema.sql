-- =================================================================================== --
-- SQL schema for Skate.Map
-- =================================================================================== --
-- =================================================================================== --
-- EXTENSIONS
-- =================================================================================== --
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- =================================================================================== --
-- USERS
-- =================================================================================== --
CREATE TABLE user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(128) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    has_security_question BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- =================================================================================== --
-- SPOTS
-- =================================================================================== --
CREATE TABLE spot (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID REFERENCES user(id) ON DELETE SET NULL,
    spot_location GEOGRAPHY(Point, 4326) NOT NULL,
    spot_name VARCHAR(128) NOT NULL,
    is_street BOOLEAN NOT NULL,
    main_photo_url TEXT NOT NULL,
    terrain_rating INT CHECK (terrain_rating IN (1, 2, 3)),
    visibility_rating INT CHECK (visibility_rating IN (1, 2, 3)),
    pedestrian_rating INT CHECK (pedestrian_rating IN (1, 2, 3)),
    is_illegal BOOLEAN,
    admin_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_spots_geo ON spot USING GIST (spot_location);
    
-- =================================================================================== --
-- FEATURES
-- =================================================================================== --

CREATE TABLE feature (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_name VARCHAR(64) UNIQUE NOT NULL,
);

CREATE TABLE spot_feature (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    spot_id UUID REFERENCES spot(id) ON DELETE CASCADE,
    feature_id UUID REFERENCES feature(id) ON DELETE CASCADE,
    feature_photo TEXT NOT NULL
);

CREATE TABLE spot_has_rating (
    spot_id UUID REFERENCES spot(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user(id) ON DELETE CASCADE,
    rating SMALLINT,
    PRIMARY KEY (spot_id, user_id)
);
-- =================================================================================== --
-- POSTS
-- =================================================================================== --
CREATE TABLE post (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    spot_id UUID REFERENCES spot(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type TEXT NOT NULL,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- =================================================================================== --
-- USER INTERACTIONS
-- =================================================================================== --
CREATE TABLE user_likes_post (
    post_id UUID REFERENCES post(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE user_favourites_post (
    post_id UUID REFERENCES post(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE user_follows_user (
    follower_id UUID REFERENCES user(id) ON DELETE CASCADE,
    following_id UUID REFERENCES user(id) ON DELETE CASCADE,
    PRIMARY KEY (follower_id, following_id)
);

CREATE TABLE user_visits_spots (
    spot_id UUID REFERENCES spot(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user(id) ON DELETE CASCADE,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (spot_id, user_id)
);