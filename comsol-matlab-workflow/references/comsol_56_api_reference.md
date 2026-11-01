# COMSOL 5.6 API 关系与调用卡片

证据层级：本文件为 DOC_VERIFIED（本机 5.6 HTML 已核对），所有下面的模型调用仍为 RUNTIME_NOT_TESTED；未执行科研模型。最小调用是有前置条件的片段，不是可独立求解的通用模型。

关系：已连接 MATLAB → ModelUtil/模型引用 → 全局参数与组件 → Geometry/Physics/Materials/Mesh → Study 控制求解问题 → Solver 计算解 → Results dataset → mphglobal/mphinterp/mpheval 数值。参数变更会使几何、网格或解失效，依赖范围由实际模型决定。

HTML 本机根：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc`；所有条目版本均为 **5.6**。

## mphstart

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：port，或 address/port/comsolpath；不要把密码写进调用。
- 输出：无模型返回；建立当前 MATLAB 连接。
- 使用条件：已有服务；端口/认证必须来自现有工作方式。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.53.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.53.html`。
- 限制：仅当已有方案明确需要手动连接才使用；默认端口不是现有连接证据。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
mphstart(port);
```

## mphload

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：filename，可选 mtag。
- 输出：model；可选解析后的 filename。
- 使用条件：当前会话已连接；输入为运行副本。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.28.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.28.html`。
- 限制：相同 model tag 可能替换服务端对象；先用 ModelUtil.tags 核对。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model = mphload(workCopy, uniqueTag);
```

## mphsave

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：model，filename。
- 输出：无返回；写文件。
- 使用条件：模型有效；明确新文件路径。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.46.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.46.html`。
- 限制：不使用省略 filename 的写法；保存新文件可能仍改变模型关联路径。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
mphsave(model, newOutputFile);
```

## mphversion

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：无参数或 model。
- 输出：v 字符串；传 model 时可得 vm。
- 使用条件：当前会话已连接。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.59.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.59.html`。
- 限制：版本字符串成功不能单独取代完整任务验收。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
v = mphversion;
```

## mphinterp

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：model，expr cell，coord(sdim×N)，dataset，solnum/时间。
- 输出：每个表达式数值，最后可选 unit。
- 使用条件：已求解且数据集可用。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.25.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.25.html`。
- 限制：T 是有温度变量的模型条件示例；坐标行列、选择维度和单位必须核对。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
[v,u] = mphinterp(model, {'T'}, 'coord', xyz, 'dataset', dset);
```

## mphglobal

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：model，表达式 cell，dataset/solnum/outersolnum。
- 输出：各表达式数值，末项 unit cell。
- 使用条件：已求解；表达式须是有效全局量。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.21.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.21.html`。
- 限制：域场不自动变成全局量；外层参数解与内层频率/时间/模态需区分。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
[v,u] = mphglobal(model, {globalExpr}, 'dataset', dset);
```

## mpheval

- 对象/函数：`LiveLink function`；版本：5.6。
- 输入：model，expr cell，dataset，edim 等。
- 输出：pd struct：expr,p,t,ve,unit,d1…dn。
- 使用条件：已求解；表达式与选择存在。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.llmatlab/llmatlab_ug_ref.9.09.html)；本机相对路径 `com.comsol.help.llmatlab\llmatlab_ug_ref.9.09.html`。
- 限制：显式核对 complexout 与复数处理，不假设文档概述中的实部描述等于所有选项的行为。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
pd = mpheval(model, {fieldExpr}, 'dataset', dset);
```

## ModelUtil

- 对象/函数：`com.comsol.model.util.ModelUtil`；版本：5.6。
- 输入：tags() 无输入；model(tag)；hasProduct(product)。
- 输出：tags 列表；model 引用；授权布尔值。
- 使用条件：已连接，Java 类可用。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.13.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.13.html`。
- 限制：create(tag) 会替换同名对象；clear() 删除所有模型，工作流禁止使用；hasProduct 不是永久席位保证。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
tags = ModelUtil.tags();
```

## Parameters

