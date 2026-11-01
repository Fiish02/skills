# 示例使用边界

这里七个函数均为 DOC_VERIFIED / RUNTIME_NOT_TESTED。它们需要已有连接和经过检查的工作模型，不会自行连接。参数名/tag/表达式/选择必须由实际模型与用户授权提供。禁止将它们逐个运行当作“验证 Skill”。

model_loading 复制输入到 run/input 后加载唯一服务端 tag；其余函数接收这个工作模型。parameter_modification、geometry_and_mesh、physics_and_boundary_conditions、study_and_solver、parameter_sweep 会改变工作模型或计算，显式 authorized=true 代表调用者已确认本次范围，不能由助手为绕过批准而填 true。

result_extraction 的 globalExpr 必须是可全局评估的量，fieldExpr 是有效场变量；dataset 与内外解编号均需明确。数值有限只是一项检查，不构成完整物理验收。所有科研输出均留在独立 run/output。


## 2026-11-01 科研模式扩展（当前状态）

旧七个示例继续保留；它们不是已运行的通用求解器。create_geometry_from_scratch演示唯一模型和2D Rectangle，parameterized_geometry演示MATLAB轮廓到2D Polygon；本轮核对5.6文档，PENDING运行。两者不自动选择物理/材料/网格。
analysis_workflow为专业分析共享适配模板，按references/structural_dynamics、acoustics、optimization填写configure/solve/extract/validate/export回调；模态、FRF、瞬态、预应力、声固耦合、扫描/优化均未获得本轮运行验证，不能留空回调后宣称可解。每项具体分析在收到实际科研任务后补齐官方API/物理方案及验证；避免凭空预设材料载荷或伪造八份可运行案例。
真实1D PDE完整代码与原始证据保留于D:/test/comsol-matlab-workflow-test/run_20261101_133305_retry02/src/run_smoke_test.m；正式案例索引在共享knowledge/regression_test_cases.md。该历史GUI脚本是一次性运行包，不当作可直接重跑的可移植模板。

专业适配入口：modal_analysis（模态/预应力由configure确定）、frequency_domain（频率响应）、transient_dynamics（瞬态）、acoustic_analysis（声学指标）、optimization_case（单设计点评价）；均复用analysis_workflow回调，带对应输入检查，PENDING运行。参数扫描沿用parameter_sweep；不是已配置完成的通用物理模型。


## 强制参数入口补充（2026-11-01）

新项目入口parameterized_project/config/model_config.m和src/run_model.m，详见其README。旧示例保留为低层片段，输入必须由唯一cfg生成并归档；不允许参数修改/扫描示例成为第二份独立参数源。新模板PENDING。