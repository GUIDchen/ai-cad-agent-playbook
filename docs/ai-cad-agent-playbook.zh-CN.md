# AI 智能体驱动的 CAD 智能画图应用
## 技术可行性调研、调用方案与落地难度评估

> 版本：v1.0　编写日期：2026-10-21
> 对应岗位场景：**AI 智能体应用工程师**（西安 · 矿山安全设备行业 · 1–3 年经验）
> 文档定位：把岗位需求里“精通 AI 智能体搭建”“精通数据备份”“协助开发 SolidWorks / AutoCAD / AD24 / AI 绘画的智能画图应用”这三条，还原成可执行的工程方案，并给出难度、工期、成本与风险判断。

---

## 0. 一页结论（先看这里）

### 0.1 结论速览

| JD 能力项 | 用现成 AI 工具能否实现 | 推荐实现方式 | 难度 | 单人做出可用 MVP |
|---|---|---|---|---|
| AutoCAD 智能画图 | **能，可做到生产可用** | 大模型 + COM / DXF + 参数化模板 + MCP 工具层 | ★★☆ | 4–6 周 |
| SolidWorks 智能建模与工程图 | **能，但限定在系列化、模板化产品** | 大模型 + COM API（或 `solidworks-mcp`）+ 几何回读校验 | ★★★★ | 8–12 周 |
| Altium Designer 24 智能画图 | **只能局部实现**（脚本、检查、BOM、批量改图） | LLM 生成 DelphiScript + Altium 365 REST API | ★★★★★ | 3 个月也只到“辅助设计” |
| AI 绘画 / 智能出图 | **能，效果图与说明书插图最成熟** | ComfyUI + ControlNet + LoRA，本地或云 API | ★★★ | 3–4 周 |
| 智能体平台与编排 | 能，属于成熟工程 | Dify / n8n / 自研 Agent + MCP | ★★ | 2–3 周 |
| 图纸理解（存量图纸数据化） | 能到 80–90% 准确率，需人工复核 | VLM + OCR + 规则 + RAG | ★★★ | 6–8 周 |

### 0.2 五条硬结论

1. **“让 AI 直接画图”已经可工程化，但正确姿势不是“文生图 / 文生 CAD”，而是“AI 做决策 + CAD 原生 API 做执行 + 几何校验做闭环”。** 端到端生成 STEP/DWG 的模型（Text-to-CAD 类）目前只能做概念件，尺寸、公差、标准件、制图规范都过不了工程验收。
2. **四个软件里难度排序是：AutoCAD（易）< SolidWorks（中偏难）< AI 绘画（部署易、可控难）< Altium（极难）。** 原因是接口开放程度差异：AutoCAD 有 COM/DXF 两套稳定接口和成熟生态；SolidWorks 的 COM API 完整但特征重建脆弱；Altium 没有官方 AI 接口，脚本生态小、试错成本高（一次打板就是钱）。
3. **真正的瓶颈不在模型，在数据和工艺知识。** 项目 60%–70% 的工作量是“把公司图纸变成机器可读的模板、参数表、图层标准、校验规则”。凡是跳过这一步直接上大模型的，都会得到“看起来对、装不上”的图纸。
4. **JD 的三条要求，实际是三个岗位的活。** 一个人 1–3 年经验、中小厂薪资水平，不可能同时精通智能体平台、备份体系、四套 CAD 的二次开发。合理的落地策略是先选 1–2 个高频场景打穿，其余用现成工具兜底（详见第 10、14 章）。
5. **最快的验证路径是“一周 demo”。** 用现成 MCP 服务器（`autocad-mcp`、`solidworks-mcp`、`freecad-mcp`）+ Dify + ComfyUI，一周内可以跑通“一句话生成一张简单零件图/效果图”，用来判断值不值得继续投入。

---

## 1. 需求还原：JD 原文 → 工程语言

### 1.1 原文摘录

> 1；精通各种 AI 智能体搭建的软件，硬件设施
> 2；精通数据备份软件及硬件应用
> 3；能协助开发各种应用软件实现智能化自动化应用（急需 SolidWorks、autocad、AD 24 电路版设计及 AI 绘画软件的智能画图应用）

### 1.2 逐条翻译

| 原文 | 真实含义（工程语言） | 可交付物 | 验收方式 |
|---|---|---|---|
| 精通各种 AI 智能体搭建的软件、硬件 | 会用 Dify/Coze/n8n/LangGraph 搭工作流；懂 MCP、函数调用；懂本地 GPU 部署 | 内网可用的智能体平台 + N 个工作流 | 业务人员能自助跑通 3 个流程 |
| 精通数据备份软件及硬件 | 3-2-1 备份、NAS/磁带/异地、快照、恢复演练 | 备份策略文档 + 恢复演练记录 | 随机抽一份图纸/模型能 30 分钟内恢复 |
| 协助开发 SolidWorks 智能画图 | 参数化建模、系列件改型、工程图自动出图、BOM | SolidWorks 插件或独立工具 | 输入参数表，输出模型 + 工程图 + BOM，尺寸零错误 |
| 协助开发 AutoCAD 智能画图 | 系统图、接线图、布置图、图纸批量处理、图纸审查 | AutoCAD 插件 / 脚本服务 | 输入 Excel，输出 DWG，图层/标注符合企业标准 |
| 协助开发 AD24 智能画图 | 原理图/PCB 的辅助生成、规则检查、库与 BOM 治理 | Altium 脚本集 / 365 数据接口 | 脚本可一键执行，检查项覆盖企业规范 |
| AI 绘画软件 | 效果图、说明书插图、投标配图、爆炸图美化 | ComfyUI 工作流 + 调用 API | 产品线稿 → 效果图，风格统一，可批量 |

### 1.3 公司画像与场景推断

行业背景：某矿山安全设备企业，未融资，20–99 人，仪器仪表/工业自动化，位于西安。矿山安全设备行业的典型产品形态是**防爆电气、本安电路、传感器、监测监控系统、矿用电源**。

由此推断（**属于推断，需到岗后与工艺/结构/电子工程师确认**）高频图纸场景：

| 场景 | 现状痛点 | AI 可切入点 |
|---|---|---|
| 防爆壳体/本安箱体结构 | 每个项目尺寸变、孔位变，重复建模 | 参数化模板 + 自动出工程图 |
| 系统图/接线图/布置图 | 甲方给 PDF/图片，人工重画 | 图纸识别 → 参数表 → AutoCAD 批量生成 |
| PCB 板卡 | 改型多、器件替换频繁、BOM 易错 | 脚本做 BOM/规则/丝印检查，AI 写脚本 |
| 投标技术方案 | 需要大量示意图、效果图 | AI 绘画 + 模板化版式 |
| 说明书/铭牌/警示标识 | 多语言、多型号 | 模板 + 变量替换（不是大模型的主战场） |

---

## 2. 技术底座：怎么“用现成 AI 工具、通过调用实现”

### 2.1 三种集成范式（决定项目成败的关键选择）

