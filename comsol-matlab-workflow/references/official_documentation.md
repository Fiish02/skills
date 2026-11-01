# 官方文档索引

核对日期：2026-11-01。先读本机文档，本索引不是完整手册学习完毕的声明。

## COMSOL 5.6 本机来源

根目录 `D:\Program Files\COMSOL\COMSOL56\Multiphysics`。

| 资料 | 本机位置（相对安装根目录） | 用途 |
|---|---|---|
| LiveLink User's Guide | `doc\pdf\LiveLink_for_MATLAB\LiveLinkForMATLABUsersGuide.pdf` | 连接、MATLAB 函数、模型与结果 |
| Programming Reference | `doc\pdf\COMSOL_Multiphysics\COMSOL_ProgrammingReferenceManual.pdf` | ModelUtil、组件、几何/网格、物理、Study/Solver、Results |
| Reference Manual | `doc\pdf\COMSOL_Multiphysics\COMSOL_ReferenceManual.pdf` | 物理建模、数值求解与命令行背景 |
| Release Notes | `doc\pdf\COMSOL_Multiphysics\COMSOL_ReleaseNotes.pdf` | 5.6 变化、向后兼容；使用其中 LiveLink 章节 |
| HTML 帮助 | `doc\help\wtpwebapps\ROOT\doc` | 可直接搜索的精确章节，本文 API 索引以它为主 |
| API JavaDoc | HTML 根下 `com.comsol.help.comsol\api\com\comsol\model` | 核对接口方法、输入类型和返回类型 |
| Application Libraries | `applications\COMSOL_Multiphysics`、`applications\LiveLink_for_MATLAB`、`applications\Structural_Mechanics_Module`、`applications\Acoustics_Module` | 先核查 5.6 随附教程及所需模块；本次只确认目录存在，未加载模型 |

官方在线入口：[LiveLink 5.6](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/LiveLinkForMATLABUsersGuide.pdf)、[Programming Reference 5.6](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/COMSOL_ProgrammingReferenceManual.pdf)、[Reference Manual 5.6](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/COMSOL_ReferenceManual.pdf)、[5.6 Release Notes](https://cdn.comsol.com/doc/5.6.0.401/COMSOL_ReleaseNotes.pdf)。PDF 页码随版次可能不同，优先用下表精确 HTML 章节和标题。

[Application Gallery](https://www.comsol.com/models) 是跨版本的当前模型库，不是锁定 5.6 的库。下载前核对模型版本、对应说明、模块和 license；不能把新版本 MPH 能被 5.6 打开当作事实，也不将教程参数作为研究模型的默认参数。

## MATLAB R2023a 来源

本机根 `D:\Program Files\MATLAB\R2023a`，`help\matlab` 有主题索引，但本次检查未找到所需的完整主题 HTML。对应函数本机帮助/源文件可辅助核对，优先官方 R2023a 归档：

| 主题 | R2023a 官方入口 | 本次访问状态 |
|---|---|---|
| Command-line | [matlabwindows](https://www.mathworks.com/help/releases/R2023a/matlab/ref/matlabwindows.html) | 已读取：-wait、-sd、-batch |
| Scripts / Functions | [function](https://www.mathworks.com/help/releases/R2023a/matlab/ref/function.html) | 网页抓取失败；索引待补核，不借用最新页替代 |
| Matrix Operations | [mtimes](https://www.mathworks.com/help/releases/R2023a/matlab/ref/mtimes.html) | 已读取：矩阵乘法与维度条件 |
| File I/O | [fopen](https://www.mathworks.com/help/releases/R2023a/matlab/ref/fopen.html) | 已读取：编码、permission、-1 错误返回 |
| Exceptions | [try/catch](https://www.mathworks.com/help/releases/R2023a/matlab/ref/try.html) | 已读取；保留 MException，不把失败改成零值 |
| Exception report | [getReport](https://www.mathworks.com/help/releases/R2023a/matlab/ref/mexception.getreport.html) | 网页抓取失败；本机历史探测模板使用过此调用，但异常分支未触发，不能称异常路径已实测 |
| Parallel | [parfor](https://www.mathworks.com/help/releases/R2023a/parallel-computing/parfor.html) | 已读取：worker 迭代需独立；工具箱授权另核实 |
| Visualization | [exportgraphics](https://www.mathworks.com/help/releases/R2023a/matlab/ref/exportgraphics.html) | 已读取：导出图形，需另保存数值 |
| Java Interface | [javaclasspath](https://www.mathworks.com/help/releases/R2023a/matlab/ref/javaclasspath.html) | 网页抓取失败；该命令的 -all 查询有本机历史 PASS 证据 |
| Structured logs | [jsonencode](https://www.mathworks.com/help/releases/R2023a/matlab/ref/jsonencode.html) | 已读取；不要用 JSON null 隐藏 NaN/Inf，数值先检查 |

API 每条记录应包含版本、章节、输入/输出、前置条件、最小调用与限制，见 `comsol_56_api_reference.md`。网页不可访问必须记失败，不将链接存在当作已阅读。后续新增具体物理特征类型时再按需核对对应模块手册。
