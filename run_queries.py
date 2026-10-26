"""Run every file in sql/queries/, print the first rows, and save full results to results/*.csv.

  python run_queries.py
"""
import csv, pathlib, sqlite3

con = sqlite3.connect("sales.db")
pathlib.Path("results").mkdir(exist_ok=True)
for q in sorted(pathlib.Path("sql/queries").glob("*.sql")):
    cur = con.execute(q.read_text())
    cols = [c[0] for c in cur.description]
    rows = cur.fetchall()
    with open(f"results/{q.stem}.csv", "w", newline="") as f:
        w = csv.writer(f); w.writerow(cols); w.writerows(rows)
    print(f"\n== {q.stem} ({len(rows)} rows) ==")
    print(" | ".join(cols))
    for r in rows[:8]:
        print(" | ".join(str(round(v, 2)) if isinstance(v, float) else str(v) for v in r))