| 范式 | 做法 | 优点 | 缺点 | 适用 |
|---|---|---|---|---|
| A. 提示词直连 | 把需求贴给 ChatGPT/DeepSeek，人工复制结果 | 零开发 | 不可复用、不可审计、无法批量 | 个人提效 |
| B. 函数调用（Function Calling） | 自研程序，把 CAD 操作封装成 JSON Schema 工具，让模型输出调用参数 | 可控、可校验、可嵌入业务系统 | 需要开发 | 生产系统 |
| C. MCP 工具层 | 用 Model Context Protocol 把 CAD 能力做成标准工具服务器，任意 Agent 客户端可接 | 一次开发、多端复用；生态已有现成服务器 | 协议较新，企业内网需自建 | **推荐主力** |

**结论：以 C 为主、B 为兜底、A 只用于探索。** MCP 是 2024 年后事实上的工具接入标准，Claude Desktop、Cursor、Dify（v1.6 起内置双向 MCP）、n8n（MCP Client 节点）都已支持；企业内网自建 MCP Server 没有额外授权成本。

### 2.2 选型清单（2026-10 视角，具体版本以官网为准）

| 层 | 用途 | 候选 | 选型建议 |
|---|---|---|---|
| 文本/推理模型 | 需求理解、参数抽取、代码/脚本生成、流程规划 | DeepSeek（deepseek-chat / reasoner）、通义千问 Qwen-Max、GLM、Kimi、豆包 | 国内合规优先；要私有化就选 Qwen / GLM 开源权重 |
| 视觉模型 VLM | 读图纸、读截图、读 PDF | Qwen-VL-Max、GLM-4V、豆包 Vision、GPT-4o（境外） | 图纸识别用 Qwen-VL 系列，中文标题栏识别更稳 |
| 图像生成 | 效果图、示意图 | 通义万相 Qwen-Image（百炼 API）、即梦/Seedream、FLUX.1、SDXL（本地） | 要可控 → 本地 ComfyUI + ControlNet；要省事 → 云 API |
| 向量/嵌入 | 标准库、图纸知识库 | bge-m3、Qwen3-Embedding | 中文标准文本用 bge-m3 足够 |
| 编排 | 工作流、Agent | Dify、n8n、LangGraph、自研 | 内网交付选 Dify（可离线部署）；复杂状态机选 LangGraph |
| 协议 | 工具接入 | MCP（stdio / SSE / Streamable HTTP） | 内网用 stdio + 本地进程最省事 |
| 本地推理 | 断网环境 | vLLM / Ollama + Qwen3-32B 级模型 | 矿山客户现场常无外网，必须准备离线方案 |

### 2.3 最小可用架构

~~~text
┌──────────────────────────────────────────────────────────────┐
│  交互层：企业微信/钉钉机器人 │ 内网 Web 页面 │ CAD 插件面板      │
└───────────────┬──────────────────────────────────────────────┘
                │ HTTPS / 内网
┌───────────────▼──────────────────────────────────────────────┐
│  编排层：Dify 工作流 / 自研 Agent（Planner + 工具白名单）        │
│  职责：意图识别 → 参数补全 → 任务拆解 → 调用工具 → 结果校验      │
└───────┬───────────────────────┬──────────────────┬───────────┘
        │ MCP / HTTP            │ MCP / HTTP       │ HTTP
┌───────▼────────┐   ┌──────────▼────────┐  ┌──────▼─────────┐
│ AutoCAD MCP    │   │ SolidWorks MCP    │  │ ComfyUI API    │
│ (COM / ezdxf)  │   │ (COM)             │  │ (图像生成)      │
└───────┬────────┘   └──────────┬────────┘  └──────┬─────────┘
        │                       │                  │
   AutoCAD 进程            SolidWorks 进程       GPU / 云
        │                       │
┌───────▼───────────────────────▼──────────────────────────────┐
│  数据层：模板库 │ 参数表(Excel/JSON) │ 图纸库 │ 向量库 │ 审计日志  │
└──────────────────────────────────────────────────────────────┘
~~~

### 2.4 为什么不做“端到端大模型直接生成 CAD 文件”

- **Text-to-CAD 类服务**（如 Zoo/KittyCAD Text-to-CAD）能用自然语言生成 B-rep/网格并导出 STEP，但生成结果偏向“造型”，不保证可制造性、不保证符合 GB 制图规范，也不能复用企业已有的特征树和标准件库。
- **开源 CAD 生成模型**（CAD-Recode、CAD-MLLM、Text2CAD 等）停留在论文与 demo 阶段，擅长简单机械件，装配体与工程图基本不可用。
- **图像生成模型**（SD/FLUX/Qwen-Image）画出来的是“像素”，不是“几何”，不能直接用于生产图纸，**只能用于效果图、示意图、说明书插图**。

因此工程上正确的分层是：

~~~text
自然语言/表格  →  结构化参数（LLM 负责）
结构化参数      →  CAD 操作序列（规则引擎 + 模板，LLM 只做映射）
CAD 操作序列    →  真实几何（CAD 原生 API 负责）
真实几何        →  校验（体积/质量/干涉/尺寸，程序负责）
校验失败        →  回传错误给 LLM 修正（闭环，最多 3 轮）
~~~


---

## 3. 能力域 A：AutoCAD 智能画图（难度 ★★☆，建议第一个做）

### 3.1 可用的调用面

| 接口 | 形态 | 能力 | 稳定性 | 适用 |
|---|---|---|---|---|
| COM / ActiveX | `AutoCAD.Application`，Python(pywin32)/C#/VBA | 几乎全部绘图、编辑、打印 | 高 | **主力** |
| AutoLISP / Visual LISP | `.lsp` 脚本，`command` 调用 | 命令级操作、批量 | 高 | 轻量批处理 |
| .NET API | ObjectARX 托管封装 | 高性能、复杂交互 | 高 | 插件级产品 |
| DXF 文件 | `ezdxf`（Python） | 无 AutoCAD 环境读写 DXF | 高 | 服务器端批处理 |
| DWG 文件 | ODA File Converter + `ezdxf.addons.odafc` | DWG↔DXF 转换 | 中 | 无授权环境 |
| MCP 服务器 | `autocad-mcp`（U-C4N，240+ 工具）、`AutoCAD-MCP`（codesknight） | 自然语言驱动绘图、读图 | 中（社区项目） | 快速验证 |

### 3.2 三条实现路线（按可靠性排序）

**路线 1：参数化模板 + 属性替换（最稳，优先做）**
企业图纸 80% 是“同一套图框 + 同一种拓扑 + 不同参数”。把图做成带属性的块（Block），只替换属性值和少量几何，风险最低、效果最好。

**路线 2：LLM 输出结构化绘图指令 → COM 对象模型执行**
模型不写 LISP、不写脚本，只输出 JSON 指令数组，由程序解释执行。这样模型出错最多是“画错”，不会“执行任意代码”。

**路线 3：自然语言 → `SendCommand` 脚本（最快，但最脆）**
一行 `doc.SendCommand("_LINE ...")` 就能画，但命令是异步的、依赖当前视图和对象捕捉、中文编码易乱，**只能用于 demo，不建议上生产**。

