# 网格、质量与数值收敛

## 选择与当前证据
先由几何、波型/波长、厚度、曲率、界面和目标量选网格。三角形、四边形、映射、自由四边形、扫掠、3D四面体/六面体是不同策略，不能因名称相似猜测5.6 feature。Case 4仅验证二维FreeTri和七个四边域上的Map/Distribution；其中初始三角结果未通过本次最终峰值网格标准，不能作收敛基准。自由四边形、3D及任意扫掠路径UNVERIFIED。

ABH优先关注截断尖端、厚度梯度、根部C0折角及曲率；不为网格方便擅改幂律或平滑根部。保留原模型物理和验收阈值。

## 质量记录
保存实际域/边选择、单元阶次、几何形函数、各类型单元数、尺寸控制、实际最小/最大尺寸或单元测度、质量度量及最小/平均值、长宽比、局部厚度/曲率分辨率和分区分布。Case 4中`mphmeshstats.secondorderelements=false`不代表物理位移是一阶；实际`order_displacement=2s`另行回读。`minvolume/maxvolume`在二维是面积，不能标成边长。

单元数按`stats.types`索引解释：Case 4最终quad=3972、edg=1372、vtx=16，`sum(numelem)=5360`是混合实体总计，不是3972个二维单元以外的新网格数。输入`mapped_aspect_target=3`不是实际最大长宽比测量；该实际极值在现存证据中UNVERIFIED。最小质量约0.9799，仅是选定skewness度量，不证明所有形状指标通过。

## Case 4 已验证的有限比较
状态VERIFIED_WITHIN_COMPUTATIONAL_SCOPE；[案例主记录](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)。
- 同一物理配置，Map二次巧凑边点位移形函数，2760→3972个四边形（厚度方向5→6层）。
- 最大峰频变化0.09221163325665745%，最大峰值幅度变化0.1262602482291661%。
- 本案例配置阈值为峰频≤1%、幅值≤5%；源程序采用`<=`，报告中的“低于”是观测事实。
- 初始三角网格与映射网格的比较失败记录完整保留。既没有把两级比较写成渐近收敛证明，也没有声称连续解绝对误差已知。

未来至少比较两级网格；严格研究采用更多等级分析趋势、误差估计和模态/峰值匹配。指标根据研究目标选固有频率、测点FRF、位移、应力、声压级或声功率，不固定使用本例阈值。检查采样分辨率与网格误差的耦合，不能用粗频点掩盖峰位变化。保留失败/未收敛级别。

## 可复用实施位置
[abh_build_mapped_mesh.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_build_mapped_mesh.m>)：要求实际七个四边域、同材连续；按实际顶点识别竖直边，再查`getAdj(2,1,domainId)`，验证每域四边。全局Distribution设置厚度方向、各域纵向分布，Map作用于这些域，网格完成/类型/质量分别检查。
[abh_build_mesh.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_build_mesh.m>)包含仅针对本项目自有mesh1的重建逻辑；不能复制为删除外部用户网格的通用方法。调用前核实模型归属、已有解有效性和任务授权。
