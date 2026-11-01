# 已验证的参数化曲梁与ABH几何工作流

## 状态、入口和适用范围
本文件为正式复用索引，VERIFIED主记录为共享知识库VS-009/010/011。环境限定本机Windows11、COMSOL5.6 Build280、MATLAB R2023a Update8，不等于官方支持声明。所有数值、点数、权重、范围只属于下列案例，不作为所有曲梁的默认精度保证。
新增知识分类：VERIFIED有实际运行和独立复核；SOURCE-DERIVED为论文/代码构型来源；WARNING为未解决问题；UNVERIFIED为未实测方法。旧PENDING/UNRESOLVED状态文字作为历史语境保留，不静默升级。文档已读不能视为运行通过。

## 可直接复用的已验证流程（VS-010、VS-011）
唯一入口config/model_config.m集中独立参数及元数据，派生量自动计算，N/容差等数值控制独立管理。run脚本每次读当前cfg、创建新run/唯一ModelUtil.createUnique模型，同步Global Parameters并set/get/evaluate回读SI值，保存cfg/源码副本、参数JSON、MAT/17gCSV、图、MPH和报告。独立Python再核对MPH参数与快照、CSV与MAT、实际几何与理论参考。
采用MATLAB坐标的Polygon必须重算坐标并更新/重建；仅修改Global Parameters不会更新已存数组。解析表达式驱动的Rectangle与此不同。两个实际测试均在同一个cfg中预定义CaseB，复用同一算法处理A/B；已经验证配置驱动的参数差异传入实际几何，不等于所有任意参数组合、已有MPH原位修改或通用模板均已验证。

## 恒定法向厚度曲梁（VS-010）
中心线yc=4fx(L-x)/L²，导数yp=4f(L-2x)/L²，法向n=(-yp,1)/sqrt(1+yp²)，边界ru/rl=(x,yc)±h*n/2。厚度按局部法向，不按全局Y；两端偏置点的X不一定相等，不改成竖直端面。
上表面左到右、下表面右到左排列Polygon，首点不重复；type=solid/source=vectors设置x/y后geom.run。g.getVertexCoord实际坐标和getAdj(1,0,edgeId)邻接重建闭环，不依赖编号顺序。检查2D域/边/顶点、bbox、坐标、法向厚度、自交及文件有效性。
在正则偏置、无自交、法向端面封闭条件下Aref=h*integral(sqrt(1+yp²),0,L)。MATLAB integral与Python scipy.quad独立参考，实际COMSOL边界图遍历面积与其比较；记录原生面积，不以原生值单独验收。
CaseA L/f/h=1/.2/.05m，CaseB=1.2/.25/.06m，N801；四级N101/201/401/801近二阶。A801面积误差4.740165045066141e-7，B801为5.0247995218226e-7；厚度最大误差分别6.94e-17和1.46e-16m。仅限此Polygon基准。

## 两端ABH变厚度（VS-011）
令d=min(x,L-x)。d<D时h=ht+(hbase-ht)*(d/D)^m，d>=D时h=hbase，等价于用户指定的左端/中部/右端三段函数。D_ABH是单端水平投影长度，不是弧长或内部ABH直径。左右镜像，端尖ht、根部及中央hbase。先计算h(x)，再沿同一局部法向±h(x)/2偏置，最后Polygon封闭。
检查正厚度、2D<L、h(x)/2<rho(x)，并执行输入和实际多边形所有非相邻线段（含共线/触碰）相交检查，不能只依赖内核修复或曲率条件。核验尖/ABH中点/根/梁中点七处实际厚度、镜像、中央常厚、实际坐标/bbox、边长和单域。
参考面积Aref=integral(h(x)*sqrt(1+yp²),0,L)，在0/D/L-D/L分段积分处理导数拐点，需正则无自交及法向端面。MATLAB原始Polygon面积、COMSOL原生getVolume、实际COMSOL闭环面积和连续参考同时保留。

### 采样及根部连续性
N为每表面固定总点数。已验证三分区均匀采样，ABH密度权重1.5；端点、ABH中点、根部、梁中心精确入点列，左右镜像。1.5为此次显式数值控制，不是通用固定要求；改变采样策略需做新收敛验证，不降低阈值。
根部h连续但dh/dx一般跳变：A内侧0.45、中部0；B0.43、中部0（右根符号相反）。实际根部转角约11.4–12.5°、无间隙/零边/反向尖点；保留原函数，不为了图形光滑自动平滑。检查真实相邻边切向角、最短边和非相邻自交。只有用户要求改变定义才考虑平滑。

### ABH案例数值（不是通用默认值）
CaseA：L=1m、f=.2m、hbase=.05m、ht=.005m、m=3、D=.30m；CaseB仅改ht=.007m、m=3.5、D=.35m。设计范围ht2–10mm、m2–4、D.20–.45m也是本次范围。