### 3.3 关键代码

**（1）连接 AutoCAD 并绘制标准图元**

```python
# pip install pywin32
import pythoncom
import win32com.client

pythoncom.CoInitialize()                       # COM 必须初始化（STA）
acad = win32com.client.Dispatch("AutoCAD.Application")
acad.Visible = True
doc = acad.ActiveDocument
ms = doc.ModelSpace

# 图层标准化：先建层，再画线，避免"全在 0 层"
if not any(l.Name == "AI_WALL" for l in doc.Layers):
    doc.Layers.Add("AI_WALL")

line = ms.AddLine((0, 0, 0), (6000, 0, 0))    # 单位：图形单位（通常 mm）
line.Layer = "AI_WALL"
ms.AddCircle((3000, 2000, 0), 800)
ms.AddText("防爆接线箱", (1000, 3500, 0), 250)  # AddText(文本, 插入点, 字高)
doc.Rebuild()
```

> 注意：AutoCAD COM 是单线程 STA，多任务时要用独立线程并 `CoInitialize`/`CoUninitialize`；跨进程调用慢，批量操作要合并成一次会话。

**（2）LLM 只输出“结构化指令”，程序执行**

```json
{
  "sheet": {"size": "A3", "scale": "1:50", "title": "防爆接线箱布置图"},
  "layers": ["AI_WALL", "AI_DIM", "AI_TEXT", "AI_HATCH"],
  "entities": [
    {"op": "rect", "layer": "AI_WALL", "p1": [0, 0], "p2": [6000, 4000]},
    {"op": "circle", "layer": "AI_WALL", "center": [3000, 2000], "r": 800},
    {"op": "text", "layer": "AI_TEXT", "at": [1000, 3500], "h": 250, "s": "防爆接线箱"},
    {"op": "dim_linear", "layer": "AI_DIM", "p1": [0, 0], "p2": [6000, 0], "offset": 600}
  ]
}
```

解析器只需实现 10–15 个 op（rect / circle / line / polyline / text / dim_linear / dim_radial / hatch / block_insert / table / leader），就能覆盖大部分系统图与接线图。**指令集越小，模型越不容易出错，校验也越容易做。**

**（3）块属性批量替换（改型号、改参数，最实用的功能）**

```python
def update_title_block(doc, block_name, values: dict):
    for layout in doc.Layouts:
        for ent in layout.Block:
            if ent.ObjectName == "AcDbBlockReference" and ent.Name == block_name:
                for attr in ent.GetAttributes():
                    if attr.TagString in values:
                        attr.TextString = values[attr.TagString]
    doc.Rebuild()
```

**（4）无 AutoCAD 授权时的批处理（ezdxf）**

```python
# pip install ezdxf
import ezdxf
doc = ezdxf.new("R2018", setup=True)          # setup=True 自带标准线型/标注样式
msp = doc.modelspace()
msp.add_lwpolyline([(0, 0), (6000, 0), (6000, 4000), (0, 4000)], close=True,
                   dxfattribs={"layer": "AI_WALL"})
doc.saveas("output.dxf")

# 读写 DWG 需安装 ODA File Converter，然后：
# from ezdxf.addons import odafc
# doc = odafc.readfile("input.dwg")
```

### 3.4 用现成 MCP 服务器（一周 demo 的关键）

`autocad-mcp` 提供 240+ 工具，支持两条后端：**连接本机 AutoCAD（COM）** 或 **无 AutoCAD 的 headless 模式（ezdxf）**。Agent 侧只需按 MCP 协议调用：

```json
// tools/list 返回的工具（节选）
{"name": "draw_line",  "description": "在指定图层画线", "inputSchema": {"type": "object", "properties": {"x1": {"type": "number"}, "y1": {"type": "number"}, "x2": {"type": "number"}, "y2": {"type": "number"}, "layer": {"type": "string"}}, "required": ["x1","y1","x2","y2"]}}

// tools/call
{"jsonrpc": "2.0", "id": 7, "method": "tools/call",
 "params": {"name": "draw_line", "arguments": {"x1": 0, "y1": 0, "x2": 6000, "y2": 0, "layer": "AI_WALL"}}}
```

> 社区 MCP 项目质量参差，建议**先用来验证可行性，再按企业标准自研**（图层规范、图框、字体、打印样式都必须定制）。

### 3.5 难度与坑（AutoCAD）

| 坑 | 说明 | 应对 |
|---|---|---|
| 中文乱码 | SHX 大字体缺失、编码不一致 | 统一字体模板；文本用 Unicode |
| 标注比例 | DIMSCALE / 注释性比例不对，字要么巨大要么看不见 | 图纸模板里预置标注样式，禁止 AI 改样式 |
| 对象捕捉干扰 | `SendCommand` 受 OSNAP 影响 | 执行前 `(setvar "OSMODE" 0)`，或不用 SendCommand |
| 异步执行 | SendCommand 立即返回，后续命令可能错序 | 改为对象模型调用；必须用命令时轮询 `doc.GetVariable("CMDACTIVE")` |
| 外部参照/嵌套块 | 批量处理时漏掉 xref 内的对象 | 建立递归遍历器，先出“影响清单”再改 |
| 版本兼容 | 客户用 2010/2018/2024 | 统一另存为 R2018 DWG |
| 授权 | 网络许可被占用导致 COM 起不来 | 单独一台“出图服务器”跑授权 |

**工期判断：** 单场景（如“Excel 参数 → 接线图 DWG”）4–6 周可交付；做到“图纸审查 + 批量改图 + 打印归档”全流程约 3 个月。

---

## 4. 能力域 B：SolidWorks 智能建模与工程图（难度 ★★★★）

### 4.1 可用的调用面

| 接口 | 说明 | 适用 |
|---|---|---|
| COM API（`SldWorks.Application`） | 官方完整 API，C#/VB.NET/Python 均可调用 | **主力** |
| Add-in（C# 插件） | 嵌入 SolidWorks 界面，响应事件 | 做产品化插件 |
| 宏录制（VBA） | 录一遍人工操作，自动生成 API 调用 | **学习 API 最快的方式** |
| Document Manager API | 不开 SolidWorks 读属性/改属性/转格式 | 批量数据治理 |
| eDrawings API | 轻量查看、批注、测量 | 审图端 |
| MCP：`solidworks-mcp`（PyPI，0.16.x） | 通过 COM 驱动本地 SolidWorks，做参数化零件/装配，**每次建模返回实测体积、质量、包围盒用于自检**，支持 STEP/STL/3MF 导出、截图、工程图 | 快速验证 / 轻量生产 |

### 4.2 实现分层（从稳到不稳）

| 层级 | 做法 | 稳定性 | 覆盖率 |
|---|---|---|---|
| L1 参数表驱动 | Excel/JSON 参数 → 方程式/配置 → 重建 | ★★★★★ | 系列化产品 60–80% |
| L2 特征序列组合 | LLM 选特征 + 给参数 → API 逐步建模 | ★★★☆ | 简单零件 |
| L3 工程图自动出图 | 建视图 + 插入模型尺寸 + 标题栏/BOM | ★★★ | 需模板配合 |
| L4 校验闭环 | 回读体积/质量/干涉/壁厚，与理论值比对 | ★★★★★ | 必须做 |

