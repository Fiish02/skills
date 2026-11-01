---
name: comsol-matlab-workflow
description: 以 MATLAB 和 LiveLink 控制 COMSOL 5.6，从零参数化建模或加载已有 MPH，完成材料、物理、网格、求解、结果提取与验证；用于结构振动、声学及参数化科研仿真。
---

# COMSOL–MATLAB 科研仿真

MATLAB 是自动化控制端：计算参数/几何坐标、调用 LiveLink、管理模型及处理结果。COMSOL 完成实际几何/布尔运算、材料/物理/网格、有限元求解和结果计算。Codex 负责需求、5.6官方文档、代码、调试、复核、文件和证据管理。外部 CAD 不是前置条件。

## 当前证据入口（Case 4 增量，2026-11-01）
本入口原有“仅1D”“专业模型PENDING”“17g尚未实测”等段落是早期历史快照，保留原文；当前范围以本节、VS-009～012及对应原始证据为准。**先检索已验证案例和实际源码，再研究缺少依据的5.6 API**。复用已有案例时先确认版本、维度、构型、材料/阻尼、载荷单位、选择和解数据集；只复制到新项目，不在历史run执行。

共享知识主库继续使用 [global_scope](references/global_scope.md) 指定的实际目录，不在Skill内另建同名knowledge分叉。Case 1–3分别是矩形、恒法向厚度曲梁、两端ABH曲梁；Case 4是二维直梁单端ABH频域分析，主记录[VS-012与详细案例](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)。内部镜像ABH曲梁不是Case 3或4，仍未完成对应COMSOL自动建模验证。

Case 4整体为VERIFIED_WITHIN_COMPUTATIONAL_SCOPE；具体材料、平面应力、总力、映射网格、Frequency、复数提取、导出和重载读解可按其条件复用。模态、瞬态、平面应变、3D结构、声固耦合和通用优化仍UNVERIFIED，不因流程覆盖就升级。全新参数组合及当前模板完整新建一键链不因分阶段成功自动通过。知识维护任务只读证据，不运行求解、MATLAB Batch或连接恢复。


## 默认环境与连接

本机 Windows11，MATLAB R2023a Update8，Root `D:\Program Files\MATLAB\R2023a`；COMSOL5.6 Build280，Root `D:\Program Files\COMSOL\COMSOL56\Multiphysics`；LiveLink 为该根的 mli。此组合本机真实FEM通过，不代表官方支持。
先读项目 AGENTS.md 与 [项目规则](references/project_rules.md)、[目录和共享知识](references/global_scope.md)。Skill 是当前用户全局入口，项目根必须取当前工作目录或显式 ProjectRoot，不从 Skill 路径推算。

默认复用已有成功连接。在实际执行窗口检查 `version('-release')`、`matlabroot`、`mphversion` 和 mli 解析；历史PASS不证明现在仍连接。没有连接时检查当前MATLAB状态，请用户通过其已验证方式建立连接后等待。已发现官方with MATLAB快捷方式，但此前成功会话的实际启动来源不明。保留mphstart.p/m及其正常优先级。
无法控制GUI时，生成完整脚本和准确的 `run('绝对路径')`，让用户在已连接窗口提交；之后主动读取日志、结果、修复和复核。只生成脚本不能报告已执行。
[连接协议](references/livelink_matlab_workflow.md)；既有 scripts/run_matlab.ps1 的 PrepareConnected 可用于打包。Standalone只用于纯MATLAB，不继承GUI连接。
无人值守Batch、独立Server、认证/网络/防火墙、独立许可及远程节点均为 OPTIONAL / OUT OF SCOPE，不作为科研仿真的必要验收。保留研究笔记，不自动新建Server。

## 强制统一参数入口

所有新建或修改COMSOL模型的项目必须提供独立、集中、可修改的配置入口，默认config/model_config.m。MATLAB配置是唯一设计参数源，不在几何、材料、求解、后处理函数重复硬编码关键数值。先读 [参数管理](references/parameter_management.md)，交付前后都明确配置路径、可修改参数含义/单位/范围、主程序命令、受影响的重建/网格/求解步骤。用户已给定值直接用，缺少必要参数则指出，不机械套用曲梁字段。
流程必须为配置读取/合法性检查→派生量自动计算→COMSOL全局参数同步并回读→按依赖更新模型→新run和实际配置/源码/参数快照。表达式几何引用全局参数；MATLAB离散坐标几何必须重算坐标并更新/重建，单改Global Definitions不能更新Polygon数组。已有MPH先查依赖，不能把set成功当传播成功。
每个新参数化模型至少需关键参数A/B实测，比较实际COMSOL几何而非只比配置；实际测试另获授权。本次参数化模板全部PENDING，不据文档编辑启动仿真。可复制的最小项目：[配置](examples/parameterized_project/config/model_config.m)、[主程序](examples/parameterized_project/src/run_model.m)、[说明](examples/parameterized_project/README.md)。原示例保留为由cfg驱动的低层片段，不能另设一套独立设计参数。

