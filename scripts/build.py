#!/usr/bin/env python3
"""
build.sh — 从 harnesses/claude-code/CLAUDE.md 生成 harnesses/codex/AGENTS.md
将 @context/xxx.md 引用展开为文件实际内容。

用法：
  python3 scripts/build.py
  或通过 Makefile: make build
"""

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
CLAUDE_MD = REPO_ROOT / "harnesses" / "claude-code" / "CLAUDE.md"
AGENTS_MD = REPO_ROOT / "harnesses" / "codex" / "AGENTS.md"


def expand_imports(content: str, base_dir: Path) -> str:
    """Replace @context/xxx.md references with file contents."""
    lines = content.splitlines()
    result = []
    for line in lines:
        match = re.match(r'^@([\w/./-]+\.md)\s*$', line.strip())
        if match:
            ref_path = REPO_ROOT / match.group(1)
            if ref_path.exists():
                ref_content = ref_path.read_text(encoding="utf-8").strip()
                result.append(ref_content)
                result.append("")  # blank line after imported content
            else:
                print(f"WARNING: Referenced file not found: {ref_path}", file=sys.stderr)
                result.append(line)
        else:
            result.append(line)
    return "\n".join(result)


def main() -> None:
    if not CLAUDE_MD.exists():
        print(f"ERROR: Source file not found: {CLAUDE_MD}", file=sys.stderr)
        sys.exit(1)

    source = CLAUDE_MD.read_text(encoding="utf-8")
    expanded = expand_imports(source, REPO_ROOT)

    header = (
        "# Personal Preferences & Coding Standards\n\n"
        "> Auto-generated from harnesses/claude-code/CLAUDE.md\n"
        "> Do not edit directly — run `make build` to regenerate.\n\n"
    )

    AGENTS_MD.write_text(header + expanded, encoding="utf-8")
    print(f"Generated: {AGENTS_MD}")


if __name__ == "__main__":
    main()