**核心工程判断：不要指望 LLM 从零“画”一个零件。正确做法是把公司 20–50 个典型件做成参数化模板（方程式 + 配置 + 派生草图），LLM 的职责是“选模板、填参数、检查结果”，而不是“发明几何”。** 这一步做了，成功率从 30% 提到 90%；不做，项目一定失败。

### 4.3 关键代码（骨架，参数以本机 SDK 为准）

```python
import win32com.client as win32
import pythoncom

pythoncom.CoInitialize()
sw = win32.Dispatch("SldWorks.Application")
sw.Visible = True

TEMPLATE = r"C:\ProgramData\SOLIDWORKS\templates\零件.prtdot"
model = sw.NewDocument(TEMPLATE, 0, 0, 0)          # 返回 IModelDoc2

# 1) 选基准面 → 进草图 → 画中心矩形
model.Extension.SelectByID2("前视基准面", "PLANE", 0, 0, 0, False, 0, None, 0)
model.SketchManager.InsertSketch(True)
# 注意：SolidWorks API 长度单位是"米"，120 mm 宽 → 半宽 0.06
model.SketchManager.CreateCenterRectangle(0, 0, 0, 0.06, 0.04, 0)
model.SketchManager.InsertSketch(True)              # 退出草图

# 2) 拉伸：参数多达 20+ 个，务必用"宏录制 → 替换数值"生成，不要手写
model.Extension.SelectByID2("草图1", "SKETCH", 0, 0, 0, False, 0, None, 0)
feat = model.FeatureManager.FeatureExtrusion3(
    True, False, False, 0, 0, 0.05, 0.0, False, False, False, False,
    0.0, 0.0, False, False, False, False, True, True, True, 0, 0.0, False)

# 3) 重建并校验（关键：把"AI 以为对"变成"程序证明对"）
ok = model.EditRebuild3()
mass = model.Extension.CreateMassProperty()          # 质量/体积/重心
print("rebuild:", ok, "volume(m^3):", mass.Volume)

model.Extension.SaveAs(r"D:\out\bracket.SLDPRT", 0, 1, None, 0, 0)
```

> 上面的 `FeatureExtrusion3` 参数顺序只是示意。**可靠做法只有一条：在 SolidWorks 里宏录制一次真实操作，把生成的 VBA 逐行翻译成 Python/C#，再参数化。** 手写 API 调用是新人最大的时间黑洞。

### 4.4 工程图自动出图（真正的难点）

```text
CreateDrawViewFromModelView3(模型名, "*前视", x, y, 0)   → 主视图
Create3rdAngleViews2(模型名)                              → 三视图
InsertModelAnnotations3(选项, 是否所有视图, 是否消除重复, ...) → 插入模型尺寸
InsertBomTable3 / InsertBomTable4                          → BOM 表
EditSheet / SetupSheet5                                    → 图纸格式与比例
```

难点不在“能不能调”，而在**标注能不能过审**：视图比例、尺寸避让、尺寸链是否重复、形位公差、粗糙度、焊接符号、技术要求文本。工程图 100% 自动化的性价比很低，**建议做到“自动出视图 + 自动插尺寸 + 人工微调 5 分钟”，不要追求零人工。**

### 4.5 难度与坑（SolidWorks）

| 坑 | 说明 | 应对 |
|---|---|---|
| 重建失败 | 草图欠约束、圆角半径大于壁厚、抽壳失败 | 参数预校验（几何约束求解器/规则表）+ 失败自动回退 |
| `SelectByID2` 脆弱 | 依赖对象名称和坐标，改名就选不中 | 用 `GetPersistReference3` 持久 ID，或统一命名规范 |
| 单位混淆 | API 用米/弧度，UI 用毫米/度 | 所有入参统一在适配层换算 |
| 版本差异 | 不同年份 API 签名不同（Extrusion2/3/4） | 锁定 SolidWorks 版本，CI 里做回归 |
| 装配配合 | 配合过定义、干涉 | 用 `InterferenceDetectionManager` 做自动干涉检查 |
| 工程图标注 | 尺寸重叠、比例错误 | 模板 + 人工复核，不追求全自动 |
| 授权 | 单机许可无法并发跑 | 夜间批处理队列 |

**工期判断：** 单一零件族参数化（10 个配置内）2–3 周；含工程图与 BOM 的完整链路 8–12 周；覆盖多产品线 6 个月以上。


---

## 5. 能力域 C：Altium Designer 24 智能画图（难度 ★★★★★，最不推荐先做）

### 5.1 必须先讲清楚的事实

Altium Designer 的对外开放能力只有四条：

1. **DelphiScript / VBScript 脚本**：内置脚本引擎，可操作原理图（`SchServer`）和 PCB（`PCBServer`），文件为 `.pas` / `.vbs`，通过 DXP 菜单的 Run Script 执行。
2. **Altium Designer SDK（Delphi / C++ 插件）**：能力最全，但需要 Pascal/C++ 功底，编译调试链老旧，社区资料少。
3. **Altium 365 REST API**：面向云端工作区（元件库、项目、BOM、评审流程）的数据接口，官方有 Developer Center 与 API 示例，适合做 PLM/供应链侧集成，**不负责“画图”**。
4. **文件与输出**：`.SchDoc`/`.PcbDoc` 私有二进制格式、OutJob、Gerber/ODB++/IPC-2581、Draftsman。

**没有官方的“AI/LLM 生成原理图/PCB”接口**（截至本文编写时的公开资料；厂商若有新发布需另行确认）。所以“AI 画电路板”在当前工程条件下，只能做成**辅助**，不能做成**自动**。

### 5.2 可行性拆解

| 任务 | 可行性 | 实现方式 | 风险 |
|---|---|---|---|
| BOM 生成/校对/替代料建议 | ★★★★★ | 脚本导出 + LLM 比对 + ERP 校验 | 低 |
| 设计规则检查（DRC）报告解读与修复建议 | ★★★★★ | 导出报告 → LLM 归类 → 给修复脚本 | 低 |
| 批量改属性（位号、参数、注释、层） | ★★★★★ | DelphiScript 遍历对象 | 低 |
| 元件库/封装库治理（重复、命名、参数缺失） | ★★★★ | 脚本导出 CSV + LLM 清洗 + 回写 | 中 |
| 原理图页/图框/标题栏批量生成 | ★★★★ | 脚本 + 模板 | 低 |
| 丝印/装配图/位号图自动排版 | ★★★ | 脚本几何计算 | 中 |
| 网表/连接关系 → 原理图草稿 | ★★ | 脚本 + LLM 生成连线和符号，人工复核 | 高（错一根线就是废板） |
| 叠层/阻抗/线宽建议 | ★★ | LLM 依据 IPC-2221 估算 + 人工确认 | 中 |
| **自动布局/布线** | ✘ | 无生产级方案（研究阶段） | 极高 |
| **从需求直接生成可投板 PCB** | ✘ | 不建议立项 | — |

