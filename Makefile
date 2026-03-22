.PHONY: build install-claude install-codex install-cursor check diff eval help
# 自动化脚本用法（不作为 make target，直接运行）：
#   ./scripts/run-coding-agent.sh --project-dir /path/to/project
#   ./scripts/run-coding-agent.sh --project-dir /path/to/project --max-runs 5 --skip-permissions

CLAUDE_DIR  ?= $(HOME)/.claude
CODEX_DIR   ?= $(HOME)/.codex
AGENTS_DIR  ?= $(HOME)/.agents

CLAUDE_HARNESS := $(CURDIR)/harnesses/claude-code
SHARED_DIR     := $(CURDIR)/harnesses/shared
CODEX_HARNESS  := $(CURDIR)/harnesses/codex
CURSOR_HARNESS := $(CURDIR)/harnesses/cursor

help: ## Show this help
	@echo "AI Engineering System"
	@echo ""
	@echo "Usage:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-22s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make install-claude                          # install to ~/.claude/"
	@echo "  make install-codex                           # install to ~/.codex/ and ~/.agents/"
	@echo "  make install-cursor PROJECT_DIR=./myproject  # install to ./myproject/.cursor/"

build: ## Render shared templates → harness-specific config files
	@bash scripts/build-harnesses.sh

# ── Claude Code ─────────────────────────────────────────────────────────────

install-claude: ## Install claude-code harness to ~/.claude/
	@echo "Installing claude-code harness to $(CLAUDE_DIR)..."
	@mkdir -p $(CLAUDE_DIR)/hooks $(CLAUDE_DIR)/skills
	@cp $(CLAUDE_HARNESS)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md
	@echo "  [OK] CLAUDE.md"
	@cp $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json
	@echo "  [OK] settings.json"
	@cp $(CLAUDE_HARNESS)/hooks/*.sh $(CLAUDE_DIR)/hooks/
	@chmod +x $(CLAUDE_DIR)/hooks/*.sh
	@echo "  [OK] hooks/"
	@rsync -a $(SHARED_DIR)/skills/ $(CLAUDE_DIR)/skills/
	@rsync -a $(CLAUDE_HARNESS)/skills/ $(CLAUDE_DIR)/skills/
	@echo "  [OK] skills/ (shared + claude-code specific)"
	@echo ""
	@echo "Done. Restart Claude Code to apply changes."

check: ## Verify claude-code harness matches ~/.claude/
	@EXIT=0; \
	diff -q $(CLAUDE_HARNESS)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md > /dev/null 2>&1 \
		|| { echo "  MISMATCH: CLAUDE.md"; EXIT=1; }; \
	diff -q $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json > /dev/null 2>&1 \
		|| { echo "  MISMATCH: settings.json"; EXIT=1; }; \
	for script in $(CLAUDE_HARNESS)/hooks/*.sh; do \
		name=$$(basename $$script); \
		diff -q $$script $(CLAUDE_DIR)/hooks/$$name > /dev/null 2>&1 \
			|| { echo "  MISMATCH: hooks/$$name"; EXIT=1; }; \
		[ -x $(CLAUDE_DIR)/hooks/$$name ] \
			|| { echo "  NO EXEC:  hooks/$$name"; EXIT=1; }; \
	done; \
	if [ $$EXIT -eq 0 ]; then echo "OK: ~/.claude/ is up to date"; fi; \
	exit $$EXIT

diff: ## Show diff between harnesses/claude-code/ and ~/.claude/
	@echo "=== CLAUDE.md ===" && diff $(CLAUDE_HARNESS)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md || true
	@echo ""
	@echo "=== settings.json ===" && diff $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json || true
	@echo ""
	@for script in $(CLAUDE_HARNESS)/hooks/*.sh; do \
		name=$$(basename $$script); \
		echo "=== hooks/$$name ==="; \
		diff $$script $(CLAUDE_DIR)/hooks/$$name || true; \
		echo ""; \
	done

# ── Codex CLI ────────────────────────────────────────────────────────────────

install-codex: ## Install codex harness (~/.codex/ + ~/.agents/skills/)
	@echo "Installing codex harness..."
	@mkdir -p $(CODEX_DIR)/rules $(AGENTS_DIR)/skills
	@cp $(CODEX_HARNESS)/config.toml $(CODEX_DIR)/config.toml
	@echo "  [OK] ~/.codex/config.toml"
	@cp $(CODEX_HARNESS)/rules/default.rules $(CODEX_DIR)/rules/default.rules
	@echo "  [OK] ~/.codex/rules/default.rules"
	@rsync -a $(SHARED_DIR)/skills/ $(AGENTS_DIR)/skills/
	@echo "  [OK] ~/.agents/skills/ (shared skills)"
	@echo ""
	@echo "Done. AGENTS.md should be placed in each project root manually:"
	@echo "  cp $(CODEX_HARNESS)/AGENTS.md /path/to/project/AGENTS.md"

# ── Cursor ───────────────────────────────────────────────────────────────────

install-cursor: ## Install cursor harness to a project directory (PROJECT_DIR required)
ifndef PROJECT_DIR
	$(error Usage: make install-cursor PROJECT_DIR=/path/to/project)
endif
	@echo "Installing cursor harness to $(PROJECT_DIR)/.cursor/ ..."
	@mkdir -p $(PROJECT_DIR)/.cursor/rules $(PROJECT_DIR)/.cursor/skills
	@cp $(CURSOR_HARNESS)/rules/*.mdc $(PROJECT_DIR)/.cursor/rules/
	@echo "  [OK] .cursor/rules/ ($(shell ls $(CURSOR_HARNESS)/rules/*.mdc | wc -l | tr -d ' ') rules)"
	@rsync -a $(SHARED_DIR)/skills/ $(PROJECT_DIR)/.cursor/skills/
	@echo "  [OK] .cursor/skills/ (shared skills)"
	@echo ""
	@echo "Done. See harnesses/cursor/README.md for usage."

# ── Evals ────────────────────────────────────────────────────────────────────

eval: ## List skill eval files and show how to run them
	@echo "Skill Evals"
	@echo "-----------"
	@ls evals/skills/ 2>/dev/null | sed 's/^/  /'
	@echo ""
	@echo "To run an eval:"
	@echo "  1. Open the eval file (e.g. evals/skills/commit-eval.md)"
	@echo "  2. Set up the described scenario in a test project"
	@echo "  3. Run the corresponding skill (/commit, /review-pr, etc.)"
	@echo "  4. Verify the output against the checklist in the eval file"
