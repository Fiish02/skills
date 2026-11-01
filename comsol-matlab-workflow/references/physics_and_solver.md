# 材料、物理、网格、Study与Solver

先读modeling_and_solver_guidelines.md及comsol_56_api_reference.md，再按物理模块的5.6手册核对。复杂固体/声学/耦合尚PENDING运行。

材料：创建Material及属性组、表达式/单位、域选择；每一物理域材料覆盖、方向/各向异性和复数阻尼须有研究依据。不能用教程材料默认值代替输入。Material API见本机api/com/comsol/model/Material.html和MaterialList.html；具体键/组逐项核实。
物理：确认模块与许可、维度、接口type、因变量、方程、初值/载荷/约束、耦合及实体选择。hasProduct不保证许可池长期有席位，不默换接口。
网格：自由三角/四面体、四边形/映射/扫掠、局部Size、边界层均为可选策略，不是已验证模板；先查本机comsol_api_mesh章节的Syntax和属性表。不能假定“Free Quadrilateral”必有同名feature。评估质量、薄层厚度离散、ABH局部尺度/波长和关键指标网格收敛，生成成功不足验收。
Study/Solver：分析类型、频率/时间/参数范围与容差由任务确定。Study可能生成序列；已有手工序列先查关联，不自动重置。没有5.6类型/属性依据就标PENDING，不猜键。保留失败点、求解日志、实际参数、解编号与dataset映射。
输出用mphglobal/mphinterp/mpheval，绘图mphplot仅在核实对应5.6函数参数后调用。每项API卡片需对象、输入/输出、示例、版本、章节及运行状态。未补齐卡片的物理feature/属性不能进入正式代码。


## 强制参数入口补充（2026-11-01）

按parameter_management.md影响表重查材料/物理选择、网格与解有效性；已有MPH先查参数依赖。缺少必要更新标STALE，param.set回读成功不等于模型已更新。