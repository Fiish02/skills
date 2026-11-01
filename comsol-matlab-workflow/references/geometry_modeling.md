# MATLAB参数化与COMSOL几何建模

模式A直接使用COMSOL几何内核，不需要外部CAD。MATLAB负责坐标/参数，COMSOL负责构造实体、布尔和分区。支持按文档研究1D/2D/3D、线/圆弧/曲线、面、实体、多区域与变厚度结构；这不是宣称所有几何已经实测。

## 曲梁、ABH和阻尼层流程

先与用户确定中心线、厚度幂律、残余厚度、单位、偏置方向、覆盖范围和层间连接。MATLAB采样中心线与法向，计算上下表面及独立阻尼轮廓；先查重合点、正厚度、闭合、自交和偏置失效。采样数做几何收敛，不指定通用点数。2D可用已核对Polygon的source=vectors、x/y、type=solid；3D应按真实截面/扫掠方案查官方文档，不把2D solid轮廓直接当3D实体。
插值/参数曲线与离散轮廓按平滑性、尺寸误差、可构建性选择；弧线、分区和最终Union/Assembly取决于界面物理，不能默默合并材料区。

## 构建后验收

geom.run成功后核对维度、实体数、包围尺寸、连续性/自交/小区域、材料区分离与接口。属性/坐标映射或命名选择须检查结果，不能默认固定ID。1D getNVertices+mphgetcoords只在现有区间案例实测。几何改变后重查材料、载荷和边界关联。

## 本机5.6章节卡片

以下是本轮静态读取的API页索引和短Syntax；不是运行通过声明。实际调用示例见examples中的Rectangle/Polygon模板，其属性已在对应页核对，仍PENDING运行。

### Block

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.061.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Block"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Circle

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.063.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Circle"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Compose, Union, Intersection, Difference

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.068.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Compose"); model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Union"); model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Intersection"); model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Difference"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).selection( property ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Cylinder

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.077.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Cylinder"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### InterpolationCurve

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.098.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"InterpolationCurve"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ) model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).importToTable(); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).importData(); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Interval

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.099.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Interval"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### LineSegment

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.100.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"LineSegment"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### ParametricCurve

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.110.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"ParametricCurve"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).importData(); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Point

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.117.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Point"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Polygon

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.118.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Polygon"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Rectangle

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.121.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Rectangle"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### Sphere

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.127.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> ,"Sphere"); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).set( property , <value> ); model.component( <ctag> ).geom( <tag> ).feature( <ftag> ).get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

### UnionSelection, IntersectionSelection, DifferenceSelection, ComplementSelection

- 版本COMSOL5.6；DOC_CONFIRMED / RUNTIME_NOT_TESTED。
- 官方本机章节：`D:\Program Files\COMSOL\COMSOL56\Multiphysics\doc\help\wtpwebapps\ROOT\doc\com.comsol.help.comsol\comsol_api_geom.44.134.html`。
- 对象/输入/调用顺序（原章节Syntax，实际占位符需替换）：` model.component( <ctag> ).geom( <tag> ).create( <ftag> , "UnionSelection" ); model.component( <ctag> ).geom( <tag> ).create( <ftag> , "IntersectionSelection" ); model.component( <ctag> ).geom( <tag> ).create( <ftag> , "DifferenceSelection" ); model.component( <ctag> ).geom( <tag> ).create( <ftag> , "ComplementSelection" ); model.component( <ctag> ).geom( <tag> ).feature().set( property,<value> ); model.component( <ctag> ).geom( <tag> ).feature().get Type ( property ); `。
- create/set/run改变几何状态；不返回科研数值；属性值/维度/选择必须阅读该页表格后决定，未核实属性标PENDING。

选择集合的UnionSelection与几何实体的Union不是同一操作；实体布尔操作见comsol_api_geom.44.068.html，分区见comsol_api_geom.44.113.html。本轮已读两页Syntax；输入selection、保留内部边界/对象及修复容差需按研究方案填写，不预设。手册中的get Type排版是类型占位表达，不能逐字作为MATLAB方法复制。


## 强制参数入口补充（2026-11-01）

config/model_config.m是唯一设计源；表达式几何引用同步全局参数，MATLAB坐标几何每次重新计算后再更新/构建。单改COMSOL参数不会更新旧Polygon坐标。实际A/B验证需单独批准，见parameter_management.md。