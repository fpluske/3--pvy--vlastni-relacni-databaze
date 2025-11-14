"""
Generátor falešných dat podle SQL schématu v projektu.

Vytváří data pro tabulky: `users`, `categories`, `products`, `orders`, `reviews`, `cart_item`
a ukládá je jako SQL INSERT dump.
"""
from faker import Faker
import random
from datetime import datetime, timedelta
import hashlib

fake = Faker("cs_CZ")
random.seed(42)

# Počty záznamů
NUM_USERS = 50
NUM_CATEGORIES = 8
NUM_PRODUCTS = 60
NUM_ORDERS = 80
NUM_CART_ITEMS = 200
NUM_REVIEWS = 120

def rand_datetime_within_year():
    start = datetime.now() - timedelta(days=365)
    end = datetime.now()
    return fake.date_time_between(start_date=start, end_date=end)

def sql_quote(value):
    if value is None:
        return 'NULL'
    if isinstance(value, bool):
        return '1' if value else '0'
    if isinstance(value, (int, float)):
        # Floats need to be formatted with dot as decimal separator
        if isinstance(value, float):
            return f"{value:.2f}"
        return str(value)
    # Escape single quotes in strings
    s = str(value).replace("'", "''")
    return f"'{s}'"

# Users
users = []
for i in range(1, NUM_USERS + 1):
    first = fake.first_name()
    last = fake.last_name()
    email = fake.unique.email()
    # Simple password hash placeholder
    pw = hashlib.sha256(fake.password(length=10).encode('utf-8')).hexdigest()
    phone = fake.phone_number()
    created = rand_datetime_within_year().strftime('%Y-%m-%d %H:%M:%S')
    is_admin = True if random.random() < 0.05 else False
    users.append((i, first, last, email, pw, phone, created, is_admin))

# Electronics-themed categories (fixed list)
elec_categories = [
    'Smartphony',
    'Notebooky',
    'Televizory',
    'Audio',
    'Doplňky',
    'Nositelná elektronika',
    'Fototechnika',
    'Komponenty'
]

categories = []
for i, cname in enumerate(elec_categories, start=1):
    desc = f"{cname} a příslušenství: " + fake.sentence(nb_words=8)
    parent_id = None
    # malé šance na podkategorizaci
    if i > 1 and random.random() < 0.2:
        parent_id = random.randint(1, i - 1)
    categories.append((i, cname, desc, parent_id))

# Electronics-themed products
brands = [
    'Samsung', 'Apple', 'Sony', 'LG', 'Panasonic', 'Xiaomi', 'Asus', 'Dell', 'HP',
    'Bose', 'JBL', 'Canon', 'Nikon', 'Intel', 'AMD', 'Nvidia', 'Microsoft'
]

# price ranges by category (CZK)
price_ranges = {
    'Smartphony': (5000, 40000),
    'Notebooky': (8000, 80000),
    'Televizory': (6000, 150000),
    'Audio': (500, 30000),
    'Doplňky': (100, 5000),
    'Nositelná elektronika': (1000, 20000),
    'Fototechnika': (4000, 200000),
    'Komponenty': (200, 50000),
}

products = []
for i in range(1, NUM_PRODUCTS + 1):
    cat_entry = random.choice(categories)
    cat = cat_entry[0]
    cat_name = cat_entry[1]
    brand = random.choice(brands)
    # model code like A12-345
    model = fake.bothify(text='?##-###', letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    name = f"{brand} {model}"
    # description with a few specs
    spec = f"{random.choice(['8GB','16GB','32GB','64GB','128GB'])} RAM, {random.choice(['256GB','512GB','1TB','2TB'])} storage"
    desc = f"{name} — {spec}. " + fake.sentence(nb_words=10)
    pr_min, pr_max = price_ranges.get(cat_name, (100, 5000))
    price = round(random.uniform(pr_min, pr_max), 2)
    stock = random.randint(0, 300)
    img = f"https://example.com/images/{i}.jpg"
    created = rand_datetime_within_year().strftime('%Y-%m-%d %H:%M:%S')
    products.append((i, cat, name, desc, price, stock, brand, img, created))

# Orders
order_statuses = ['created', 'pending', 'processing', 'shipped', 'delivered', 'cancelled']
orders = []
for i in range(1, NUM_ORDERS + 1):
    user_id = random.choice(users)[0]
    order_date = rand_datetime_within_year().strftime('%Y-%m-%d %H:%M:%S')
    status = random.choice(order_statuses)
    # total_price set to 0 for now, will compute after cart items generation
    total_price = 0.0
    shipping = fake.address()
    billing = fake.address()
    orders.append([i, user_id, order_date, status, total_price, shipping, billing])

# Cart items (items per order)
cart_items = []
for cid in range(1, NUM_CART_ITEMS + 1):
    order = random.choice(orders)
    order_id = order[0]
    prod = random.choice(products)
    prod_id = prod[0]
    quantity = random.randint(1, 5)
    cart_items.append((cid, order_id, prod_id, quantity))
    # update order total
    order[4] += prod[4] * quantity

# Finalize totals (formatting)
for o in orders:
    o[4] = round(o[4], 2)

# Reviews
reviews = []
for i in range(1, NUM_REVIEWS + 1):
    prod_id = random.choice(products)[0]
    user_id = random.choice(users)[0]
    rating = random.randint(1, 5)
    comment = fake.sentence(nb_words=12)
    created_at = rand_datetime_within_year().strftime('%Y-%m-%d %H:%M:%S')
    reviews.append((i, prod_id, user_id, rating, comment, created_at))

# Připravit SQL INSERT příkazy
sql_lines = []

def insert_lines(table, columns, rows):
    sql_lines.append(f"-- {table}")
    cols = ', '.join(columns)
    for row in rows:
        values = ', '.join(sql_quote(v) for v in row)
        sql_lines.append(f"INSERT INTO {table} ({cols}) VALUES ({values});")
    sql_lines.append("")

# Vložíme data v pořadí, které respektuje FK
insert_lines('users', ['id_user','first_name','last_name','email','password_hash','phone','created_at','is_admin'], users)
insert_lines('categories', ['id_category','name','description','parent_id'], categories)
insert_lines('products', ['id_product','id_category','name','description','price','stock','brand','img','created_at'], products)

# orders: total_price computed above
insert_lines('orders', ['id_order','id_user','order_date','status','total_price','shipping_address','billing_address'], orders)

# reviews: note SQL schema has column name `id_priduct` (typo), we follow schema
insert_lines('reviews', ['id_review','id_priduct','id_user','rating','comment','created_at'], reviews)

# cart_item: schema uses `id_cart`, `id_order`, `id_priduct`, `quantity`
insert_lines('cart_item', ['id_cart','id_order','id_priduct','quantity'], cart_items)

dump_path = 'random-zaznamy.sql'
with open(dump_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines))

print(f'SQL dump uložen do: {dump_path}')
