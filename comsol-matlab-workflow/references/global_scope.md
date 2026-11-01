# 全局范围、项目目录与知识库

此 Skill 安装在当前 Windows 用户的 `C:\Users\14289\.agents\skills\comsol-matlab-workflow`，供该用户的不同 Codex 项目发现。它不安装 COMSOL 或 MATLAB，也不意味着 Mac 上自动可运行 Windows 软件。

## 目录分工

- Skill 安装目录：规则、references、examples、scripts 和 assets；不存放新科研模型、运行结果或每项目日志。
- 当前项目：当前任务工作目录，或 run_matlab.ps1 的显式 `-ProjectRoot`；默认结果目录为该项目的 results。必须先确认实际工作目录，不能把用户主目录或 Skill 的上级目录当成科研项目。
- 共享知识库根：`C:\Users\14289\Documents\Codex\COMSOL_MATLAB_Knowledge`。其 knowledge 保存五类跨项目记录，evidence 保留初始化时的历史证据。原项目记录与证据保留，迁移副本不改变原文件。
- 项目已有 AGENTS.md 与知识文件继续适用。不要自动覆盖它们或将全局规则强写入所有项目。项目专有研究结果保留本项目，共享知识只追加可复用经验及证据位置。

## 执行规则

`run_matlab.ps1 -ProjectRoot <明确的项目目录>` 可从任意当前目录调用。未传入时使用启动 PowerShell 的当前目录，不从 Skill 路径推算。PrepareConnected 仍是默认模式；不自动创建连接、服务器或认证，不重做基础兼容性检查。

共享知识继承原证据层级：用户实际连接结果为 PASS；候选官方快捷方式已发现；该快捷方式是否为成功会话来源、无桌面联合启动仍待验证。不得因全局安装扩大验证范围。

未来其他 Windows 账号、主机或软件路径变化时，先记录实际环境并按授权适配；这些路径不视为所有机器的默认事实。不得在 Mac 直接执行本 Skill 的 Windows 程序。

## 跨项目记录格式

记录问题编号、日期、版本、场景、原因证据、修改、验证、适用范围，以及完整的项目路径/run ID/日志位置。只有实测可复核方案进入 validated_solutions。没有文件写权限时读取现有记录，将新增草稿保存在当前可写项目并说明待合并，不改系统配置解决权限。


## 2026-11-01 全局发现与本次归档
本次会话提供的可用Skill目录、用户显式调用路径与文件系统均指向 `C:/Users/14289/.agents/skills/comsol-matlab-workflow`；其目录及父级检查无符号链接/Junction目标。用户 `.codex/skills` 只有系统Skill子目录；当前项目及扫描到的插件位置未发现第二份同名有效SKILL.md。实际配置无该Skill的禁用项。检查范围和哈希见共享知识库更新报告，不能据此宣称扫描过全盘或验证过新会话自动触发。

OpenAI官方[本地Skill发现说明](https://developers.openai.com/codex/skills/)列出用户 `$HOME/.agents/skills` 与项目 `.agents/skills` 范围；此处以当前会话目录和实际文件核对为决定依据。项目根继续取当前工作目录，不从全局Skill路径推导。

主知识库仍为 `C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge`。新增[Case 4详细记录](<C:/Users/14289/Documents/Codex/COMSOL_MATLAB_Knowledge/knowledge/validated_2d_abh_frequency_domain.md>)与`update_reports/global_skill_upgrade_report.md`均放在此主库；Skill只建立链接，不复制出第二套同名知识。此次只增量编辑文档，不改变scripts/examples执行逻辑，不新建同名已安装Skill。