## 模式选择

### A：从零建立模型（核心）
无需MPH或外部CAD。按需求依次完成：唯一Model标签 → 参数/单位 → Component/Geometry → MATLAB参数化坐标及COMSOL几何构建 → 材料分区和物理/边界/初值/载荷/耦合 → 网格 → Study/Solver → 提取/验证 → 新路径保存。
先读 [几何建模](references/geometry_modeling.md) 和 [材料、物理、网格与求解](references/physics_and_solver.md)。几何示例 [新建几何](examples/create_geometry_from_scratch.m)、[参数化几何](examples/parameterized_geometry.m) 是文档模板，未经运行验证。研究问题涉及1D/2D/3D、曲梁/ABH/多区域/布尔时按对应5.6章节核实，不能将单区间端点选择泛化。

### B：加载已有 MPH（核心）
检查源文件与版本，哈希并复制到独立run/input，唯一tag加载工作副本；检查组件/参数、几何、材料与域分配、物理和边界选择、网格、Study/Solver、Results及解编号，再修改用户授权节点、重新求解、提取并另存新MPH。
复用合理的既有结构；不要无理由重建。[model_loading](examples/model_loading.m) 为未运行模板；加载前核对tag以免覆盖。模型结构检查与验收细则见 [建模指南](references/modeling_and_solver_guidelines.md)。

### C：外部 CAD（可选）
仅在任务需要时采用；先核实文件格式、单位、修复容差与导入模块许可。不默认要求SolidWorks/SpaceClaim。

## 每次科研任务的流程

1. 明确目标、几何/材料/参数单位、物理/载荷/边界、Study、输出与验收。研究假设及缺失的关键选择需讨论；已有授权不重复询问。
2. 给出建模方案与5.6证据。查 [官方索引](references/official_documentation.md)、[API卡片](references/comsol_56_api_reference.md)。记录对象层级、feature type、输入输出、tag/单位/数据集/调用顺序与验证状态；找不到5.6依据标PENDING，不照搬6.x。
3. 编写模块化MATLAB函数 `(cfg,runDir)`，集中参数、显式路径；先生成独立运行包及源码/输入快照。异常保存完整getReport并rethrow；复跑新目录，保留失败记录。
4. 在已连接会话执行授权模型操作，不clear/remove其他模型、不自动断连。几何/网格更新后重新检查选择与材料归属，不硬编码未经核实实体ID。
5. 主动读MATLAB输出/异常、原生进度及求解内容、状态、结果。GUI的diary不等于OS stdout/stderr；不可获得流标UNAVAILABLE。showProgress(String)返回void，不接收输出；无输出字符串调用修复尚PENDING。Progress/Solver/Server日志明确来源，派生段不得称独立采集。
6. 验证真实求解完成、变量/解与参数一致、NaN/Inf、复数、单位/维度、物理规律和用户标准。不得只凭退出码/PASS/非空解判成功；无标准标COMPLETED_UNVALIDATED。
7. 交付新MPH、完整MATLAB源码、CSV/MAT、PNG、日志/状态和报告。CSV默认舍入经验保留；建议17g+原始MAT+回读核对，但修复未实测，不标VERIFIED。

## 结构振动、声学与优化

按任务读取 [结构动力学](references/structural_dynamics.md)、[声学](references/acoustics.md)、[参数扫描/优化](references/optimization.md)。包括模态/预应力、频响、瞬态、阻尼、声固耦合、辐射/SPL/强度/功率/远场/PML，以及敏感性、多目标和代理模型数据生成。具体模块许可、feature与表达式逐项查5.6，研究假设不自行替换。示例索引见 [examples/README.md](examples/README.md)。

## 证据、安全与知识

当前仅真实1D CoefficientFormPDE基线已运行：20个P1单元、101点、max误差4.4408920985006262e-16、RMS2.4345293599563255e-16，阈值max<1e-3。线性解属于P1空间，不泛化该精度。正式记录在共享knowledge/regression_test_cases.md和validated_solutions.md；本次编辑不重跑。
知识统一 VERIFIED / PENDING / UNRESOLVED；旧状态文本保留历史语境，新记录按此分类。VERIFIED主记录仅在共享validated_solutions，其余文档交叉引用；文档核对标DOC_CONFIRMED，不冒充运行验证。先去重再追加known_issues/debugging_history/api_usage_notes/decision_log/regression_test_cases。排错见 [troubleshooting](references/troubleshooting.md)。
不覆盖原MPH/数据，不ModelUtil.clear()，不删除历史。原Preferences、pathdef、注册表、环境变量、许可、防火墙不擅改；密码不进脚本/日志。管理员、系统、网络、许可变更先解释获批。求解、建模、参数修改必须属于用户授权；不能用变更物理或放宽阈值掩盖代码问题。