### 5.3 让 LLM 写 DelphiScript 的工程闭环

关键不是“让它写”，而是“写完能安全执行并验证”：

~~~text
需求描述 → 检索 API 片段（RAG：官方脚本示例 + 企业脚本库）
        → LLM 生成脚本（限定 API 白名单、禁写文件系统）
        → 在图纸副本上执行（先备份/版本控制）
        → 回读对象数量/网络表/DRC 结果做断言
        → 失败则把错误信息回传模型，最多 3 轮
        → 人工确认后合入
~~~

示例（PCB 上按坐标画一段走线，LLM 生成脚本的最小正确形态）：

```pascal
{..............................................................................}
Procedure AddTrackByLLM;
Var
  Board : IPCB_Board;
  Track : IPCB_Track;
Begin
  Board := PCBServer.GetCurrentPCBBoard;
  If Board = Nil Then Exit;

  Track := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
  Track.X1    := MilsToCoord(1000);
  Track.Y1    := MilsToCoord(1000);
  Track.X2    := MilsToCoord(1400);
  Track.Y2    := MilsToCoord(1000);
  Track.Width := MilsToCoord(12);
  Track.Layer := eTopLayer;

  Board.AddPCBObject(Track);
  PCBServer.PostProcess;
  Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);
End;
{..............................................................................}
```

> 实践要点：Altium 脚本的调试体验有限（断点、变量观察都不如现代 IDE），**建议用 `ShowMessage` / 日志文件分段验证**；单位必须用 `MilsToCoord` 显式换算；改图前先用版本控制或另存副本，脚本批量改动很难靠撤销回退。

### 5.4 规避策略（强烈建议）

- **AI 原型用 KiCad，交付用 Altium。** KiCad 有 Python API 和现成 MCP 服务器（`kicad-mcp-server` 等），做“AI 生成原理图草稿/规则检查”的验证成本远低于 Altium；验证通过的设计思路再人工落到 Altium。
- **Altium 侧只做“数据与检查”类自动化**：BOM、库、DRC 报告、批量属性、输出打包。这类工作占电子工程师 30% 的时间，收益确定、风险低。
- **不要承诺“AI 自动画板”。** 一旦承诺，项目会死在“打样回来不工作”上。

### 5.5 难度与工期

| 阶段 | 内容 | 工期 |
|---|---|---|
| P1 | 脚本框架 + BOM/DRC 报告分析 | 3–4 周 |
| P2 | 批量属性/库治理/输出自动化 | 4–6 周 |
| P3 | 网表→原理图草稿（实验性） | 2–3 个月，成功率不保证 |
| P4 | 自动布线 | 不建议 |

---

## 6. 能力域 D：AI 绘画 / 智能出图（难度 ★★★）

### 6.1 适用场景与边界

| 能用 | 不能用 |
|---|---|
| 产品效果图、场景渲染图 | 生产图纸、装配图 |
| 说明书插图、爆炸图美化 | 带尺寸/公差的工程图 |
| 投标方案示意、宣传物料 | 需要精确结构的剖视图 |
| 铭牌/面板示意、材质预览 | 文字必须精确的图（型号、参数） |

**原则：结构由 CAD 锁定（线稿/深度/法线），AI 只负责材质、光影、场景；文字一律后期排版，不让模型写。**

### 6.2 技术栈

| 组件 | 选型 | 说明 |
|---|---|---|
| 生成引擎 | ComfyUI（本地） | 节点式、可 API 调用、生态最大 |
| 底模 | FLUX.1 / SDXL / Qwen-Image | FLUX 质感好、SDXL 生态全、Qwen-Image 中文语义强 |
| 结构控制 | ControlNet（Canny / Lineart / Depth / Normal / SoftEdge） | 线稿锁结构的关键 |
| 风格控制 | LoRA（公司产品风格，20–50 张图训练）+ IP-Adapter | 保证多张图风格统一 |
| 调用方式 | ComfyUI HTTP API（`/prompt`、`/history`、`/view`）+ WebSocket | 可嵌入任何系统 |
| 硬件 | RTX 4090 24GB（本地）或云 GPU 按小时 | 本地更符合内网要求 |

### 6.3 标准管线

~~~text
SolidWorks 截图（统一视角、统一背景、关掉阴影）
   → 预处理（抠背景 / Lineart / Depth）
   → ComfyUI 工作流（ControlNet 权重 0.6–0.9 + LoRA 0.6）
   → 生成 4–8 张候选
   → 人工挑选（这一步不能省）
   → 后期（PS/AI 排版文字、加尺寸标注）
   → 归档到素材库（带提示词与参数，便于复现）
~~~

### 6.4 调用代码

```python
import json, time, uuid, requests

SERVER = "http://127.0.0.1:8188"
CLIENT_ID = str(uuid.uuid4())

# 1) 在 ComfyUI 里搭好工作流，菜单选 "Save (API Format)" 导出 workflow_api.json
wf = json.load(open("workflow_api.json", encoding="utf-8"))

# 2) 用节点 id 注入参数（id 由工作流决定，不要硬编码到业务代码里）
wf["6"]["inputs"]["text"] = "industrial explosion-proof junction box, painted steel, studio light"
wf["10"]["inputs"]["image"] = "lineart.png"       # LoadImage 节点
wf["3"]["inputs"]["seed"] = 12345

# 3) 提交任务
r = requests.post(f"{SERVER}/prompt", json={"prompt": wf, "client_id": CLIENT_ID}, timeout=30)
prompt_id = r.json()["prompt_id"]

# 4) 轮询结果
while True:
    h = requests.get(f"{SERVER}/history/{prompt_id}", timeout=10).json()
    if prompt_id in h:
        for node_out in h[prompt_id]["outputs"].values():
            for img in node_out.get("images", []):
                print("生成:", img["filename"])   # 再用 /view?filename=... 下载
        break
    time.sleep(1)
```

### 6.5 可控性技巧与坑

| 问题 | 原因 | 解决 |
|---|---|---|
| 结构被“自由发挥” | ControlNet 权重太低 | 权重 0.7–0.9，配 Lineart + Depth 双控制 |
| 风格每张不一样 | 无固定种子/LoRA | 固定 seed 区间 + 训练企业 LoRA |
| 图里出现乱码文字 | 生成模型不会排版 | 后期加字，或遮蔽该区域重绘 |
| 透视与 CAD 不一致 | 截图相机与生成视角不同 | 统一相机参数，或用 Depth 图约束 |
| 出图慢 | 单卡排队 | 队列 + 批量任务 + 夜间跑 |

**工期判断：** 部署 + 一条可用工作流 1–2 周；风格 LoRA + 批量管线 3–4 周。

---

## 7. 能力域 E：图纸理解与知识库（难度 ★★★，决定项目上限）

这一块不直接“画图”，但决定了前面所有能力好不好用：**存量图纸如果不能变成结构化数据，AI 就只能画新图，接不上老图。**

### 7.1 处理管线