|模型|N|实际COMSOL边界面积相对误差|厚度最大误差m|
|---|---:|---:|---:|
|convergence_N201|201|3.8683053108475851e-05|6.1582683397176652e-17|
|convergence_N401|401|1.0221989696582033e-05|6.6786853825107073e-17|
|convergence_N801|801|2.5554958093181997e-06|7.5460471204991109e-17|
|case_A|1601|6.302722698865353e-07|6.9388939039072284e-17|
|case_B|1601|7.2481197231317206e-07|7.2858385991025898e-17|

最终每组1个2D域、3202边和3202点，最大厚度误差约7.29e-17m，面积均<1e-6；阶数约1.92、2.00、2.02。本轮总共五个实际模型，CaseA1601兼作收敛末级，不算第六个。实际标签、bbox、参数和完整精度见原报告/JSON。

## WARNING：原生面积精度
Known issue, workaround validated, root cause unresolved。详细主问题KI-008、API记录GV-001。完整保留getVolume双精度返回值，不四舍五入，不宣称修复；同列原生面积、实际COMSOL坐标/连接重建面积、连续理论参考。对实际Polygon直线分段的面积重建替代验收已验证，但曲线几何的精确面积不能直接用顶点连线代替。

## SOURCE-DERIVED：内部ABH论文构型，不是上述两端基准
原论文TeX main-sc-en.tex约299–345行：半梁内部ABH中心xc=L/4，D_ABH是该内部区域水平投影直径，另半镜像；阻尼同心，|x-xc|<=D_damping/2且D_damping<=0.95D_ABH，完全粘结。stage12_geometry_plot.py约178、205–211、300–309行对应投影掩膜、左右镜像、下表面外侧法向偏置。
不得将两端ABH公式当成论文最终内部ABH公式，不能将两端测试PASS等同完整TLP–TLS已建模。内部ABH的COMSOL自动几何、阻尼多域、材料赋值/网格/物理自动化均UNVERIFIED。本机1D PDE历史求解仍有效，不能由此泛化为上述专业模型通过。
阻尼实际落地仍需确认中心/起止位置、覆盖侧、相对尖/根范围、厚度、端部过渡、镜像，以及联合共享边界还是装配/粘结。历史来源给出了旧模型的下侧/同心/粘结定义，但不决定本次端部基准的映射及COMSOL离散实现。

## 证据与源代码复用
原始模型/配置/算法都保持在独立测试目录，不复制为固定默认设计、不直接在历史run重跑。先读对应project的README与config，复制项目到新研究目录或按其主程序建立新的独立run，保留唯一tag和完整参数快照；研究假设/参数改变按用户授权处理。

- rectangle：[报告](<D:/test/comsol-matlab-workflow-geometry-test/run_20261101_163729_retry04/report.md>)；[独立复核](<D:/test/comsol-matlab-workflow-geometry-test/run_20261101_163729_retry04/logs/independent_review.json>)。

- curved：[报告](<D:/test/comsol-matlab-workflow-curved-beam-parameterized-test/run_20261101_182142_550_b828ac8b-d8f1-4c15-ad92-6652588a6a6c/report.md>)；[独立复核](<D:/test/comsol-matlab-workflow-curved-beam-parameterized-test/run_20261101_182142_550_b828ac8b-d8f1-4c15-ad92-6652588a6a6c/logs/independent_review.json>)。

- abh：[报告](<D:/test/comsol-matlab-workflow-abh-curved-beam-test/run_20261101_190839_544_63b3c800-2823-47ea-8ea4-c25f824036b3/report.md>)；[独立复核](<D:/test/comsol-matlab-workflow-abh-curved-beam-test/run_20261101_190839_544_63b3c800-2823-47ea-8ea4-c25f824036b3/logs/independent_review.json>)。

- 恒厚曲梁成功项目：D:/test/comsol-matlab-workflow-curved-beam-parameterized-test/project_20261101_181836_retry02（config/model_config.m、src/run_curved_beam.m及calculate_geometry/has_intersection）。
- ABH成功项目：D:/test/comsol-matlab-workflow-abh-curved-beam-test/project_20261101_183831（config/model_config.m、src/run_abh_curved_beam.m、calculate_abh_thickness/calculate_geometry/has_intersection、verify_abh_outputs.py）。run内source/config为实际快照。
- 原研究来源：D:/vscode_project/Projects/Optimization/surrogate_based_optimization_v3/PAPER/MyPaper/main-sc-en.tex；同项目src/stage12_geometry_plot.py；来源复核在ABH报告及docs/damping_review.md。

主知识记录：[validated_solutions.md](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_solutions.md>)（VS-009/010/011）；[原生面积问题](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/known_issues.md>)（KI-008）；[API说明](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/api_usage_notes.md>)（GV-001）。


## Case 4 单端直梁的独立入口
新增[单端直梁ABH频域案例](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)（VS-012，VERIFIED_WITHIN_COMPUTATIONAL_SCOPE）。其坐标轴直线、厚度沿Y、单端渐薄，与本页两端法向偏置曲梁不同。Case 4材料/物理/网格/求解成功不能升级论文内部ABH、粘结阻尼层或多材料耦合；原Cases 1–3及面积WARNING继续有效。
