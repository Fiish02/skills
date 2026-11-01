# 排错与修复记录

按阶段读取完整日志，先检索 knowledge。每次修复用新 run ID，保留之前失败记录，禁止删除失败参数点或只抄最后一行。

| 阶段 | 证据 | 处理边界 |
|---|---|---|
| Windows 启动 | 异常链、NativeErrorCode、命令、进程是否真正创建 | 740 与历史 RUNASADMIN 是启动层线索；不自动改注册表或提权 |
| MATLAB 运行 | stdout/stderr、matlab_error、release/root | 必须完整 R2023a 路径；不调用裸 matlab |
| 连接/认证 | 现有启动配方、会话来源、服务常规日志 | 不猜端口、读密码或重配；用户交互认证在日志之前 |
| Java | version('-java')、javaclasspath、异常 cause | 不混入其他版本 jar；不能仅因 COMSOL/MATLAB JVM 数字不同认定失败 |
| API/模型结构 | 5.6 章节、真实 tags、getType、选择与数据集 | 无依据的 property/type 必须停止使用；不得改物理模型掩盖编程错误 |
| 许可证 | 产品授权 API、原始错误、已知许可来源 | 不改许可文件，不把 hasProduct 当永久席位可用 |
| Solver | solver progress、参数快照、依赖、收敛/迭代与状态 | 参数/边界/网格/求解策略变化需讨论 |
| 提取/验收 | dataset、solnum/outersolnum/t、单位、shape、NaN/Inf | 不把插值失败 NaN 自动填零，不误取旧解 |

修复闭环：现象→可复现条件→原因证据（未知则明确未知）→候选修复→授权范围→最小修改→新目录重跑→相同验收标准比较→知识库去重追加。知识主记录统一VERIFIED、PENDING、UNRESOLVED：候选修复与根因未知分别保留，旧OPEN/PROPOSED/VALIDATED只作为历史状态，不作新条目分类；反例使既有方案失效时追加边界和失效证据，不静默删除历史。

新执行入口的 Standalone 合成任务与异常日志已验证，COMSOL 分支未执行。若入口本身失败，先查看 run_status.json 与 matlab_status.json 的职责，不把基础设施失败错误归因为科研模型。

全局安装的共享知识路径和项目目录规则见 [global_scope.md](global_scope.md)。
