---
name: comsol-matlab-workflow
description: 使用 COMSOL 5.6 与 MATLAB R2023a 的既有 LiveLink 会话进行模型检查和自动化、结构动力学与声学分析、参数扫描、结果提取及 API 排错，并维护带证据的科研知识库。
---

# COMSOL–MATLAB 工作流

## 适用范围与环境

用于 MATLAB 调用 COMSOL、模型创建/修改、几何与网格、物理场与边界、模态/频域/瞬态分析、批量计算、优化与结果处理。默认 COMSOL **5.6.0.280**、MATLAB **R2023a Update 8**，不自动升级。这是当前 Windows 用户的全局 Skill。项目根目录是当前任务的工作目录或明确传入的 ProjectRoot，不能从 Skill 安装路径向上推算。先读取适用的项目 `AGENTS.md`，并遵守 [长期安全规则](references/project_rules.md)；目录与共享知识库规则见 [global_scope.md](references/global_scope.md)。

开始时确认执行 OS、主机、目录与进程状态。Windows 专用程序只在 Windows 主机执行。独立 R2023a 启动和 Java 初始化已有历史实测；当前连接状态为 PASS（用户已在实际连接窗口执行 version/root/mphversion/which 并提供结果）；已发现官方联合启动快捷方式，但该成功会话的启动来源未确认。交互式连接与无桌面自动化不得等同，不重测基础兼容性。见 references/connection_profile.json。

## 官方文档与按需阅读

- 查版本、来源、使用条件：读 [official_documentation.md](references/official_documentation.md)。优先本机 5.6 文档，缺项再查官方网页；不复制手册全文。
- 写/改 API：读 [comsol_56_api_reference.md](references/comsol_56_api_reference.md)。明确对象、输入输出、节点 tag、单位、数据集与解编号；文档核实和本机执行是两种状态。
- 执行/接入会话：读 [livelink_matlab_workflow.md](references/livelink_matlab_workflow.md)。复用成功连接，不猜端口/密码，不自动新建服务器。
- 写 MATLAB、处理数据或并行：读 [matlab_r2023a_guidelines.md](references/matlab_r2023a_guidelines.md)。
- 建模、求解、数值验收：读 [modeling_and_solver_guidelines.md](references/modeling_and_solver_guidelines.md)。
- 发生错误：读 [troubleshooting.md](references/troubleshooting.md)，并检索共享 [known_issues](C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/known_issues.md) 和 [validated_solutions](C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_solutions.md)，以及当前项目已有知识记录。

## 任务执行流程

1. 明确目标、输入 MPH、参数范围/单位、输出指标、物理场、边界、求解类型、资源预算与验收标准。缺失会影响研究结论的信息必须询问；不阻塞无依赖的文件检查。
2. 对已有模型先检查结构和关联。复制输入到独立运行目录，记录哈希；检查后复用已有组件/选择/Study/Solver，不擅自重建。
3. 给出采用的 5.6 API、将修改的节点、求解步骤和输出文件。研究假设、材料/载荷/边界、网格和收敛策略的取舍先讨论；明确授权后不重复询问。
4. 代码采用函数与 cfg 集中参数，明确路径和作用域。用 `try/catch` 保留 `getReport(...,'extended','hyperlinks','off')`；不 `savepath`，不 `ModelUtil.clear()`，不默默吞异常。
5. 用 [run_matlab.ps1](scripts/run_matlab.ps1) 的 PrepareConnected 模式先建立运行包，或按已经明确提供且核实的连接脚本接入。Standalone 只适用于不需 LiveLink 的任务；它不会继承另一个 MATLAB 进程的连接。
6. 进入已连接会话后，用 [matlab_entry_template.m](scripts/matlab_entry_template.m) 执行已授权任务函数 `(cfg,runDir)`。模板本身不连接、不载入或创建模型。示例见 [examples](examples/README.md)。
7. 主动读取完整 stdout/stderr、MATLAB 异常、可获得的 Server/Solver 日志、状态与输出；长任务观察 `matlab_status.json` 的 stage 和日志，不能仅等待用户贴报错。不能获得的日志明确标 UNAVAILABLE，不能伪造空日志为成功。
8. 验收以用户标准为准：确认求解完成、变量、NaN/Inf、单位、维度与物理一致性；模板要求任务回传验证证据。程序完成但未验收只标 COMPLETED_UNVALIDATED。

## 模型与自动执行安全

所有示例为 **DOC_VERIFIED / RUNTIME_NOT_TESTED**，需传入经过检查的真实 tags、参数和选择，不能直接批量运行。必须在工作副本上操作，不覆盖原始 MPH。求解、几何/网格重建与物理修改需落在用户授权范围内。默认串行；并行前核对许可证、各 worker 独立会话和输出冲突。

运行目录保存 input/source/logs/output 与状态，源代码和输入有快照。Template 只在认证已经结束后开始日志；不记录登录输入，不把密钥放入 cfg。不要捕获凭据窗口，不修改登录文件。

## 错误诊断与修复

先按 Windows 启动、MATLAB、连接认证、Java、API/节点、许可证、求解器、结果提取定位。保存完整失败证据，检索既有案例；区分事实和推断。常规代码修复可自主进行，修复后在新目录复跑并比较。禁止通过无依据调整物理条件来让程序“成功”。涉及管理员/系统配置/网络/许可证的操作先解释并取得批准。

## 知识库维护与协作

共享知识库 `C:\Users\14289\Documents\Codex\COMSOL_MATLAB_Knowledge\knowledge` 的五个文件各负其责；项目特定结果与完整日志仍留在当前项目：known_issues 记录现象，debugging_history 记录包括失败尝试的过程，validated_solutions 只收录实测可复核方案，api_usage_notes 标明文档/实测层级，decision_log 保存选择与影响。按问题编号、日期、版本、场景、原始错误、原因证据、修改、验证、边界、代码/日志位置记录，先去重后追加，保留旧记录。

三种状态不得混淆：OPEN（已发现）→ PROPOSED（修复待验证）→ VALIDATED（实测通过）。用户报告连接成功可以保留事实，但在缺少实际命令/日志时不生成可复用连接配方。结束时给出修改、证据、失败/限制和下一步；科研结果与预期冲突时先讨论。