~~~text
PDF/扫描图 → 页面渲染（300dpi）→ 版面分析（标题栏/明细表/视图区）
          → OCR + 表格识别 → VLM 字段抽取（材料、比例、图号、技术要求）
          → 结构化 JSON → 人工复核界面 → 入库（图纸库 + 向量库）
~~~

### 7.2 工具

| 环节 | 候选 |
|---|---|
| OCR / 版面 | PaddleOCR（PP-Structure）、MinerU、Docling |
| VLM 抽取 | Qwen-VL-Max、GLM-4V、豆包 Vision |
| 表格 | PaddleOCR 表格模型 / 专用表格 API |
| 知识库 | Dify 知识库、RAGFlow、Qdrant/Milvus + bge-m3 |

### 7.3 准确率预期（工程经验值，需以实测为准）

| 对象 | 预期准确率 | 是否可无人化 |
|---|---|---|
| 标题栏字段（图号/名称/材料/比例） | 90–97% | 需抽检 |
| 明细表（BOM） | 85–95% | 需复核 |
| 技术要求文本 | 90%+ | 需复核 |
| 尺寸与公差（散落标注） | 60–80% | 必须人工 |
| 装配关系/拓扑 | <50% | 不可用 |

**结论：图纸理解定位为“录入加速器”，不是“全自动数字化”。**

### 7.4 标准知识库（矿山安全设备的差异化壁垒）

把下列标准做成可检索知识库，让 Agent 在生成图纸/方案时自动引用：

- GB 3836 系列《爆炸性环境》（防爆型式、隔爆间隙、本安参数）
- GB/T 1.1 标准化文件编写规则
- MT/T 煤矿行业标准、AQ 安全标准
- 《煤矿安全规程》相关条款
- 企业工艺文件、检验规范、历史项目图纸

这部分是**别人抄不走的部分**：模型谁都能接，标准条款 + 企业工艺只有公司自己有。


---

## 8. 智能体编排与产品形态

### 8.1 四种产品形态

| 形态 | 技术 | 优点 | 缺点 | 适用 |
|---|---|---|---|---|
| CAD 插件面板 | SolidWorks Add-in / AutoCAD .NET | 工程师不离开软件 | 开发重、版本绑定 | 高频重度用户 |
| 内网 Web 应用 | 前端 + 后端 + MCP | 易迭代、易统计 | 需要切换窗口 | 主流选择 |
| IM 机器人 | 企业微信/钉钉 + 后端 | 零学习成本、可审批 | 传文件体验差 | 审批、查询、轻任务 |
| 低代码工作流 | Dify / n8n | 一周出原型 | 复杂逻辑受限 | 验证期、非核心流程 |

建议：**验证期用 Dify，生产期用“内网 Web + 自研 Agent + MCP 工具”**，两条腿走。

### 8.2 Agent 设计要点

1. **Planner 与 Executor 分离**：规划模型只输出步骤与工具名，执行器做参数校验（范围、单位、必填），不合法直接拒绝，不交给模型“再想想”。
2. **工具白名单 + 只读/写分离**：读图、测量、导出可以放开；改图、删特征、覆盖文件必须二次确认。
3. **强制校验器**：每个写操作后回读几何（体积/质量/包围盒/对象数），与预期比对，偏差超阈值即回滚。
4. **Human-in-the-loop**：工程图、投板文件、对外交付物，一律人工确认后才落盘。
5. **全链路审计**：谁、什么时候、用什么提示词、调了什么工具、生成了什么文件，全部落库，便于追责和复盘。

### 8.3 内网 / 断网部署（矿山客户场景的硬约束）

| 组件 | 离线方案 |
|---|---|
| LLM | vLLM + Qwen3-32B / GLM-4-9B 级模型，单卡 4090 可跑 32B 量化 |
| VLM | Qwen2.5-VL-7B/32B 本地部署 |
| 图像生成 | ComfyUI + SDXL/FLUX（本地） |
| 编排 | Dify 离线 Docker Compose |
| 向量库 | Qdrant / Milvus 单机版 |
| 更新 | 内网镜像仓库 + 离线模型包 |

### 8.4 合规与安全

- **图纸外发**：涉及客户型号、防爆结构的图纸，不应上传公有云模型；优先本地模型。
- **模型备案**：面向公众提供生成式 AI 服务需备案；企业内部自用工具一般不涉及，但需法务确认。
- **代码执行**：LLM 生成的脚本必须沙箱执行（禁网、禁删、限定目录），这是最容易出事的地方。
- **许可证**：SolidWorks/Altium/AutoCAD 的 API 调用不额外收费，但**用其生成的数据训练模型**要看许可条款，商业项目建议只用自研数据与公开数据。

---

## 9. 三个端到端场景（可直接照做）

### 场景 A：防爆壳体“参数 → 模型 → 工程图 → BOM”

~~~text
输入：宽 400 / 高 500 / 深 200 / 壁厚 6 / 法兰螺栓 M8×12 / 防爆等级 Ex d IIB T4
  ↓ ① LLM 解析 + 参数补全（缺省值来自企业标准）
  ↓ ② 规则校验：壁厚、隔爆面长度（按 GB 3836.2 容积分级查表）、螺栓间距  （纯代码，不用模型）
  ↓ ③ 调用 SolidWorks：打开模板 → 改方程式/配置 → 重建
  ↓ ④ 回读：体积、质量、包围盒、干涉检查 → 与理论值比对（±2%）
  ↓ ⑤ 出工程图：三视图 + 关键尺寸 + 标题栏 + BOM
  ↓ ⑥ 人工复核（5–10 分钟）→ 归档 → 同步 ERP
输出：SLDPRT + SLDDRW + PDF + BOM.xlsx
~~~

关键点：步骤 ② 和 ④ 是“AI 之外”的确定性代码，**没有它们，这个流程不可交付**。

### 场景 B：甲方 PDF 系统图 → 参数表 → AutoCAD 图纸

~~~text
输入：甲方 PDF/照片（矿用监控系统图）
  ↓ ① 渲染 + OCR + VLM 抽取：设备清单、连接关系、图例
  ↓ ② 人工复核表单（Web 页面，勾选/改数）
  ↓ ③ 映射到企业图纸模板（块库：传感器、分站、电源、光缆）
  ↓ ④ 生成绘图指令 JSON → AutoCAD COM 执行 → 自动标注/编号
  ↓ ⑤ 图纸审查 Agent：图层、字体、图框、编号连续性、遗漏连接
输出：DWG + PDF + 设备清单
~~~

关键点：**不要追求“PDF 直接变 DWG”**。中间必须有一张人可编辑的参数表，这是准确率的来源，也是出问题时能定位的地方。

### 场景 C：产品线稿 → 说明书/投标插图

~~~text
输入：SolidWorks 模型截图（统一视角）
  ↓ ① 抠背景 + Lineart/Depth 提取
  ↓ ② ComfyUI（ControlNet 0.8 + 企业 LoRA 0.6）生成 6 张
  ↓ ③ 人工挑选 + 局部重绘
  ↓ ④ 后期排版加文字、箭头、标注
