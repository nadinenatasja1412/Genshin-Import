-- ============================================================
-- Genshin Import — Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS genshin_import;
USE genshin_import;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100)        NOT NULL,
  email       VARCHAR(150)        NOT NULL UNIQUE,
  password    VARCHAR(255),                         -- NULL for OAuth-only accounts
  role        ENUM('admin','user') NOT NULL DEFAULT 'user',
  oauth_provider VARCHAR(50),                       -- 'google', NULL, etc.
  oauth_id    VARCHAR(255),
  created_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Weapons Table
CREATE TABLE IF NOT EXISTS weapons (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(150)        NOT NULL,
  type        ENUM('Sword','Claymore','Polearm','Bow','Catalyst') NOT NULL,
  description TEXT                NOT NULL,
  stock       INT                 NOT NULL DEFAULT 0,
  image_url   VARCHAR(500),
  price       DECIMAL(12,2)       NOT NULL,
  created_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT                 NOT NULL,
  weapon_id   INT                 NOT NULL,
  quantity    INT                 NOT NULL DEFAULT 1,
  total_price DECIMAL(14,2)       NOT NULL,
  status      ENUM('pending','confirmed','cancelled') NOT NULL DEFAULT 'pending',
  ordered_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
  FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
);

-- Cart Items Table
CREATE TABLE IF NOT EXISTS cart_items (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT                 NOT NULL,
  weapon_id   INT                 NOT NULL,
  quantity    INT                 NOT NULL DEFAULT 1,
  created_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_cart_item (user_id, weapon_id),
  FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
  FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
);

-- ============================================================
-- Seed Data
-- ============================================================

-- Admin account  (password: Admin@123)
INSERT INTO users (name, email, password, role) VALUES
  ('GachaMerch Admin', 'admin@gachamerch.com',
   '$2a$12$qiioRbsjC4Fp.0yDCc/v3ueehCQCHU8HB34OVM0.YlufBM.W0jy82', 'admin');

-- Regular user  (password: User@123)
INSERT INTO users (name, email, password, role) VALUES
  ('Traveler', 'traveler@teyvat.com',
   '$2a$12$ErFTdiiOOImcZ2sfF0sTG.Ib1xcWbmytw1Dx782JmBnrQ2rROIzXm', 'user');

-- Weapons
INSERT INTO weapons (name, type, description, stock, image_url, price) VALUES
  ('Primordial Jade Winged-Spear', 'Polearm',
   'A jade polearm forged by the Archons. Its edge is keen enough to cleave the clouds.',
   15, 'https://rerollcdn.com/GENSHIN/Weapons/Primordial_Jade_Winged-Spear.png', 450000.00),

  ('Wolf''s Gravestone', 'Claymore',
   'A longsword that hints of a time when humanity struggled to survive. It was damaged at some point.',
   10, 'https://rerollcdn.com/GENSHIN/Weapons/Wolf%27s_Gravestone.png', 480000.00),

  ('Skyward Harp', 'Bow',
   'A bow that sings of the sky. It has existed since before memory, carried by the wind itself.',
   8,  'https://rerollcdn.com/GENSHIN/Weapons/Skyward_Harp.png', 470000.00),

  ('Lost Prayer to the Sacred Winds', 'Catalyst',
   'An ancient scroll that has recorded the forbidden knowledge of winds. Forbidden, yet longed for.',
   12, 'https://rerollcdn.com/GENSHIN/Weapons/Lost_Prayer_to_the_Sacred_Winds.png', 460000.00),

  ('Aquila Favonia', 'Sword',
   'A sword that once shone like the sun, carrying the blessings of the Anemo Archon.',
   20, 'https://rerollcdn.com/GENSHIN/Weapons/Aquila_Favonia.png', 455000.00),

  ('Summit Shaper', 'Sword',
   'A sharp sword that gathers the might of the mountains. It can split a mountain in twain.',
   6,  'https://rerollcdn.com/GENSHIN/Weapons/Summit_Shaper.png', 440000.00),

  ('Vortex Vanquisher', 'Polearm',
   'A polearm that is as heavy as a mountain and as unyielding as stone.',
   9,  'https://rerollcdn.com/GENSHIN/Weapons/Vortex_Vanquisher.png', 435000.00),

  ('Memory of Dust', 'Catalyst',
   'A treasured keepsake of a couple separated by the Archon War, now a powerful catalyst.',
   7,  'https://rerollcdn.com/GENSHIN/Weapons/Memory_of_Dust.png', 425000.00);
