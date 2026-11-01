# 复用现有连接与运行协议

## 当前事实与证据

- **连接状态 PASS（USER_EXECUTED / USER_REPORTED）**：用户在成功连接的 MATLAB 窗口执行 version('-release')、matlabroot、mphversion、which mphstart -all，得到 2023a、D 盘 R2023a 根、COMSOL 5.6 (Build 280) 及 COMSOL56 mli 路径。本次不重测。
- 当前目录的历史日志仅覆盖 Phase 2.1；用户最新提供的实际连接结果是新增证据，不能倒填为历史 Task 002 的执行结果。结构化记录见 connection_profile.json。
- 已发现候选入口：C:\ProgramData\Microsoft\Windows\Start Menu\Programs\COMSOL Multiphysics 5.6\COMSOL Multiphysics 5.6 with MATLAB.lnk；Target 为 D:\Program Files\COMSOL\COMSOL56\Multiphysics\bin\win64\comsolmphserver.exe，Arguments 为 matlab，WorkingDirectory 为安装根目录。本次只读核对匹配；尚未确认它是成功会话来源，不自动执行。
- mphstart.p 优先于同目录 mphstart.m；.m 的 Shadowed 状态在此情形正常，禁止删除任一文件来“修复”。
- 不执行历史 preflight 中尚未验证的 -mlroot/port/auth 组合，也不修改 Preferences/pathdef/注册表。当前无 MATLAB/COMSOL 进程的检查结果只是时间点快照。

## 两条统一入口

`scripts/run_matlab.ps1` 默认 **PrepareConnected**：创建独立 run 目录、快照和上下文，生成 `invoke_in_existing_session.m` 与 `invoke_command.txt`。在用户既有的已连接 MATLAB R2023a 窗口执行其中命令。入口通过只读 `ModelUtil.tags()` 检查现有连接，然后执行任务；不 mphstart，不创建服务器，不登录、不自动断开。外部 Codex 可以读取 run_status.json、matlab_status.json 和日志；没有会话控制工具时不谎称已自动提交。

**Standalone** 模式只用于独立 MATLAB 数据/文件处理，以 Task 002 验证的完整 R2023a 可执行路径和 -wait/-sd/-batch 形态启动。它不是 COMSOL 连接替代方案。新 runner 的 Standalone 合成任务成功路径和异常路径已实际验证，见 evidence/workflow_infrastructure；这不验证 COMSOL 分支、模型或连接自动化。

未来归档连接配方时记录：Windows 主机、成功脚本/快捷方式位置与哈希、实际命令、版本、参数传递接口、认证交互、许可影响、隔离方式、日志位置和用户授权范围。密码只能由用户在交互界面输入。若需要管理员、注册表、网络或许可变化，先说明并等待批准。现有配方未明确前，不实现自动服务启动 adapter。

## 任务函数协议

函数签名 `result = taskFunction(cfg, runDir)`，代码不得向 cfg 放凭据。cfg 由集中 JSON 输入，示例函数须在该任务函数中显式调用。result 应含：

```matlab
result.validation.status = 'PASS'; % 仅在所有已定义验收条件都实际通过后
result.validation.checks = {'具体验收项目与数值证据'};
result.metrics = struct();        % 关键数值；另存单位/解编号等元数据
```

缺 validation 或没有非空 checks 的任务只能 COMPLETED_UNVALIDATED。失败必须抛异常，模板会保存扩展堆栈并重抛。禁止任意 catch 后填零作为成功。不要用此入口执行认证；认证必须在 diary 之前完成。

## 日志、状态与收尾

每个 run 有 input/source/logs/output、isolated matlab_prefs/tmp、run_context.json、run_status.json。MATLAB 另写 matlab_status.json，避免与外部 runner 同时写一个文件。PrepareConnected 的真实进程 stdout/stderr 无法由另一个窗口重定向，标 UNAVAILABLE；有 MATLAB diary，不把 diary 冒充操作系统流。