输出：PNG/JPG（300dpi）+ 提示词与参数存档
~~~

---

## 10. 难度评估总表与实施路线

### 10.1 综合难度矩阵

评分口径：★=1 分，满分 5 星。工期为“1 名有经验工程师”的估算。

| 能力域 | 技术难度 | 数据依赖 | 集成风险 | 业务风险 | MVP 工期 | 生产可用 | 优先级 |
|---|---|---|---|---|---|---|---|
| AutoCAD 参数化出图 | ★★☆ | 中（需图层/图框标准） | 低 | 低 | 4–6 周 | 2–3 月 | **P0** |
| AutoCAD 图纸审查/批量改图 | ★★ | 中 | 低 | 中 | 3–4 周 | 2 月 | **P0** |
| AI 绘画（效果图/插图） | ★★★ | 低 | 低 | 低 | 2–3 周 | 1–2 月 | **P0** |
| 图纸理解（标题栏/BOM） | ★★★ | 高（扫描质量） | 中 | 中 | 6–8 周 | 3 月 | P1 |
| SolidWorks 参数化建模 | ★★★★ | 高（模板化程度） | 中 | 高 | 8–12 周 | 4–6 月 | P1 |
| SolidWorks 工程图自动标注 | ★★★★☆ | 高 | 高 | 高 | 12 周+ | 6 月+ | P2 |
| Altium 脚本/BOM/DRC 辅助 | ★★★☆ | 中 | 中 | 中 | 3–4 周 | 2 月 | P1 |
| Altium 网表→原理图 | ★★★★★ | 高 | 高 | 极高 | 3 月+ | 不建议 | P3 |
| Altium 自动布线 | ★★★★★ | — | — | 极高 | — | 无方案 | 不做 |
| Agent 平台/权限/审计 | ★★ | 低 | 中 | 中 | 2–3 周 | 2 月 | **P0** |

### 10.2 三期路线

| 阶段 | 时间 | 目标 | 交付物 | 验收指标 |
|---|---|---|---|---|
| 一期：打样 | 0–2 月 | 证明“能出图” | AutoCAD 单场景 + AI 效果图 + Dify 平台 | 3 个真实项目用上，节省工时 ≥30% |
| 二期：复制 | 2–5 月 | 从 1 个场景到 5 个 | 图纸理解 + SolidWorks 参数化 + Altium 辅助 | 覆盖 60% 常规改型，返工率 <10% |
| 三期：沉淀 | 5–9 月 | 变成企业能力 | 标准库 RAG + 模板库 + 培训体系 | 新员工 1 周上手，图纸一次通过率提升 |

**单人（1–3 年经验）现实预期：** 9 个月能把 P0 + 部分 P1 做到“能用”，做不到“全精通”。三人小组（AI 工程师 + CAD 二次开发 + 工艺专家兼职）6 个月可覆盖 P0/P1。

---

## 11. 成本测算（量级参考，以实际报价为准）

| 项目 | 估算 | 说明 |
|---|---|---|
| 人力（1 人） | 12–20 万/年 | 西安中级工程师薪资 + 社保公积金 |
| 人力（3 人小组） | 40–60 万/年 | AI + CAD 开发 + 兼职工艺 |
| LLM API | 500–3000 元/月 | 按日均 100–300 次任务、每次 1–3 万 token 估算，国产模型单价低 |
| 图像生成 | 本地 0 元/月；云 500–2000 元/月 | 4090 整机约 2–3 万元 |
| 本地推理服务器 | 3–6 万元/台 | 4090/5090 级单卡，跑 32B 量化模型 |
| 软件许可 | 按现有资产 | SolidWorks/AutoCAD/Altium 已购则不增量；**注意 API 并发会占用许可** |
| 隐形成本 | 2–3 人月 | 图纸标准化、模板整理、图层/图框统一（最容易低估） |

> 结论：**钱不是主要约束，人月和数据整理才是。** 一个 20–99 人的公司，最现实的是“1 个 AI 工程师 + 1 个 CAD 熟手 + 工艺专家每周 1 天”。

---

## 12. 风险清单

| # | 风险 | 概率 | 影响 | 应对 |
|---|---|---|---|---|
| 1 | 模型幻觉导致几何/尺寸错误 | 高 | 高 | 强制回读校验 + 人工确认，不让模型直接落盘 |
| 2 | 图纸不标准，模板化失败 | 高 | 高 | 先做图纸标准化，先挑 3–5 个标准件试点 |
| 3 | 老员工不配合/不信任 | 中 | 高 | 先做“省时间”的功能（批量改图、BOM），不做“替代人”的宣传 |
| 4 | CAD 版本/许可变化导致接口失效 | 中 | 中 | 锁定版本，封装适配层，回归测试 |
| 5 | 社区 MCP 项目停更/有后门 | 中 | 中 | 只用于验证，生产自研；代码审计 |
| 6 | 内网无外网，云 API 不可用 | 高 | 中 | 本地模型兜底，双轨设计 |
| 7 | Altium 方向投入产出比失衡 | 高 | 中 | 只做数据/检查类，不碰自动布线 |
| 8 | 关键人离职，系统无人维护 | 中 | 高 | 文档化 + 代码规范 + 至少两人懂 |
| 9 | 生成内容版权/合规 | 低 | 中 | 只用自研数据训练，公开模型遵守许可 |
| 10 | 项目范围蔓延，一年做不完 | 高 | 高 | 按本文 P0/P1/P2 排序，季度评审 |

---

## 13. 岗位映射：这份 JD 到底在招什么人

### 13.1 三条要求 ↔ 实际技能

| JD 要求 | 真实需要的技能 | 本方案对应章节 | 权重判断 |
|---|---|---|---|
| 精通 AI 智能体搭建（软硬件） | Python、API 调用、MCP、Dify/n8n、GPU 部署 | §2、§8 | 40% |
| 精通数据备份（软硬件） | 3-2-1 备份、NAS、快照、恢复演练 | 附录 A | 10%（运维属性） |
| 协助开发智能画图应用 | CAD 二次开发（COM/脚本）、几何/制图知识、工程思维 | §3–§7 | 50% |

### 13.2 给候选人的建议（如果你在准备这个岗位）

- **面试作品**：做一个“Excel 参数 → AutoCAD 接线图 DWG”的最小 demo（2 周可完成），比任何证书都有说服力。代码放 GitHub，附 3 分钟演示视频。
- **必须能讲清楚的三个问题**：
  1. 为什么不让大模型直接输出 DWG/STEP？（答案见 §2.4）
  2. 模型画错了怎么发现？（答案：回读几何 + 规则校验 + 人工确认）
  3. Altium 为什么不能自动布线？（答案：无开放接口 + 试错成本 + 无生产级算法）
- **不要吹**：不要说“精通 SolidWorks/Altium 二次开发”，1–3 年经验做不到；说“能基于 COM/脚本做参数化与批处理，复杂几何交给模板”。
- **反向提问**：公司图纸有没有统一的图层/图框/模板？有没有 PDM/版本管理？—— 这两个问题的答案决定项目难度。