## 已验证曲梁知识索引（2026-11-01增量，非执行逻辑变更）
新曲梁/ABH任务先读 [已验证曲梁与ABH流程](references/validated_curved_beam_workflow.md)，并通过共享知识VS-009/010/011定位原报告、实际配置/算法和独立复核，优先复用已验证API而非重新探索。既有未运行通用模板不因这些特定项目通过而整体升级。
集中配置为用户修改入口；验收必须查询实际COMSOL实体、复杂轮廓须独立复核。ABH检查尖/根、法向厚度和非相邻自交；按原生getVolume的已知WARNING保留三类面积，不宣布其已修复。两端ABH测试基准与论文内部ABH严格分开。先验收基体，再在另行授权后增加阻尼/材料/物理。
本次新增几何知识统一采用VERIFIED / SOURCE-DERIVED / WARNING / UNVERIFIED；旧PENDING/UNRESOLVED保留为历史字样，见DEC-012。论文定义不等于COMSOL运行验证；未经实测不得标VERIFIED。

当前证据范围补充：前文“当前仅真实1D”及“17g修复未实测”为本次归档前的历史状态；截至本节，VS-009/010/011几何案例及曲梁项目17g+MAT回读已验证。其余通用模板、物理场或求解能力不随之升级。


## 完整有限元阶段与按需路由

先识别任务：仅几何、几何+材料、物理场配置、模态、频域、时域、扫描、优化、声振耦合或仅后处理；明确授权的阶段，按需执行，不每次跑完整流程。

任务分析 → 环境只读检查 → 唯一参数配置/派生/回读 → 几何创建 → 实际几何验收 → 材料与域/界面 → 物理场 → 约束和载荷 → 网格 → 质量检查 → Study/Solver → 授权求解 → 结果提取 → 后处理 → 数值检查 → 独立复核 → MPH/数据导出 → 报告。断点保存可穿插各阶段；已有有效解的后处理直接走提取/导出，保留原始求解来源。

|任务|按需读取|
|---|---|
|材料、Solid Mechanics、2D近似、边界与Study|[物理与求解](references/physics_and_solver.md)、[5.6实际API卡片](references/comsol_56_api_reference.md)|
|三角/四边形/映射及网格收敛|[网格与收敛](references/mesh_and_convergence.md)|
|扫频、阻尼、局部加密和频率分辨率|[频域分析](references/frequency_domain_analysis.md)|
|FRF、复数提取、重载读解、可信度及复用门槛|[后处理与验证](references/postprocessing_and_validation.md)|
|已验证曲梁/两端ABH、单端ABH区分|[几何索引](references/validated_curved_beam_workflow.md)、共享VS-009～012|
|模态/瞬态、声学/声固、扫描优化|[结构动力学](references/structural_dynamics.md)、[声学](references/acoustics.md)、[扫描优化](references/optimization.md)，各项按自身UNVERIFIED边界处理|

保持集中cfg为唯一参数源：区分设计、材料、数值控制、求解器、后处理与派生参数；按依赖重建，不散落硬编码。二维必须选择平面应力/平面应变；平面应力显式记录出平面宽度、材料与总力/面力/线载荷定义。选择原生TotalForce模式时由COMSOL按实际面积归一化，勿再重复乘除宽度。

保存实际频率列表、复数响应、方向/单位和FRF定义。案例参数和1%/5%阈值不是全局默认。几何成功、单次网格变化、嵌套频点、MPH重载、辅助梁理论各自的证据范围分开；数值验证不升级实验或工程真实性。可信度统一为VERIFIED、VERIFIED_WITHIN_COMPUTATIONAL_SCOPE、SOURCE-DERIVED、WARNING、UNVERIFIED；旧状态保留为历史。运行状态PASS/FAIL/COMPLETED_UNVALIDATED与知识可信度分开。

阶段验收不自动增加审批：用户已授权完整有限元任务时，几何验收后继续已授权的材料、物理和求解；历史“先基体、再另批”的表述针对当时仅几何的范围，不能用于重复索取已有授权。只做知识维护或后处理的任务则严格保持其阶段边界。
