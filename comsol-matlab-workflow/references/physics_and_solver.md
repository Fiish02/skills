# 材料、物理、网格、Study与Solver

先读modeling_and_solver_guidelines.md及comsol_56_api_reference.md，再按物理模块的5.6手册核对。复杂固体/声学/耦合尚PENDING运行。

材料：创建Material及属性组、表达式/单位、域选择；每一物理域材料覆盖、方向/各向异性和复数阻尼须有研究依据。不能用教程材料默认值代替输入。Material API见本机api/com/comsol/model/Material.html和MaterialList.html；具体键/组逐项核实。
物理：确认模块与许可、维度、接口type、因变量、方程、初值/载荷/约束、耦合及实体选择。hasProduct不保证许可池长期有席位，不默换接口。
网格：自由三角/四面体、四边形/映射/扫掠、局部Size、边界层均为可选策略，不是已验证模板；先查本机comsol_api_mesh章节的Syntax和属性表。不能假定“Free Quadrilateral”必有同名feature。评估质量、薄层厚度离散、ABH局部尺度/波长和关键指标网格收敛，生成成功不足验收。
Study/Solver：分析类型、频率/时间/参数范围与容差由任务确定。Study可能生成序列；已有手工序列先查关联，不自动重置。没有5.6类型/属性依据就标PENDING，不猜键。保留失败点、求解日志、实际参数、解编号与dataset映射。
输出用mphglobal/mphinterp/mpheval，绘图mphplot仅在核实对应5.6函数参数后调用。每项API卡片需对象、输入/输出、示例、版本、章节及运行状态。未补齐卡片的物理feature/属性不能进入正式代码。


## 强制参数入口补充（2026-11-01）

按parameter_management.md影响表重查材料/物理选择、网格与解有效性；已有MPH先查参数依赖。缺少必要更新标STALE，param.set回读成功不等于模型已更新。

## Case 4 后的物理与求解配置规范
前述“复杂固体PENDING”是历史快照。当前仅[Case 4](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)的二维线弹性平面应力、均匀结构损耗、固定约束、总谐波力及Frequency流程有真实执行与独立复核，整体VERIFIED_WITHIN_COMPUTATIONAL_SCOPE。其余接口不随之升级。

### 材料与阻尼
从cfg读取E、nu、rho及所选阻尼参数，记录单位、来源和域覆盖。Case 4的实测API为`mat.propertyGroup('def')`中的`youngsmodulus`、`poissonsratio`、`density`、`lossfactor`，值均引用同步全局参数；`lossfactor`是材料API键，不能用显示符号`eta_s`代替。线弹性`lemm1`子节点`Damping`采用`DampingType=IsotropicLossFactor`、`eta_s_mat=from_mat`。这些仅在该5.6接口/材料组合VERIFIED。
结构损耗因子eta、阻尼比zeta、Rayleigh系数、黏性系数、复模量不是同一参数；先明确模型和频率/时间适用性。转换、复模量符号与时间约定须有用户模型和5.6依据；Case 4没有验证其他阻尼实现。70 GPa等数值只属于演示案例，不成为全局默认。

### 维度、域与界面
|配置|当前实测边界与未来要求|
|---|---|
|2D Solid Mechanics / Plane Stress|Case 4 VERIFIED（设置范围）；`prop('Type2D').set('Type2D','PlaneStress')`，`prop('d').set('d','b')`；另查宽度数值验证限制|
|2D Plane Strain / Generalized Plane Strain|UNVERIFIED；必须由实际出平面约束选择，不把平面应力配置照搬|
|3D Solid Mechanics|UNVERIFIED；核实3D域、材料、体积和载荷面积，不能沿用2D宽度解释|
|Pressure Acoustics|UNVERIFIED；给定介质、声速/密度/损耗、参考量、边界和模块许可后核实5.6接口|
|Acoustic-Structure Interaction|UNVERIFIED；显式声/固域、界面法向、连续性/耦合、声学边界和功率核查|

所有域分别保存材料归属；Union共享边界、Assembly与配对/粘结必须区分。Case 4是七个同材连续分区，不能作为异材、多阻尼层、接触或多物理界面的验证。

### 二维宽度与载荷核查
先说明总力N、面力N/m²和按哪条长度定义的线载荷N/m。设出平面宽度b、加载边界弧长s：面力`t_y`对应`F_y=b*integral(t_y ds)`；沿边界长度的线载荷`q_y`对应`F_y=integral(q_y ds)`。若“单位宽度力”是按出平面宽度定义，则应另写`F_y=b*Q_y`，不得混淆两种N/m。

Case 4源码及MPH确认：`b=0.01[m]`绑定Solid厚度`d=b`；`BoundaryLoad`使用`LoadType=TotalForce`、`Ftot={'0','-F0*exp(i*phase0)','0'}`。原生总力模式负责按所选边界实际面积归一化，不需要再手动乘除b。加载长度约0.02 m，`intload(1)*b`实际回读约0.0002 m²；0.01 N总力对应的均匀面力约-50 Pa、沿边界线载荷约-0.5 N/m。这是单位复核，不是已设置了FperArea模式；该模式的默认零值不是载荷为零。

宽度进入模型厚度输入、全局值、材料rho和总力模式的**定义设置已VERIFIED**。本次未见b的A/B缩放、装配K/M或独立质量/反力缩放测试；质量/刚度随宽度的独立数值检验仍UNVERIFIED，不能写成已测量K、M均正确缩放。此范围区别必须随交付保留。

### 约束与Study
固定、滑移、对称、弹性支承、集中/分布/谐波/多点载荷均需记录物理意义、选择、坐标/法向、幅值、单位及相位；只有Case 4的Fixed和单区域TotalForce有本次实测。选择在实际几何上确认，不能固化案例实体ID。
`Frequency`的create、plist与Study.run在新建独立模型及Case 4恢复路径已执行；保存实际频率、solver/dataset关联、有限性、状态和完整异常。Eigenfrequency、TimeDependent及通用Parametric Sweep仍UNVERIFIED；先确定搜索/时间/参数列表及特有验收。模态特征值与FRF采样峰值不同。材料节点局部非线性选项不能代替Study整体非线性开关检查。

求解与提取分离：见[频域](frequency_domain_analysis.md)、[网格](mesh_and_convergence.md)、[后处理](postprocessing_and_validation.md)。源函数[abh_add_physics.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_add_physics.m>)不是无条件通用物理模板。