stdout/stderr 以原始进程字节保存；中文控制台编码不一定是 UTF-8，错误文本另有 UTF-8 matlab_error.txt 和 JSON，读取时不要覆盖原始流。外部 PowerShell 的返回值是结构化记录，调用方必须看 status 和 exit_code，不能仅看父 PowerShell 退出码。

Server 日志不自动读取未知安装/用户位置，不收集 login.properties。用户给出已知不含凭据的 Server 日志路径后，另行快照并注明来源。Solver 日志由已连接模板的 `ModelUtil.showProgress(filename)` 请求，失败时标 UNAVAILABLE，保留原因；不靠日志存在判断求解成功。

任务结束保留原会话，模板不 disconnect、clear 或 remove 用户模型，不抢占其他会话。停止/中断共享会话前核实归属并与用户沟通。

全局安装的共享知识路径和项目目录规则见 [global_scope.md](global_scope.md)。


## 当前默认策略（2026-11-01修订）
历史已连接GUI中真实PDE成功，不保证此刻仍连接。常规科研任务只需复用该工作方式并在执行窗口查询release/root/mphversion；无连接则请用户按其已验证方式建立后等待。不将无人值守/Server网络认证作为必要前置。
命令行帮助已成功采集：D:/test/comsol-matlab-workflow-unattended/run_20261101_140524/phase1_help_review.md。mlroot/port/portfile/prefsdir等为HELP_CONFIRMED，不是安全服务运行通过；仅回环绑定及无交互认证尚未确认，端到端Batch未执行。OPTIONAL / OUT OF SCOPE，旧自动化笔记保留但不得阻塞已连接科研仿真。


## 强制参数入口补充（2026-11-01）

参数化不改变连接协议。先从集中配置生成独立run和实际配置/源码快照、parameters.json；同步回读通过后才建模。历史GUI输入授权不等于本轮文档任务获准新仿真。

## 已执行的现有Server连接恢复（2026-11-01，VS-011证据）
ABH首次会话mli可解析但ModelUtil Java不可见，mphversion失败；先诊断而非盲目开服务。用户明确批准后，在现有R2023a执行mphstart(address,port,COMSOL安装根)，连接已核实的既有服务，之后mphversion核对5.6 Build280且ModelUtil.tags成功，再进行建模。证据：[报告](<D:/test/comsol-matlab-workflow-abh-curved-beam-test/run_20261101_190839_544_63b3c800-2823-47ea-8ea4-c25f824036b3/report.md>)及其logs/server_connection_status.json。
127.0.0.1:2036、Server PID26924和MATLAB PID21036只记录当时事实，不作为下次默认值。每次先查实际路径/服务/端点；改变连接状态须遵循授权，不自动重连/新建Server。mli存在与GUI打开不证明LiveLink已初始化；类缺失本身也不证明网络/许可证根因。认证与diary分开，不读login.properties，不记录账户/许可密码，不改Preferences/pathdef/注册表/环境变量。
此为一次本机连接恢复记录，不是跨环境自动重连配方；窗口输入方法也依赖前台/布局，不升级为无人值守通用能力。


## Case 4：既有会话提交与日志的有限实测
历史[Case 4](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)通过已运行窗口查询release/root/mphversion确认连接，Windows原子Unicode SendInput提交到已核实PID和主窗口；慢速SendKeys/定向WM_CHAR及COM附加尝试未形成可靠执行回执。提交成功不等于执行成功，必须读取实际状态/产物。历史PID、窗口句柄和端口不能作下次默认；焦点控制依赖交互桌面，不能升级无人值守Batch能力。
本案例showProgress(String)无返回值形式实际写出原生求解进度，但未增加完整关闭/异常收尾验证。键盘中断在原生求解返回后才生效，旧RUNNING状态可能陈旧；必须结合原生日志和实际解判断，不能杀共享进程或将恢复导出称为新求解。文档升级不执行这些操作。
