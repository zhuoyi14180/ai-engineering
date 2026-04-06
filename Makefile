.PHONY: build install-claude install-codex install-cursor check diff eval help

CLAUDE_DIR    ?= $(HOME)/.claude
CODEX_DIR     ?= $(HOME)/.codex
AGENTS_DIR    ?= $(HOME)/.agents
CURSOR_SKILLS ?= $(HOME)/.cursor/skills
CURSOR_AGENTS ?= $(HOME)/.cursor/agents

CLAUDE_HARNESS := $(CURDIR)/harnesses/claude-code
CODEX_HARNESS  := $(CURDIR)/harnesses/codex
SKILLS_DIR     := $(CURDIR)/skills
AGENTS_DIR_SRC := $(CURDIR)/agents

help: ## Show this help
	@echo "AI Engineering System"
	@echo ""
	@echo "Usage:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-24s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make install-claude                          # install to ~/.claude/"
	@echo "  make install-codex                           # install to ~/.codex/ and ~/.agents/"
	@echo "  make install-cursor                          # install skills/agents to ~/.cursor/"
	@echo "  make install-cursor PROJECT_DIR=./myproject  # also copy AGENTS.md to project"

# ── Build (AGENTS.md generation) ─────────────────────────────────────────────

build: ## Generate harnesses/codex/AGENTS.md from harnesses/claude-code/CLAUDE.md
	@python3 scripts/build.py
	@echo "Done. Run 'make install-codex' to deploy."

# ── Claude Code ───────────────────────────────────────────────────────────────

