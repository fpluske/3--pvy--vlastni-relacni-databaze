CREATE TABLE `users` (
  `id_user` integer PRIMARY KEY AUTO_INCREMENT,
  `first_name` varchar(50),
  `last_name` varchar(50),
  `email` text UNIQUE,
  `password_hash` text,
  `phone` varchar(14) DEFAULT 420,
  `created_at` datetime DEFAULT (now()),
  `is_admin` bool DEFAULT false
);

CREATE TABLE `categories` (
  `id_category` integer PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(50),
  `description` text,
  `parent_id` integer
);

CREATE TABLE `products` (
  `id_product` integer PRIMARY KEY AUTO_INCREMENT,
  `id_category` integer,
  `name` varchar(50),
  `description` text,
  `price` decimal(10,2),
  `stock` integer,
  `brand` varchar(30),
  `img` blob,
  `created_at` datetime DEFAULT (now())
);

CREATE TABLE `orders` (
  `id_order` integer PRIMARY KEY AUTO_INCREMENT,
  `id_user` integer,
  `order_date` datetime DEFAULT (now()),
  `status` ENUM ('created', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'),
  `total_price` decimal(10,2),
  `shipping_address` text,
  `billing_address` text
);

CREATE TABLE `reviews` (
  `id_review` integer PRIMARY KEY AUTO_INCREMENT,
  `id_priduct` integer,
  `id_user` integer,
  `rating` integer,
  `comment` text,
  `created_at` datetime DEFAULT (now())
);

CREATE TABLE `cart_item` (
  `id_cart` integer PRIMARY KEY AUTO_INCREMENT,
  `id_order` integer,
  `id_priduct` integer,
  `quantity` integer
);

ALTER TABLE `categories` ADD FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id_category`);

ALTER TABLE `products` ADD FOREIGN KEY (`id_category`) REFERENCES `categories` (`id_category`);

ALTER TABLE `orders` ADD FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`);

ALTER TABLE `reviews` ADD FOREIGN KEY (`id_priduct`) REFERENCES `products` (`id_product`);

ALTER TABLE `reviews` ADD FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`);

ALTER TABLE `cart_item` ADD FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`);

ALTER TABLE `cart_item` ADD FOREIGN KEY (`id_priduct`) REFERENCES `products` (`id_product`);
