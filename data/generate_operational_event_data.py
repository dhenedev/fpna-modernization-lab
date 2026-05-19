import csv
import random
from pathlib import Path
from datetime import date, timedelta

OUTPUT_DIR = Path(__file__).parent / "synthetic"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

random.seed(84)

REGIONS = ["Northwest", "Southwest", "Central", "Northeast", "Southeast"]

EVENT_TYPES = [
    "invoice_processed",
    "refund_issued",
    "work_order_completed",
    "forecast_adjusted",
    "vendor_onboarded",
    "asset_maintenance_completed",
]

DOMAIN_BY_EVENT = {
    "invoice_processed": "Finance",
    "refund_issued": "Finance",
    "work_order_completed": "Operations",
    "forecast_adjusted": "FP&A",
    "vendor_onboarded": "Vendor Governance",
    "asset_maintenance_completed": "Asset Management",
}

STATUS_OPTIONS = ["Completed", "Open", "Delayed", "Reversed"]


def risk_level_from_impact(hours, cost):
    if hours >= 8 or cost >= 50000:
        return "High"
    if hours >= 4 or cost >= 15000:
        return "Medium"
    return "Low"


def seasonal_multiplier(month):
    if month in [11, 12]:
        return 1.25
    if month in [1, 2]:
        return 0.9
    if month in [6, 7, 8]:
        return 1.15
    return 1.0


def event_weight(event_type, event_date):
    base = {
        "invoice_processed": 40,
        "refund_issued": 12,
        "work_order_completed": 25,
        "forecast_adjusted": 6,
        "vendor_onboarded": 4,
        "asset_maintenance_completed": 13,
    }[event_type]

    # Simulate refund pressure emerging in the most recent year
    if event_type == "refund_issued" and event_date.year == date.today().year:
        base *= 1.5

    # Simulate operational scale growth over time
    years_ago = date.today().year - event_date.year
    growth_factor = max(0.75, 1.25 - (years_ago * 0.12))

    return base * growth_factor * seasonal_multiplier(event_date.month)


def generate_operational_events(days=365 * 4):
    rows = []
    start_date = date.today() - timedelta(days=days)

    event_id = 1

    for day_offset in range(days):
        event_date = start_date + timedelta(days=day_offset)

        # Daily volume changes with seasonality and occasional volatility
        daily_base = random.randint(8, 20)
        if event_date.month in [11, 12, 6, 7, 8]:
            daily_base += random.randint(3, 8)

        # Inject occasional disruption / surge days
        if random.random() < 0.04:
            daily_base += random.randint(10, 25)

        weighted_events = []
        for event_type in EVENT_TYPES:
            weighted_events.extend([event_type] * int(event_weight(event_type, event_date)))

        for _ in range(daily_base):
            event_type = random.choice(weighted_events)
            region = random.choice(REGIONS)

            if event_type == "invoice_processed":
                operational_cost = round(random.uniform(100, 2500), 2)
                revenue_impact = round(random.uniform(2500, 85000), 2)
                impact_hours = round(random.uniform(0.1, 1.5), 1)

            elif event_type == "refund_issued":
                operational_cost = round(random.uniform(250, 6000), 2)
                revenue_impact = round(random.uniform(-25000, -500), 2)
                impact_hours = round(random.uniform(0.5, 6.0), 1)

            elif event_type == "work_order_completed":
                operational_cost = round(random.uniform(500, 30000), 2)
                revenue_impact = 0
                impact_hours = round(random.uniform(1.0, 10.0), 1)

            elif event_type == "forecast_adjusted":
                operational_cost = round(random.uniform(50, 1000), 2)
                revenue_impact = round(random.uniform(-10000, 10000), 2)
                impact_hours = round(random.uniform(0.2, 2.0), 1)

            elif event_type == "vendor_onboarded":
                operational_cost = round(random.uniform(1000, 12000), 2)
                revenue_impact = 0
                impact_hours = round(random.uniform(1.0, 5.0), 1)

            else:  # asset_maintenance_completed
                operational_cost = round(random.uniform(2000, 45000), 2)
                revenue_impact = 0
                impact_hours = round(random.uniform(1.0, 12.0), 1)

            # Add recent-year cost inflation / acceleration
            if event_date.year == date.today().year:
                operational_cost = round(operational_cost * random.uniform(1.05, 1.25), 2)

            governance_risk_level = risk_level_from_impact(impact_hours, operational_cost)

            # More delays/reversals during medium/high risk
            if governance_risk_level == "High":
                status = random.choices(STATUS_OPTIONS, weights=[65, 10, 20, 5])[0]
            elif governance_risk_level == "Medium":
                status = random.choices(STATUS_OPTIONS, weights=[78, 8, 10, 4])[0]
            else:
                status = random.choices(STATUS_OPTIONS, weights=[90, 5, 3, 2])[0]

            rows.append({
                "event_id": f"EVT{event_id:07}",
                "event_timestamp": str(event_date),
                "event_type": event_type,
                "business_domain": DOMAIN_BY_EVENT[event_type],
                "region": region,
                "related_entity_id": f"ENT{random.randint(1, 99999):05}",
                "operational_cost": operational_cost,
                "revenue_impact": revenue_impact,
                "governance_risk_level": governance_risk_level,
                "business_impact_hours": impact_hours,
                "event_status": status,
            })

            event_id += 1

    return rows


def write_csv(filename, rows):
    if not rows:
        return

    path = OUTPUT_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"Created {path} with {len(rows)} rows")


def main():
    rows = generate_operational_events()
    write_csv("operational_events.csv", rows)


if __name__ == "__main__":
    main()