install-claude: ## Install claude-code harness to ~/.claude/
	@echo "Installing claude-code harness to $(CLAUDE_DIR)..."
	@mkdir -p $(CLAUDE_DIR)/hooks $(CLAUDE_DIR)/skills $(CLAUDE_DIR)/agents
	@cp $(CLAUDE_HARNESS)/CLAUDE.md    $(CLAUDE_DIR)/CLAUDE.md
	@echo "  [OK] CLAUDE.md"
	@cp $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json
	@echo "  [OK] settings.json"
	@cp $(CLAUDE_HARNESS)/hooks/*.sh   $(CLAUDE_DIR)/hooks/
	@chmod +x $(CLAUDE_DIR)/hooks/*.sh
	@echo "  [OK] hooks/"
	@rsync -a --delete $(SKILLS_DIR)/ $(CLAUDE_DIR)/skills/
	@echo "  [OK] skills/"
	@rsync -a --delete $(AGENTS_DIR_SRC)/ $(CLAUDE_DIR)/agents/
	@echo "  [OK] agents/"
	@echo ""
	@echo "Done. Restart Claude Code to apply changes."

check: ## Verify claude-code harness is in sync with ~/.claude/
	@EXIT=0; \
	diff -q $(CLAUDE_HARNESS)/CLAUDE.md    $(CLAUDE_DIR)/CLAUDE.md    >/dev/null 2>&1 || { echo "  MISMATCH: CLAUDE.md";    EXIT=1; }; \
	diff -q $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json >/dev/null 2>&1 || { echo "  MISMATCH: settings.json"; EXIT=1; }; \
	for f in $(CLAUDE_HARNESS)/hooks/*.sh; do \
		name=$$(basename $$f); \
		diff -q $$f $(CLAUDE_DIR)/hooks/$$name >/dev/null 2>&1 || { echo "  MISMATCH: hooks/$$name"; EXIT=1; }; \
		[ -x $(CLAUDE_DIR)/hooks/$$name ]                        || { echo "  NO EXEC:  hooks/$$name"; EXIT=1; }; \
	done; \
	if [ $$EXIT -eq 0 ]; then echo "OK: ~/.claude/ is up to date"; fi; \
	exit $$EXIT

diff: ## Show diff between harnesses/claude-code/ and ~/.claude/
	@echo "=== CLAUDE.md ===" && diff $(CLAUDE_HARNESS)/CLAUDE.md    $(CLAUDE_DIR)/CLAUDE.md    || true
	@echo ""
	@echo "=== settings.json ===" && diff $(CLAUDE_HARNESS)/settings.json $(CLAUDE_DIR)/settings.json || true
	@echo ""
	@for f in $(CLAUDE_HARNESS)/hooks/*.sh; do \
		name=$$(basename $$f); \
		echo "=== hooks/$$name ==="; \
		diff $$f $(CLAUDE_DIR)/hooks/$$name || true; \
		echo ""; \
	done

# ── Codex CLI ─────────────────────────────────────────────────────────────────

install-codex: build ## Generate AGENTS.md then install codex harness
	@echo "Installing codex harness..."
	@mkdir -p $(CODEX_DIR) $(AGENTS_DIR)/skills
	@cp $(CODEX_HARNESS)/AGENTS.md   $(CODEX_DIR)/AGENTS.md
	@echo "  [OK] ~/.codex/AGENTS.md (global preferences)"
	@cp $(CODEX_HARNESS)/config.toml $(CODEX_DIR)/config.toml
	@echo "  [OK] ~/.codex/config.toml"
	@rsync -a --delete $(SKILLS_DIR)/ $(AGENTS_DIR)/skills/
	@echo "  [OK] ~/.agents/skills/"
ifdef PROJECT_DIR
	@cp $(CODEX_HARNESS)/AGENTS.md $(PROJECT_DIR)/AGENTS.md
	@echo "  [OK] $(PROJECT_DIR)/AGENTS.md (project-level copy)"
endif
	@echo ""
	@echo "Done."

# ── Cursor ────────────────────────────────────────────────────────────────────

install-cursor: ## Install cursor skills/agents to ~/.cursor/ (optionally copy AGENTS.md to PROJECT_DIR)
	@echo "Installing cursor harness to $(CURSOR_SKILLS) and $(CURSOR_AGENTS)..."
	@mkdir -p $(CURSOR_SKILLS) $(CURSOR_AGENTS)
	@rsync -a --delete $(SKILLS_DIR)/ $(CURSOR_SKILLS)/
	@echo "  [OK] ~/.cursor/skills/"
	@rsync -a --delete $(AGENTS_DIR_SRC)/ $(CURSOR_AGENTS)/
	@echo "  [OK] ~/.cursor/agents/"
ifdef PROJECT_DIR
	@mkdir -p $(PROJECT_DIR)
	@cp $(CODEX_HARNESS)/AGENTS.md $(PROJECT_DIR)/AGENTS.md
	@echo "  [OK] $(PROJECT_DIR)/AGENTS.md"
endif
	@echo ""
	@echo "Done. Cursor picks up skills from ~/.cursor/skills/ and agents from ~/.cursor/agents/ automatically."

# ── Third-party Skills ────────────────────────────────────────────────────────

update-skill-creator: ## Fetch latest skill-creator from anthropics/skills
	@set -e; \
	TMP=$$(mktemp -d); \
	trap 'rm -rf "$$TMP"' EXIT; \
	git clone --depth=1 --filter=blob:none --sparse \
		https://github.com/anthropics/skills.git "$$TMP/skills"; \
	git -C "$$TMP/skills" sparse-checkout set skills/skill-creator; \
	VERSION=$$(git -C "$$TMP/skills" log -1 --format='%h %ai'); \
	rm -rf $(CLAUDE_DIR)/skills/skill-creator; \
	mkdir -p $(CLAUDE_DIR)/skills; \
	cp -r "$$TMP/skills/skills/skill-creator" $(CLAUDE_DIR)/skills/skill-creator; \
	echo "  [OK] skill-creator installed ($$VERSION)"

# ── Evals ─────────────────────────────────────────────────────────────────────

eval: ## List skill eval files
	@echo "Skill Evals"
	@echo "-----------"
	@ls evals/skills/ 2>/dev/null | sed 's/^/  /' || echo "  (none)"
	@echo ""
	@echo "To run an eval:"
	@echo "  1. Open the eval file (e.g. evals/skills/commit-eval.md)"
	@echo "  2. Set up the described scenario in a test project"
	@echo "  3. Run the corresponding skill (/commit, /review-pr, etc.)"
	@echo "  4. Verify output against the checklist"