- 对象/函数：`model.param()`；版本：5.6。
- 输入：get(name)，set(name,expr)，varnames()。
- 输出：get 返回表达式；evaluate 返回数值；set 为状态变更。
- 使用条件：模型副本；用户批准参数名与表达式。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.49.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.49.html`。
- 限制：表达式含单位，不能把任意数据强制转换为无单位；保留原值以便审查。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
old = char(model.param().get(name));
```

## Component

- 对象/函数：`model.component()`；版本：5.6。
- 输入：component(ctag)，create(tag,true)。
- 输出：组件引用；创建改变模型。
- 使用条件：已检查组件 tags。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.22.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.22.html`。
- 限制：不要假设组件叫 comp1；创建需授权和唯一 tag。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
c = model.component(ctag);
```

## Geometry

- 对象/函数：`component.geom()`；版本：5.6。
- 输入：geom(gtag)，run()。
- 输出：几何引用；run 更新几何。
- 使用条件：几何 tag 存在；重建已获批准。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.34.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.34.html`。
- 限制：几何变化可能使边界编号/选择失效；重查关联而非继续使用旧编号。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model.component(ctag).geom(gtag).run();
```

## Mesh

- 对象/函数：`component.mesh()`；版本：5.6。
- 输入：mesh(mtag)，run()。
- 输出：网格引用；run 更新网格。
- 使用条件：网格 tag 存在；策略经批准。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.40.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.40.html`。
- 限制：重建网格不代表网格收敛；不擅改 autoMeshSize 或单元阶次。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model.component(ctag).mesh(mtag).run();
```

## Physics

- 对象/函数：`component.physics()`；版本：5.6。
- 输入：physics(ptag).feature(ftag).set(prop,val)。
- 输出：特征引用；set 改变模型。
- 使用条件：接口/特征/选择已检查；物理方案经批准。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.50.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.50.html`。
- 限制：feature type、property、entity dimension 取决于模块和物理接口，不能通用猜测。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
feature = model.component(ctag).physics(ptag).feature(ftag);
```

## Study

- 对象/函数：`model.study()`；版本：5.6。
- 输入：study(stag).run() 或 runNoGen()。
- 输出：更新模型解状态，无科研结果直接返回。
- 使用条件：study tag、类型与运行范围获批准。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.59.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.59.html`。
- 限制：run 可能生成求解序列；runNoGen 使用已挂接序列；不能自动互换作为修复。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model.study(stag).runNoGen();
```

## Solver

- 对象/函数：`model.sol()`；版本：5.6。
- 输入：sol(stag).runAll()，isEmpty()。
- 输出：runAll 更新解；isEmpty 布尔。
- 使用条件：solver tag 与依赖已检查；允许求解。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.57.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.57.html`。
- 限制：isEmpty=false 只证明有解数据，不能证明其对本次参数有效或已收敛。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model.sol(solverTag).runAll();
```

## Results

- 对象/函数：`model.result()`；版本：5.6。
- 输入：result(plotTag).run()；numerical(tag).run()。
- 输出：绘图或评估更新状态。
- 使用条件：结果节点/数据集与解匹配。
- 章节：[同名官方 HTML](https://doc.comsol.com/5.6/doc/com.comsol.help.comsol/comsol_api_general.43.53.html)；本机相对路径 `com.comsol.help.comsol\comsol_api_general.43.53.html`。
- 限制：图像成功不是数值通过；先核实 dataset 与 solution 的映射，再提取物理量。
- 最小调用（变量由已检查的模型/任务给定）：

```matlab
model.result(plotTag).run();
```

## 示例补充方法依据

Physics 示例使用的标量字符串读取 `feature.getString(property)` 已核对本机 5.6 JavaDoc：`com.comsol.help.comsol/api/com/comsol/model/PropFeature.html#getString-java.lang.String-`。它不适用于向量或数值属性；不匹配会在 set 之前报错，不自动换类型。

## 尚不能通用指定的参数

具体 Physics 特征类型、材料属性组与键、边界选择、Study 类型的特定属性、求解容差和评价表达式，必须从原模型及 5.6 对应模块文档获取。禁止把教程的 solid/acpr/freq 等名称直接移植为任意模型的事实。所需字段见 examples 的显式参数。
