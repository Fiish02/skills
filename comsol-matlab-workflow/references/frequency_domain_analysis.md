# 频域分析、分辨率和FRF

## 前提与复用顺序
先确认维度/约束、材料与阻尼、载荷幅相/单位/区域、测点方向、频段与目标指标。优先读取[Case 4](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)和[实际API](comsol_56_api_reference.md)，按模型条件复用。案例整体VERIFIED_WITHIN_COMPUTATIONAL_SCOPE，不能把结构位移输出称为声压级或已验证声固耦合。

## 频率数组与求解
cfg给出单位明确的频率列表；要求有限、严格递增、无重复且覆盖指定端点，记录生成规则、局部加密中心/区间/步长、每轮请求数组与**求解后回读的实际数组**。检查solver、dataset、solnum/outersolnum是否对应本次频率。不能把旧解或写入plist成功当作新解。

Case 4：5–200 Hz，初始0.5 Hz共391点，局部加密后最终1284点，值只属于该案例。实际路径为391→757点的早期运行与恢复后的757/1284点网格复算，最终后处理目录没有新求解，见provenance。不能把1284理解为整个历史仅执行1284次线性求解。

原代码用`unique`去重双精度数组；这不自动合并近邻但不相等的值。保留历史1284数组，不事后舍入或删点。新任务如需合并近重复，须定义与分辨率一致的容差、保存映射，并对获授权的新频率列表求解。根据阻尼、模态密度和峰宽决定步长，不照搬0.5 Hz；粗扫峰检测可能漏掉极窄峰，必要时另行授权模态定位或独立细扫。

## 阻尼与分辨率
结构损耗因子eta与阻尼比zeta不等同；本例eta=0.01仅为演示。原策略在峰附近使用经验条件`Delta f <= eta*f/8`，实现检查峰附近相邻五个索引的最大间隔与eta*f之比；它不是普适数学定理，不能移用到所有阻尼或强耦合问题。

Case 4嵌套检查：完整实际频点与其子集比较，子集保留隔点索引并重新保留初始0.5 Hz网格和端点；保存具体索引。最终最大采样峰频差0.07538749170737161%，最大幅值差0.5181045987111899%，按本例1%/5%通过。**不是两次独立有限元求解，不是严格频率收敛证明**。用户要求严格验证时，经授权独立执行两组分辨率并保留各自完成证据。

## FRF与变量命名
一般复数定义：`H_uF=U/F`，单位m/N；`H_vF=V/F`，单位(m/s)/N；`H_aF=A/F`，单位(m/s^2)/N。幅值、相位和复数本体分开。若采用exp(i*omega*t)，速度为i*omega*U、加速度为-omega^2*U；实际接口表达式和时间约定先核实，Case 4未验证通用速度/加速度提取链。

Case 4 COMSOL变量`v`实际是Y向**位移**。存储的复数`frf=v/F0`，其幅值为`abs(v)/F0`，是receptance幅值，不是速度导纳/SPL。F0是正标量力峰值，实际Fy=-F0*exp(i*phase0)，故相位相对正F0定义；与U/Fy的相位约定不能混同。新后处理建议使用u_x/u_y、v_x/v_y、a_x/a_y作为语义别名，保留实际COMSOL表达式映射，勿直接改名破坏接口。

## 实际函数与限制
- [abh_solve_frequencies.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_solve_frequencies.m>)：Study plist/run后调用独立提取。
- [abh_refine_response.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_refine_response.m>)：有界局部加密，保存每轮请求/响应/检查，不足时保留未验证状态。每测点最多6峰是本例数值控制，不保证全频带所有峰已捕获。
- [abh_nested_frequency_check.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_nested_frequency_check.m>)：实际子集检查；[abh_compare_peaks.m](<D:/test/abh_beam_2d/results/run_20261101_221156_379_76354718-01a8-438c-b1cf-7f3f1f82a2e3_postprocess/source/src/abh_compare_peaks.m>)按测点及最近频率匹配，交叉/密集模态需更强跟踪，不能泛化。

模态特征值、离散采样峰值、拟合峰值、插值峰值严格区分。本例12.172 Hz为采样响应峰，不标成精确固有频率。
