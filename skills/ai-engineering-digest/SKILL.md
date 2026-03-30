---
name: ai-engineering-digest
description: 自动抓取并整理 Anthropic 和 OpenAI 近一个月内新发表的工程理念、最佳实践博客，生成一份专业、详实且可直接发表的 Markdown 报告。当用户提到「工程博客」「最佳实践」「AI 工程月报」「整理 Anthropic/OpenAI 文章」「工程 digest」「学习新的 AI 工程实践」等场景时触发。
allowed-tools: WebFetch, Write, Read
---

# AI Engineering Digest

自动收集 Anthropic 和 OpenAI 近一个月工程博客，整理为可发表的 Markdown 报告。

## 执行步骤

### 1. 确定时间范围

获取当前日期，计算「一个月前」的日期，用于过滤文章。

### 2. 抓取文章列表

并行使用 WebFetch 抓取两个来源：

```
Anthropic 工程博客：https://www.anthropic.com/engineering
OpenAI 工程博客：https://openai.com/news/engineering/
```

Prompt 设置为：`"列出所有文章的标题、URL、发布日期"`。

筛选**近一个月内**的文章。若日期信息不全，取页面靠前（最新）的条目人工判断。

### 3. 抓取每篇文章正文

对筛选出的每篇文章并行使用 WebFetch 获取全文。

每篇提取：
- 标题与发布日期
- 核心问题/背景
- 关键理念或原则（3-5 条）
- 具体技术方案或实践方法
- 代码示例（如有，保留原文代码）
- 架构图信息（如有，用 mermaid 重绘）
- 对个人开发工作流的潜在影响

### 4. 生成报告

按照 `references/report-template.md` 中定义的格式生成最终报告。

文件名：`ai-engineering-digest-YYYY-MM.md`，存放到项目根目录下的 `digests/` 目录（不存在则创建）。

### 5. 输出摘要

告知用户报告路径、包含的文章列表，以及本期最重要的 1-2 个新理念。

---

## 注意事项

- 若某篇文章无法抓取（403/超时），跳过并在报告中注明「原文暂不可达，基于摘要整理」
- 若本月文章不足 2 篇，扩展范围至近 6 周
- 代码示例保留原文语言和注释，不翻译变量名
- mermaid 图表用 `flowchart LR` 或 `sequenceDiagram`
- 报告语言：中文正文，英文代码/变量名/专有名词保持英文

## 参考资源

- 报告模板：`references/report-template.md`
