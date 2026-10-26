"""Create sales.db with SYNTHETIC e-commerce data (fixed seed, reproducible).

  python build_db.py
"""
import datetime as dt, pathlib, random, sqlite3

random.seed(42)
DB = pathlib.Path("sales.db")
if DB.exists():
    DB.unlink()
con = sqlite3.connect(DB)
con.executescript(pathlib.Path("sql/schema.sql").read_text())

countries = ["South Africa", "Nigeria", "Kenya", "France", "Belgium", "DR Congo", "Germany", "Brazil"]
cats = {"Electronics": (30, 400), "Home": (10, 120), "Fitness": (8, 90), "Books": (5, 40), "Beauty": (6, 70)}
first = ["Amara", "Luc", "Naledi", "Jean", "Aisha", "Pedro", "Sofia", "Tendai", "Marie", "Kofi", "Lina", "Omar"]
last = ["Dube", "Mukendi", "Okafor", "Martin", "Silva", "Banda", "Dupont", "Mensah", "Khan", "Kabila"]

start, end = dt.date(2025, 1, 1), dt.date(2026, 9, 30)
span = (end - start).days

customers = []
for cid in range(1, 501):
    signup = start + dt.timedelta(days=random.randint(0, span - 30))
    customers.append((cid, f"{random.choice(first)} {random.choice(last)}",
                      random.choices(countries, weights=[4, 3, 2, 3, 1, 2, 2, 2])[0], signup.isoformat()))
con.executemany("INSERT INTO customers VALUES (?,?,?,?)", customers)

products, pid = [], 1
for cat, (lo, hi) in cats.items():
    for i in range(1, 9):
        products.append((pid, f"{cat} Item {i}", cat, round(random.uniform(lo, hi), 2)))
        pid += 1
con.executemany("INSERT INTO products VALUES (?,?,?,?)", products)

month_weight = {11: 1.8, 12: 2.0, 1: 0.8}
oid, iid, orders, items = 1, 1, [], []
for cid, _, _, signup in customers:
    signup = dt.date.fromisoformat(signup)
    n_orders = min(12, int(random.expovariate(1 / 3.2)) + 1)
    for _ in range(n_orders):
        for _try in range(10):
            d = signup + dt.timedelta(days=int(random.expovariate(1 / 120)))
            if d <= end and random.random() < month_weight.get(d.month, 1.0) / 2.0:
                break
        else:
            continue
        status = random.choices(["completed", "cancelled", "returned"], weights=[88, 7, 5])[0]
        orders.append((oid, cid, d.isoformat(), status))
        for _ in range(random.randint(1, 4)):
            p = random.choice(products)
            items.append((iid, oid, p[0], random.randint(1, 3), random.choice([0, 0, 0, 0.05, 0.1, 0.2])))
            iid += 1
        oid += 1
con.executemany("INSERT INTO orders VALUES (?,?,?,?)", orders)
con.executemany("INSERT INTO order_items VALUES (?,?,?,?,?)", items)
con.commit()
print(f"Built sales.db: {len(customers)} customers, {len(products)} products, {len(orders)} orders, {len(items)} items")
