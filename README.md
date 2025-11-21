**Vlastní Relační Databáze**

Krátký popis a zdroje pro projekt schématu databáze.

- **dbdiagram:** https://dbdiagram.io/d/Vlastni-relacni-databaze-690dc4eb6735e11170b71c00
- **Obrázek schématu:**

<img width="1113" height="682" alt="Vlastní relační databáze" src="https://github.com/user-attachments/assets/a42cd656-c1bc-4db3-b04b-8f008ddc333a" />

Instrukce pro generování demo dat (skript se nachází v `scripts/faker_data.py`):

- Nainstalujte závislosti:

```powershell
pip install -r requirements.txt
```

- Spusťte generátor:

```powershell
python .\scripts\faker_data.py
```

Po spuštění bude v kořeni projektu vytvořen SQL dump (`random-zaznamy.sql`), který obsahuje INSERT příkazy podle schématu.

Poznámky:
- Skript generuje data v češtině pomocí `Faker`.
- Pokud chcete upravit téma (např. jiné kategorie nebo počty záznamů), otevřete `scripts/faker_data.py` a změňte proměnné `NUM_*` nebo sekce pro generování kategorií/produktů.

**Popis databáze**

Tato databáze je navržena pro jednoduchý e‑shop (produkty, kategorie, uživatelé, objednávky, recenze a položky objednávek). Níže je stručný přehled tabulek, klíčů a vazeb.

- **users**: uchovává registrované uživatele.
	- Hlavní sloupce: `id_user` (PK), `first_name`, `last_name`, `email` (UNIQUE), `password_hash`, `phone`, `created_at`, `is_admin`.

- **categories**: stromová struktura kategorií (možno mít `parent_id`).
	- Hlavní sloupce: `id_category` (PK), `name`, `description`, `parent_id` (FK -> `categories.id_category`, ON DELETE SET NULL).

- **products**: produkty patří do kategorie.
	- Hlavní sloupce: `id_product` (PK), `id_category` (FK -> `categories`), `name`, `description`, `price`, `stock`, `brand`, `img`, `created_at`.

- **orders**: objednávky vytvořené uživateli.
	- Hlavní sloupce: `id_order` (PK), `id_user` (FK -> `users`), `order_date`, `status` (ENUM), `total_price`, `shipping_address`, `billing_address`.

- **order_items** (nebo `cart_item` ve starší verzi): položky v objednávce.
	- Hlavní sloupce: `id_order` (PK část), `id_product` (PK část, FK -> `products`), `quantity`, `price_at_order`.
	- Použito kompozitní PK (`id_order`, `id_product`) aby se zabránilo duplicitním položkám; položky jsou kaskádově smazány při smazání objednávky.

- **reviews**: recenze produktů uživateli.
	- Hlavní sloupce: `id_review` (PK), `id_product` (FK -> `products`), `id_user` (FK -> `users`), `rating` (CHECK 1–5), `comment`, `created_at`.
