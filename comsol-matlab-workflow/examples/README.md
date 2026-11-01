# 示例使用边界

这里七个函数均为 DOC_VERIFIED / RUNTIME_NOT_TESTED。它们需要已有连接和经过检查的工作模型，不会自行连接。参数名/tag/表达式/选择必须由实际模型与用户授权提供。禁止将它们逐个运行当作“验证 Skill”。

model_loading 复制输入到 run/input 后加载唯一服务端 tag；其余函数接收这个工作模型。parameter_modification、geometry_and_mesh、physics_and_boundary_conditions、study_and_solver、parameter_sweep 会改变工作模型或计算，显式 authorized=true 代表调用者已确认本次范围，不能由助手为绕过批准而填 true。

result_extraction 的 globalExpr 必须是可全局评估的量，fieldExpr 是有效场变量；dataset 与内外解编号均需明确。数值有限只是一项检查，不构成完整物理验收。所有科研输出均留在独立 run/output。
