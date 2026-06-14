import csv
import random
import os
import sys

NUM_ROWS = 50

COLUMNS = ["student_id", "age", "exam_score", "grade"]

def generate_row():
    return {
        "student_id": random.randint(1000, 9999),
        "age": random.randint(18, 35),
        "exam_score": round(random.uniform(50.0, 100.0), 1),
        "grade": random.choice(["A", "B", "C", "D", "F"]),
    }

OUTPUT_DIR = sys.argv[1] if len(sys.argv) > 1 else "/data"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "data.csv")

os.makedirs(OUTPUT_DIR, exist_ok=True)

rows = [generate_row() for _ in range(NUM_ROWS)]

with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(rows)

print(f"Generated {NUM_ROWS} rows in {OUTPUT_FILE}")
