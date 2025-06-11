# Product Sales and Customer Insights SQL Analysis

This project is a comprehensive SQL-based analysis of product sales and customer behavior. The goal is to uncover actionable insights from transactional data, helping business stakeholders understand **which products perform well**, **who their best customers are**, and **how sales evolve over time**.

## Project Objectives

The analysis aims to answer the following key business questions:

1. Which product categories generate the most and least revenue?
2. Does the number of subcategories in a product category influence total revenue?
3. Which products lead in revenue and quantity sold and are they correlated?
4. Which customer segments (country, gender, marital status) contribute most to revenue?
5. What’s the average order value across different customer demographics (age group, country)?
6. Are there seasonal trends in monthly sales performance?

## Key Findings

### 1. Product Category Performance

#### Total Revenue by Category
- **Bikes** generate the highest revenue (in millions).
- **Components** had no recorded sales.
- Categories like **Accessories** had more orders but lower revenue.

#### Insight:
> The number of subcategories doesn't necessarily drive revenue. **Bikes**, with the fewest subcategories, still lead in sales.

#### Average Spend per Order (by Category)
- Customers spend most per order on **Bikes**, indicating a premium product line.

#### Order Volume by Category
- **Accessories** had the **highest order volume**, but lower revenue. Indicating lower-priced items with higher turnover.
  
#### Insight:
> High quantity sold doesn’t always translate to high revenue. Pricing and product type influence total revenue more than volume alone.

### 2. Top Products & Correlation Between Quantity and Revenue

#### Top 5 Products by Revenue and Quantity
- Highest-earning products are also among the highest-selling by quantity.
- However, statistical check (Pearson Correlation Coefficient):  
  **Correlation = -0.004** → **No significant linear relationship** between quantity and revenue.

### 3. Customer Segment Analysis

#### By Country
- **United States** and **Australia** lead in total sales revenue.
- The **United Kingdom** follows at a distant third.

#### By Gender
- Females slightly outspent males.

#### By Marital Status
- **Married** customers generated the most revenue.

### 4. Average Order Value (AOV)

#### By Age Group
- Age was calculated using birthdate data.
- **Adults (≤69 yrs)** had higher average order values than older customers.

#### By Country
- **Australia** recorded the **highest AOV**, despite not having the highest order volume.

### 5. Sales Trend Over Time

#### Monthly Seasonality (2013)
- Sales **peaked in December**, with significant growth from mid-year.
- Clear **seasonal pattern** with **Q4 outperforming** other quarters.

## 📌 Recommendations

Based on this analysis, the following actions are advised:

- **Diversify the Bike Category:** Despite having fewer subcategories, bikes dominate in revenue. Explore opportunities to introduce new bike subcategories  to boost  variety and upsell potential.
- **Revamp or Retire the Components Category:** With zero recorded sales, audit whether this category:
a. Is incorrectly priced
b. Has stock issues
c. Needs better positioning or bundling with related products
- Offer bundles or cross-sells for high-volume low-revenue products like Accessories.
- Run seasonal campaigns in Q4 to maximize year-end sales momentum.
- Investigate countries with low total sales and low AOV to uncover barriers like poor delivery infrastructure, pricing mismatch, or lack of regional product relevance.
- Identify and address off-season months with flash sales, product education campaigns, or loyalty rewards to smooth out the revenue curve.
- Launch a feedback form post-purchase to collect qualitative data about why certain categories are under- or over-performing.

## Notes

- All analysis was performed using Microsoft SQL Server.
- Dataset is fictional but mimics real-world sales patterns.
- Results were manually reviewed and summarized in SQL comments for clarity.


