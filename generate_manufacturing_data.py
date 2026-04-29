import pandas as pd
import numpy as np
import random
from pathlib import Path
from datetime import datetime, timedelta


def generate_manufacturing_dataset(output_dir="output", n_orders=4200, seed=42):
    """
    生成制造业销售与成本分析项目数据集。

    输出文件：
    1. orders.csv         订单表
    2. products.csv       产品表
    3. customers.csv      客户表
    4. cost_details.csv   成本明细表
    5. sales_cost_fact.csv 分析宽表

    使用方法：
    python generate_manufacturing_data.py
    """

    np.random.seed(seed)
    random.seed(seed)

    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # =============================
    # 1. 生成产品表 products
    # =============================
    categories = {
        "电机类": ["伺服电机A型", "伺服电机B型", "步进电机A型", "减速电机C型"],
        "控制器类": ["PLC控制器标准版", "PLC控制器增强版", "变频控制器A型"],
        "传动部件": ["精密齿轮箱", "同步带轮组件", "联轴器套件"],
        "机加工件": ["铝合金支架", "不锈钢轴套", "CNC定制件"],
        "配套耗材": ["工业线缆", "传感器支架", "密封圈套装"]
    }

    product_rows = []
    product_id = 1001

    for category, names in categories.items():
        for name in names:
            if category == "电机类":
                unit_cost = np.random.randint(420, 1200)
                gross_rate = np.random.uniform(0.22, 0.38)
            elif category == "控制器类":
                unit_cost = np.random.randint(650, 1800)
                gross_rate = np.random.uniform(0.25, 0.42)
            elif category == "传动部件":
                unit_cost = np.random.randint(180, 750)
                gross_rate = np.random.uniform(0.18, 0.32)
            elif category == "机加工件":
                unit_cost = np.random.randint(80, 520)
                gross_rate = np.random.uniform(0.15, 0.28)
            else:
                unit_cost = np.random.randint(20, 180)
                gross_rate = np.random.uniform(0.12, 0.25)

            standard_price = round(unit_cost / (1 - gross_rate), 2)

            product_rows.append({
                "product_id": f"P{product_id}",
                "product_name": name,
                "category": category,
                "unit_cost": round(unit_cost, 2),
                "standard_price": standard_price,
                "supplier": random.choice(["南通华科", "苏州精工", "常州机电", "无锡智造", "上海工控"])
            })
            product_id += 1

    products = pd.DataFrame(product_rows)

    # =============================
    # 2. 生成客户表 customers
    # =============================
    regions = ["华东", "华南", "华北", "华中", "西南"]

    provinces = {
        "华东": ["江苏", "上海", "浙江", "安徽", "山东"],
        "华南": ["广东", "福建", "广西"],
        "华北": ["北京", "天津", "河北"],
        "华中": ["湖北", "湖南", "河南"],
        "西南": ["四川", "重庆", "云南"]
    }

    customer_types = ["终端工厂", "经销商", "设备集成商"]

    customer_rows = []
    for i in range(1, 121):
        region = random.choices(
            regions,
            weights=[0.42, 0.20, 0.14, 0.14, 0.10]
        )[0]

        customer_rows.append({
            "customer_id": f"C{i:04d}",
            "customer_name": f"{random.choice(provinces[region])}客户{i:03d}",
            "region": region,
            "province": random.choice(provinces[region]),
            "customer_type": random.choices(
                customer_types,
                weights=[0.45, 0.35, 0.20]
            )[0],
            "credit_level": random.choices(
                ["A", "B", "C"],
                weights=[0.45, 0.40, 0.15]
            )[0]
        })

    customers = pd.DataFrame(customer_rows)

    # =============================
    # 3. 生成订单表 orders
    # =============================
    start_date = datetime(2025, 1, 1)
    end_date = datetime(2025, 12, 31)
    days = (end_date - start_date).days + 1

    order_rows = []

    for i in range(1, n_orders + 1):
        order_date = start_date + timedelta(days=np.random.randint(0, days))

        # 华东订单更多，模拟制造业公司主要业务集中在江浙沪
        customer = customers.sample(
            1,
            weights=customers["region"].map({
                "华东": 1.40,
                "华南": 1.00,
                "华北": 0.80,
                "华中": 0.75,
                "西南": 0.65
            })
        ).iloc[0]

        product = products.sample(
            1,
            weights=products["category"].map({
                "电机类": 1.45,
                "控制器类": 1.15,
                "传动部件": 1.00,
                "机加工件": 1.25,
                "配套耗材": 0.70
            })
        ).iloc[0]

        # 不同产品类别的采购数量不同
        if product["category"] in ["电机类", "控制器类"]:
            quantity = np.random.randint(1, 18)
        elif product["category"] == "配套耗材":
            quantity = np.random.randint(10, 120)
        else:
            quantity = np.random.randint(3, 45)

        # 不同客户类型有不同折扣
        discount = {
            "终端工厂": np.random.uniform(0.94, 1.03),
            "经销商": np.random.uniform(0.86, 0.98),
            "设备集成商": np.random.uniform(0.90, 1.00)
        }[customer["customer_type"]]

        unit_price = round(product["standard_price"] * discount, 2)

        order_status = random.choices(
            ["已完成", "已取消", "退货"],
            weights=[0.92, 0.05, 0.03]
        )[0]

        order_rows.append({
            "order_id": f"O{i:06d}",
            "order_date": order_date.strftime("%Y-%m-%d"),
            "customer_id": customer["customer_id"],
            "product_id": product["product_id"],
            "quantity": quantity,
            "unit_price": unit_price,
            "order_status": order_status,
            "sales_person": random.choice(["张伟", "李娜", "王强", "陈敏", "赵磊", "刘洋"]),
            "channel": random.choice(["直销", "经销", "老客户复购", "展会线索"])
        })

    orders = pd.DataFrame(order_rows)

    # =============================
    # 4. 生成成本明细表 cost_details
    # =============================
    cost_rows = []

    for _, row in orders.iterrows():
        product = products.loc[products["product_id"] == row["product_id"]].iloc[0]
        order_month = pd.to_datetime(row["order_date"]).month

        material_cost = product["unit_cost"] * np.random.uniform(0.62, 0.72)
        labor_cost = product["unit_cost"] * np.random.uniform(0.12, 0.18)
        manufacturing_cost = product["unit_cost"] * np.random.uniform(0.10, 0.16)

        revenue = row["unit_price"] * row["quantity"]
        logistics_cost = revenue * np.random.uniform(0.015, 0.05)
        other_cost = revenue * np.random.uniform(0.005, 0.02)

        # 制造一个业务异常：
        # 8月电机类、控制器类原材料上涨，导致利润率下降
        if order_month == 8 and product["category"] in ["电机类", "控制器类"]:
            material_cost *= np.random.uniform(1.18, 1.35)

        cost_rows.append({
            "order_id": row["order_id"],
            "material_cost": round(material_cost * row["quantity"], 2),
            "labor_cost": round(labor_cost * row["quantity"], 2),
            "manufacturing_cost": round(manufacturing_cost * row["quantity"], 2),
            "logistics_cost": round(logistics_cost, 2),
            "other_cost": round(other_cost, 2)
        })

    cost_details = pd.DataFrame(cost_rows)

    # =============================
    # 5. 生成分析宽表 sales_cost_fact
    # =============================
    fact = (
        orders
        .merge(products, on="product_id", how="left")
        .merge(customers, on="customer_id", how="left")
        .merge(cost_details, on="order_id", how="left")
    )

    fact["revenue"] = fact["quantity"] * fact["unit_price"]

    fact["total_cost"] = (
        fact["material_cost"]
        + fact["labor_cost"]
        + fact["manufacturing_cost"]
        + fact["logistics_cost"]
        + fact["other_cost"]
    )

    fact["profit"] = fact["revenue"] - fact["total_cost"]

    fact["gross_margin_rate"] = np.where(
        fact["revenue"] != 0,
        fact["profit"] / fact["revenue"],
        0
    )

    fact["order_month"] = pd.to_datetime(fact["order_date"]).dt.to_period("M").astype(str)

    # =============================
    # 6. 保存 CSV
    # =============================
    orders.to_csv(output_path / "orders.csv", index=False, encoding="utf-8-sig")
    products.to_csv(output_path / "products.csv", index=False, encoding="utf-8-sig")
    customers.to_csv(output_path / "customers.csv", index=False, encoding="utf-8-sig")
    cost_details.to_csv(output_path / "cost_details.csv", index=False, encoding="utf-8-sig")
    fact.to_csv(output_path / "sales_cost_fact.csv", index=False, encoding="utf-8-sig")

    print("数据生成完成！")
    print(f"输出目录：{output_path.resolve()}")
    print(f"订单表 orders.csv：{len(orders)} 行")
    print(f"产品表 products.csv：{len(products)} 行")
    print(f"客户表 customers.csv：{len(customers)} 行")
    print(f"成本明细表 cost_details.csv：{len(cost_details)} 行")
    print(f"分析宽表 sales_cost_fact.csv：{len(fact)} 行")


if __name__ == "__main__":
    generate_manufacturing_dataset(
        output_dir=r"C:\Users\26029\Desktop\manufacturing_sales_analysis\data\raw",
        n_orders=4200,
        seed=42
    )
