# Restaurant Data Analysis Pipeline (V Fusion)

An end-to-end data analytics and business intelligence project automating a restaurant's operational data pipeline. This repository demonstrates how raw restaurant transactional records are ingested via an ETL process, modeled in a relational database ecosystem, and transformed into an interactive management dashboard using advanced DAX metrics.

---

## 📊 Dashboard Insights & Core Metrics

The data pipeline extracts critical operational and customer behavioral insights from the **V Fusion Fine Dine Restaurant** dataset:

### 1. High-Level Performance Indicators (KPIs)
* **Total Revenue Generated:** ₹1.69M
* **Total Customer Base:** 4.26K unique visitors
* **Total Product Volume:** 10.59K total food quantities sold

### 2. Customer Segmentation & Value Split (Behavioral Analytics)
* **Revenue Breakdown:** 
  * **Repeated Customers:** Generates **₹1.06M (62.75%)** of total revenue.
  * **Once Visited Customers:** Generates **₹0.63M (37.25%)** of total revenue.
* **Customer Distribution Volumetrics:**
  * **Repeated Customers:** Represents **2.66K (62.44%)** of the customer cohort.
  * **Once Visited Customers:** Represents **1.60K (37.56%)** of the active customer cohort.
  * *Business Insight: While first-time visitors bring the bulk of immediate sales, the retained 37.56% repeat user base provides a strong foundation for predictable recurring income.*

### 3. Menu Performance & Product Engineering
* **Top 10 Food Items Sold (Total Price Contribution):** Highly dominated by **North Indian Noodles (₹18.2K)** and **Spicy Kebab (₹18.2K)**, closely followed by *Crispy Ice Cream* (₹17.3K) and *Garlic Fried Rice* (₹16.6K).
* **Retention Drivers (Top Items by Repeat Customers):** Interestingly, **Garlic Kebab (₹1.9K)** and **Sweet Noodles (₹1.6K)**, closely followed by *North Indian Noodles* (₹1.5K).

### 4. Granular Auditing & Transaction Volume
* **Order Frequency Tracking:** Tracks individual client metrics displaying an active cluster of high-frequency consumers (e.g., Anil Goud, Anil Kumar, Anil Naidu cohorts) averaging **6 total orders** each, pushing the collective dataset order counter to **4,260 orders**.
* **Bulk Volume Buyers:** Tracks intensive bulk consumer consumption led by high-quantity patrons such as *Prasad Rao 29* (**22 quantities purchased**), *Satish Teja 4* (**21**), and *Suresh Kumar 75* (**21**), accumulating a total baseline calculation of **10,594 item items purchased**.

---

## 🛠️ Tech Stack & Analytical Ecosystem

* **Relational Database Server:** Microsoft SQL Server (SSMS) for structuring, clearing data integrity gaps, and testing optimization constraints.
* **Business Intelligence Tool:** Power BI Desktop for star-schema relational data modeling and interface rendering.
* **Data Extraction & Ingestion (ETL):** Automated processing pipelines handling Microsoft Excel worksheets and raw tabular CSV data matrices.
