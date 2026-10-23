# Changelog

本项目的所有重要变更都会记录在此文件。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Planned

- AutoCAD 绘图指令集（op schema）与最小执行器
- SolidWorks 参数化模板示例
- ComfyUI 线稿转效果图工作流（API 格式）

## [1.0.0] - 2026-10-21

### Added

- 《AI 智能体驱动的 CAD 智能画图应用：技术可行性调研、调用方案与落地难度评估》v1.0
  - 15 章正文 + 2 个附录：需求还原、技术底座、AutoCAD / SolidWorks / Altium / AI 绘画四类能力域、图纸理解、智能体编排、端到端场景、难度矩阵、成本、风险、岗位映射、90 天验收
  - 关键代码示例：AutoCAD COM、ezdxf、SolidWorks COM、Altium DelphiScript、ComfyUI HTTP API
  - 附录 A：数据备份与 AI 资产治理（3-2-1-1-0）
  - 附录 B：一周 demo 清单
- `tools/md2docx.py`：Markdown → DOCX 转换脚本（标题层级、表格、代码块、页码）
- 项目 README（中文主文档 + 英文标题）、贡献指南、变更记录与许可说明
