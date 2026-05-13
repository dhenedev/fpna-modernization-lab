import csv
import random
from pathlib import Path
from datetime import date, timedelta

OUTPUT_DIR = Path(__file__).parent / "synthetic"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

random.seed(42)

REGIONS = ["Northwest", "Southwest", "Central", "Northeast", "Southeast"]
VENDOR_CATEGORIES = ["Field Services", "Materials", "Equipment", "Technology", "Professional Services", ""]
PAYMENT_TERMS = ["Net 30", "Net 45", "Net 60"]
GL_ACCOUNTS = ["5000", "5100", "5200", "5300", "5400", "9999"]  # 9999 intentionally invalid
ASSET_TYPES = ["Substation", "Transformer", "Pipeline", "Control System", "Transmission Line"]
STATUSES = ["Open", "In Progress", "Complete", "Closed", "Delayed", "Done"]  # Done intentionally inconsistent


def write_csv(filename, rows):
    if not rows:
        return

    path = OUTPUT_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"Created {path}")


def generate_vendors():
    vendors = []
    base_names = [
        "Cascade Field Services",
        "Summit Utility Supply",
        "Evergreen Equipment Co",
        "Northline Consulting",
        "Pioneer Controls",
        "BlueRiver Materials",
        "Atlas Infrastructure",
        "Harbor Safety Group",
    ]

    for i, name in enumerate(base_names, start=1):
        vendors.append({
            "vendor_id": f"V{i:03}",
            "vendor_name": name,
            "parent_vendor": name if random.random() > 0.2 else "",
            "vendor_category": random.choice(VENDOR_CATEGORIES),
            "payment_terms": random.choice(PAYMENT_TERMS),
            "region": random.choice(REGIONS),
        })

    # Intentional duplicate / naming variation
    vendors.append({
        "vendor_id": "V009",
        "vendor_name": "Cascade Field Svcs",
        "parent_vendor": "Cascade Field Services",
        "vendor_category": "Field Services",
        "payment_terms": "Net 30",
        "region": "Northwest",
    })

    return vendors


def generate_gl_accounts():
    return [
        {"gl_account": "5000", "gl_category": "Labor", "financial_statement_line": "Cost of Services"},
        {"gl_account": "5100", "gl_category": "Materials", "financial_statement_line": "Cost of Services"},
        {"gl_account": "5200", "gl_category": "Equipment", "financial_statement_line": "Operating Expense"},
        {"gl_account": "5300", "gl_category": "Technology", "financial_statement_line": "Operating Expense"},
        {"gl_account": "5400", "gl_category": "Professional Services", "financial_statement_line": "Operating Expense"},
    ]


def generate_assets(count=40):
    assets = []
    for i in range(1, count + 1):
        assets.append({
            "asset_id": f"A{i:04}",
            "asset_type": random.choice(ASSET_TYPES),
            "region": random.choice(REGIONS),
            "maintenance_status": random.choice(["Current", "Due", "Overdue", ""]),
            "replacement_risk": random.choice(["Low", "Medium", "High"]),
            "last_inspection_date": str(date.today() - timedelta(days=random.randint(10, 500))),
        })
    return assets


def generate_employees(count=30):
    employees = []
    departments = ["Finance", "Field Operations", "Asset Management", "Executive", "Operations"]

    for i in range(1, count + 1):
        employees.append({
            "employee_id": f"E{i:04}",
            "department": random.choice(departments + ["Ops"]),  # Ops intentionally inconsistent
            "region": random.choice(REGIONS),
            "utilization_rate": round(random.uniform(0.45, 1.25), 2),  # >1.0 intentionally possible
            "manager_id": "" if random.random() < 0.15 else f"E{random.randint(1, 5):04}",
        })

    return employees


def generate_invoices(vendors, count=120):
    invoices = []

    for i in range(1, count + 1):
        vendor = random.choice(vendors)
        invoice_id = f"INV{i:05}"

        # Intentional duplicate invoice ID
        if i == 75:
            invoice_id = "INV00020"

        invoices.append({
            "invoice_id": invoice_id,
            "vendor_id": vendor["vendor_id"],
            "invoice_type": random.choice(["AP", "AR"]),
            "invoice_date": str(date.today() - timedelta(days=random.randint(1, 180))),
            "amount": round(random.uniform(500, 75000), 2),
            "gl_account": random.choice(GL_ACCOUNTS),
            "payment_status": random.choice(["Paid", "Pending", "Overdue", ""]),
            "region": random.choice(REGIONS),
        })

    return invoices


def generate_work_orders(assets, employees, count=100):
    work_orders = []

    for i in range(1, count + 1):
        work_orders.append({
            "work_order_id": f"WO{i:05}",
            "asset_id": random.choice(assets)["asset_id"],
            "employee_id": random.choice(employees)["employee_id"],
            "assigned_region": random.choice(REGIONS),
            "completion_status": random.choice(STATUSES),
            "response_time_hours": round(random.uniform(1, 96), 1),
            "operational_cost": round(random.uniform(250, 25000), 2),
            "last_updated_date": str(date.today() - timedelta(days=random.randint(1, 120))),
        })

    return work_orders


def generate_forecast(count=60):
    rows = []

    for i in range(1, count + 1):
        forecast_amount = round(random.uniform(25000, 250000), 2)
        variance_factor = random.uniform(0.65, 1.45)

        rows.append({
            "forecast_id": f"F{i:04}",
            "period": f"2026-{random.randint(1, 12):02}",
            "region": random.choice(REGIONS),
            "gl_account": random.choice(GL_ACCOUNTS),
            "forecast_amount": forecast_amount,
            "actual_amount": round(forecast_amount * variance_factor, 2),
        })

    return rows


def main():
    vendors = generate_vendors()
    gl_accounts = generate_gl_accounts()
    assets = generate_assets()
    employees = generate_employees()
    invoices = generate_invoices(vendors)
    work_orders = generate_work_orders(assets, employees)
    forecast = generate_forecast()

    write_csv("vendors.csv", vendors)
    write_csv("gl_accounts.csv", gl_accounts)
    write_csv("assets.csv", assets)
    write_csv("employees.csv", employees)
    write_csv("invoices.csv", invoices)
    write_csv("work_orders.csv", work_orders)
    write_csv("forecast.csv", forecast)


if __name__ == "__main__":
    main()