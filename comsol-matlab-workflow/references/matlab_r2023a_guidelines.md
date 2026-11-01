# MATLAB R2023a 编程规范

证据入口见 official_documentation；文档抓取失败项保留状态，不假定最新 API 可用。

- 函数显式接收 cfg、runDir、model，不依赖 base workspace。参数在 cfg 集中管理；不要 clear all、eval 任意输入或自动修改默认 path。
- 使用 `fullfile` 构造路径；文件写入前检查存在性，源文件先快照。`fopen` 检查 fid<0，使用 UTF-8 与 onCleanup 关闭句柄。并发运行不共享输出目录。
- COMSOL Java 调用保留模型对象类型；接口 tags 转 char/cell 时注意 Java 数组，不把 model 对象写 JSON。classpath 变化须来自现有连接方式，不重复 javaaddpath 或混用多个 COMSOL jar 版本。
- 矩阵 `A*B` 要求内维匹配；逐元素操作与矩阵运算不能混淆。用 size 与物理变量维度验证，避免隐式扩展生成意外矩阵。
- COMSOL 结果可能是复数，不能默认 real 或 abs 后当原始物理量；约定幅值/相位/RMS 与时间因子。先检查实部与虚部中的 NaN/Inf，再做 JSON 编码。
- `try/catch ME` 保存 getReport 的 extended/hyperlinks off 输出并 rethrow；不同阶段分别标记，不把许可证、Java 或求解错误混为同一问题。
- 串行参数扫描先验证。parfor 迭代要独立；共享同一个 Java model/连接的循环不是可直接并行的方案。启用并行前另核对 PCT、COMSOL 许可、内存和每个 worker 的独立会话配方。
- 图像用 exportgraphics 等 R2023a 已有函数；必须同时保留原始数组、坐标、单位、参数、dataset、solution selector，不能只留图片。
- 每个任务函数返回 validation.status、非空 checks 与 metrics；不能把 exit code 0 作为模型验收。
- 旧 Phase 2.1 的 Java=1.8.0_202，777 个 classpath 条目只是独立进程快照，不应硬编码成后续连接会话必须相同的类路径长度。