### 13.3 给企业的建议（如果你在评估是否立项）

- **先用 30 天做可行性验证**，不要一上来买 GPU、招团队。验证题：拿 3 个真实项目，看现有工具能省多少工时。
- **预算分配建议**：50% 人力、20% 图纸标准化、20% 软硬件、10% 试错。
- **组织建议**：AI 工程师向技术负责人汇报，工艺专家给“否决权”（图纸不合规可一票否决）。

### 13.4 90 天验收表（可直接用于试用期考核）

| 时间 | 交付 | 验收标准 |
|---|---|---|
| 第 30 天 | 环境 + 2 个 demo（AutoCAD 出图、AI 效果图） | 能现场演示，代码可复现 |
| 第 60 天 | 1 个真实项目落地 | 节省工时 ≥30%，无图纸错误 |
| 第 90 天 | 平台化 + 文档 + 培训 | 业务人员能自助使用 3 个流程 |

---

## 14. 结论与行动建议

### 14.1 做 / 缓 / 不做

| 决策 | 内容 | 理由 |
|---|---|---|
| **立刻做** | AutoCAD 参数化出图、AI 效果图、Agent 平台 | 风险低、见效快、可复用 |
| **计划做** | 图纸理解录入、SolidWorks 参数化（系列件）、Altium BOM/DRC 辅助 | 价值高，但依赖数据整理 |
| **谨慎做** | SolidWorks 工程图全自动标注 | 投入产出比低，人工微调更划算 |
| **不要做** | Altium 自动布局布线、PDF 直接转 DWG、端到端文生 CAD 生产件 | 当前技术条件下不可交付 |

### 14.2 如果只做一件事

**做“AutoCAD 参数化出图 + 图纸审查”。** 原因：矿山安全设备的图纸以系统图、接线图、布置图为主，拓扑稳定、参数化程度高；AutoCAD 接口最开放；错误代价低（改图便宜）；一线工程师每天都要用。这是唯一能在 2 个月内看到明确 ROI 的方向。

### 14.3 如果只能招一个人

优先招**会 Python + 懂 CAD 二次开发 + 有工程直觉**的人，而不是“会调 API 的算法工程师”。这个岗位 80% 的时间在跟图纸、图层、模板、单位、版本打交道，不是训模型。

---

## 15. 参考资料

| 主题 | 链接 |
|---|---|
| AutoCAD MCP 服务器（240+ 工具，COM / ezdxf 双后端） | https://github.com/U-C4N/autocad-mcp |
| AutoCAD MCP（另一实现） | https://github.com/codesknight/AutoCAD-MCP |
| SolidWorks MCP（PyPI，COM 驱动，带几何自检） | https://pypi.org/project/solidworks-mcp/ |
| FreeCAD MCP | https://pypi.org/project/freecad-mcp/ |
| KiCad MCP Server | https://pypi.org/project/kicad-mcp-server/ |
| Altium Designer DelphiScript 官方文档 | https://www.altium.com/documentation/altium-designer/delphiscript-support |
| Altium 365 API 文档 | https://www.altium.com/documentation/altium-developer-center/altium-365/api/examples |
| ComfyUI Server API 示例 | https://docs.comfy.org/development/comfyui-server/api-examples |
| Dify v1.6 双向 MCP 支持 | https://dify.ai/blog/v1-6-0-built-in-two-way-mcp-support |
| n8n MCP Client 节点 | https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcpclient |
| Zoo Text-to-CAD（商业文生 CAD） | https://zoo.dev/text-to-cad |
| 通义万相 Qwen-Image API | https://www.alibabacloud.com/help/tc/model-studio/qwen-image-2-0-pro |
| MCP 协议规范 | https://modelcontextprotocol.io |

> 说明：社区项目（MCP 服务器）的接口与能力可能随版本变化，落地前需按当前版本 README 复核；商业模型的价格与版本以厂商官网为准。

---

## 附录 A：数据备份与 AI 资产治理（对应 JD 第 2 条）

这一条看似与“画图”无关，实际是最容易被低估的部分：**图纸、模型、训练数据、提示词、工作流，本身就是公司最贵的资产。**

### A.1 3-2-1-1-0 原则

| 数字 | 含义 | 落地 |
|---|---|---|
| 3 | 至少 3 份副本 | 本地 + NAS + 异地/云 |
| 2 | 2 种不同介质 | SSD/HDD + 磁带/对象存储 |
| 1 | 1 份异地 | 异地机房或云冷备 |
| 1 | 1 份离线/不可变 | 防勒索病毒（快照 + 对象锁） |
| 0 | 0 错误（可恢复） | 每季度恢复演练，记录 RTO/RPO |

### A.2 工具选型

| 场景 | 候选 | 说明 |
|---|---|---|
| 整机/虚拟机备份 | Veeam、Acronis | 企业主流，支持异机恢复 |
| 文件级增量 | Restic、Duplicati、Kopia | 开源、支持加密与对象存储 |
| NAS 快照 | 群晖/威联通 Snapshot Replication | 防勒索的第一道防线 |
| 代码/图纸版本 | SVN、Git + Git LFS、PDM（SolidWorks PDM） | **图纸必须有版本，否则 AI 改图无法回滚** |
| AI 资产 | 模型权重、LoRA、工作流 JSON、提示词库、评测集 | 单独仓库 + 版本号，和代码一起备份 |

### A.3 与 AI 项目的结合点

1. **AI 改图前自动打快照**：调用 API 前 copy 一份到 `backup/时间戳/`，失败可秒回滚。
2. **生成物归档**：每次生成的模型/图纸/图片，连同提示词、参数、模型版本一起入库，保证可复现。
3. **知识库备份**：向量库需要定期导出（快照 + 原文），避免“库坏了重建要重跑嵌入”。
4. **恢复演练**：随机抽一份 3 年前的图纸，要求 30 分钟内可打开、可编辑、版本正确。

---

## 附录 B：一周 demo 清单（可直接执行）

| 天 | 任务 | 命令 / 动作 |
|---|---|---|
| D1 | 装 Python 3.11 + Git；克隆 ComfyUI，跑通默认工作流 | `git clone https://github.com/comfyanonymous/ComfyUI` → `pip install -r requirements.txt` |
| D2 | 装 `solidworks-mcp` 或 `autocad-mcp`，用 Claude Desktop / Cursor 连接 | `pip install solidworks-mcp`，按其 README 配置 MCP |
| D3 | 用自然语言让 Agent 画一个带孔的板 | 观察它调用哪些工具、错在哪 |
| D4 | 用 Dify 搭“参数表 → 指令 JSON”工作流 | 接一个 HTTP 节点调用本地执行器 |
| D5 | 做一条 ComfyUI 线稿转效果图工作流 | 导出 API 格式 JSON |
| D6 | 串起来：一句需求 → 出图 → 出效果图 | 录屏 |
| D7 | 复盘：哪些环节不可靠、需要多少人工 | 形成可行性结论 |

**这个 demo 的产出，就是判断“这个岗位/这个项目值不值得投入”的最小证据。**
