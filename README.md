# 🍽️ Restaurant Order Analysis — SQL Project

![SQL](https://img.shields.io/badge/SQL-MySQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-brightgreen) ![Dataset](https://img.shields.io/badge/Dataset-Maven%20Analytics-orange)

## 📌 Project Overview

This project analyses a relational restaurant database containing menu item and order transaction data from a fictional international restaurant. The goal was to uncover actionable insights about menu performance, customer ordering patterns, and revenue drivers — demonstrating practical SQL skills including joins, aggregations, subqueries, and CTEs.

---

## 🎯 Goals

| # | Goal | Focus |
|---|------|-------|
| 1 | **Menu Intelligence** | Understand what is on the menu, how it is priced, and which items customers choose most |
| 2 | **Order Behaviour** | Analyse the volume, frequency, and size of orders over the trading period |
| 3 | **Revenue Drivers** | Identify the highest-value orders and the items that generate the most revenue |
| 4 | **Operational Insight** | Identify peak trading hours and where revenue is concentrated across the day |

---

## 🗂️ Dataset

The dataset was sourced from **Maven Analytics** and contains simulated restaurant order transactions from Q1 2023.

| Table | Records | Key Fields |
|-------|---------|------------|
| `menu_items` | 32 items | menu_item_id, item_name, category, price |
| `order_details` | 12,234 records | order_details_id, order_id, order_date, order_time, item_id |

**Date Range:** January 1, 2023 — March 31, 2023 (89 days)

> **Data Quality Note:** 137 order lines had NULL item IDs and could not be traced back to any menu item. An INNER JOIN was applied to exclude these records, retaining 12,097 valid transactions for analysis.

---

## 🛠️ Tools & Technologies

- **Database:** MySQL
- **IDE:** DataGrip
- **Version Control:** GitHub

---

## 📊 Key Findings

### 🥇 Menu Intelligence
- The menu spans **4 cuisine categories** — American, Asian, Italian, and Mexican — with prices ranging from **$5.00 to $19.95**
- **Italian** is the premium category with the highest average price ($16.75) and the most expensive item — Shrimp Scampi at $19.95
- **American** is the most affordable on average ($10.07), contributing to its dominance in order volume
- The **Hamburger** (American) was the most ordered item with **622 orders**; **Chicken Tacos** (Mexican) was the least ordered at just **123 orders**

### 📦 Order Behaviour
- **5,370 unique orders** were placed across the 89-day trading period (~60 orders/day)
- Average order size was **2.25 items per order**
- Order **#330** had the most items in a single order at **14 items**
- Only **20 orders** exceeded 12 items — less than 0.4% of all orders, yet representing high-value group dining events

### 💰 Revenue Drivers
- The **top 5 orders** each spent between **$185–$192**, all containing 13–14 items
- **Order #440** was the highest spend at **$192.15**, with 6 of its 14 items being Italian dishes
- Italian cuisine consistently dominates high-spend orders, confirming its role as the restaurant's primary revenue driver

### ⏰ Operational Insight
- Peak traffic was concentrated in the **Lunch (12:00–14:59)** and **Dinner (18:00–20:59)** windows
- **Dinner** generated the highest total revenue, largely driven by Italian dish selections
- The **Afternoon (15:00–17:59)** recorded the lowest traffic across all time bins

---

## 💡 Recommendations

1. **Double down on Italian during Dinner service** — Italian dominates both the highest-spend orders and the peak revenue window. Dinner set menus or group dining packages during 18:00–20:59 could significantly increase average order value.

2. **Investigate Chicken Tacos underperformance** — despite Mexican having the most menu variety (9 dishes), Chicken Tacos recorded the lowest order count at 123. A pricing review or menu repositioning could recover lost volume.

3. **Convert the Afternoon slump into revenue** — the 15:00–17:59 window recorded the lowest traffic across the entire trading period. A targeted happy hour or discounted set menu could turn a dead period into an additional revenue stream.

4. **Fix the 137 NULL item IDs at source** — these missing records mean every analysis is working with incomplete data. Addressing the logging error at point-of-sale level will ensure future analyses capture the full picture.

---

## 📁 Project Structure

```
restaurant-order-analysis/
│
├── data/
│   ├── menu_items.csv
│   └── order_details.csv
│
├── queries/
│   └── restaurant_analysis.sql
│
├── presentation/
│   └── Restaurant_Order_Analysis.pdf
│
└── README.md
```

---

## 🚀 How to Run

1. Clone this repository
```bash
git clone https://github.com/yourusername/restaurant-order-analysis.git
```

2. Create the database and import the data
```sql
CREATE DATABASE restaurant_db;
USE restaurant_db;
```

3. Import `menu_items.csv` and `order_details.csv` into their respective tables

4. Run the queries in `queries/restaurant_analysis.sql`
