# Manufacturing Sales & Cost Analysis（制造业销售与成本分析）

## 项目简介

本项目基于模拟制造业业务数据，从数据生成、数据建模到业务分析与可视化，完整复现数据分析工作流程，涵盖 Python 数据生成 + SQL 数据建模 + Power BI 可视化分析。
目标是通过多维度分析（产品/区域/客户/成本），识别盈利结构，发现问题产品，并提出业务优化方向。

## 技术栈

- python（数据生成）
- SQL（MySQL，数据建模 & 分析）
- Power BI（可视化）

## 数据处理流程

### 数据生成

使用python脚本模拟制造业业务数据，包括以下表格：

- 订单数据（orders）
- 客户数据（customers）
- 产品数据（products）
- 成本明细（cost_details）

### 数据建模

通过多表 JOIN 构建分析宽表：v_sales_cost_fact，并筛选分析所需字段，定义了一些新字段。

核心指标定义：

- revenue = quantity × unit_price
- total_cost = 各项成本合计
- profit = revenue - total_cost
- gross_margin_rate = SUM(profit) / SUM(revenue)

### Power BI可视化设计

#### Overview

全局经营情况监控

切片器：
- 年份 / 月份
- 区域
- 产品类别

KPI：
- 总收入
- 总利润
- 整体毛利率
- 订单总数

图标分析：
- 收入 vs 利润趋势（双轴折线图）
- 各区域收入占比（环形图）

#### Product

核心盈利产品 & 问题产品识别
