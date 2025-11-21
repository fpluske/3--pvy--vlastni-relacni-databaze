-- Revidované MySQL schema pro "Vlastní relační databáze"
-- Soubor vytvořen automaticky jako kompletní revize původního SQL.
-- Dialekt: MySQL (InnoDB, utf8mb4)

SET SQL_MODE = 'STRICT_TRANS_TABLES';
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables if exist (bezpečné při znovuvytváření testovací DB)
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;

-- Users
CREATE TABLE `users` (
  `id_user` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_admin` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories (hierarchické)
CREATE TABLE `categories` (
  `id_category` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `parent_id` INT DEFAULT NULL,
  PRIMARY KEY (`id_category`),
  KEY `idx_categories_parent` (`parent_id`),
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id_category`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products
CREATE TABLE `products` (
  `id_product` INT NOT NULL AUTO_INCREMENT,
  `id_category` INT DEFAULT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `stock` INT NOT NULL DEFAULT 0,
  `brand` VARCHAR(100) DEFAULT NULL,
  `img` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_product`),
  KEY `idx_products_category` (`id_category`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`id_category`) REFERENCES `categories` (`id_category`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders
CREATE TABLE `orders` (
  `id_order` INT NOT NULL AUTO_INCREMENT,
  `id_user` INT NOT NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('created','pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'created',
  `total_price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `shipping_address` TEXT DEFAULT NULL,
  `billing_address` TEXT DEFAULT NULL,
  PRIMARY KEY (`id_order`),
  KEY `idx_orders_user` (`id_user`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reviews
CREATE TABLE `reviews` (
  `id_review` INT NOT NULL AUTO_INCREMENT,
  `id_product` INT NOT NULL,
  `id_user` INT NOT NULL,
  `rating` TINYINT NOT NULL,
  `comment` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_review`),
  KEY `idx_reviews_product` (`id_product`),
  KEY `idx_reviews_user` (`id_user`),
  CONSTRAINT `chk_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5),
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`id_product`) REFERENCES `products` (`id_product`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order items (položky objednávky) — kompozitní PK
CREATE TABLE `order_items` (
  `id_order` INT NOT NULL,
  `id_product` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `price_at_order` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_order`,`id_product`),
  KEY `idx_order_items_product` (`id_product`),
  CONSTRAINT `chk_order_items_quantity` CHECK (`quantity` >= 1),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`id_product`) REFERENCES `products` (`id_product`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- Konec revidovaného schema
