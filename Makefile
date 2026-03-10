.PHONY: install update diff check help

CLAUDE_DIR := $(HOME)/.claude
GLOBAL_DIR := $(CURDIR)/global

help: ## Show this help
	@echo "AI Engineering System - Makefile"
	@echo ""
	@echo "Usage:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-15s %s\n", $$1, $$2}'

install: ## Copy global/ config to ~/.claude/ (skip if already exists)
	@echo "Installing AI engineering config to $(CLAUDE_DIR)..."
	@mkdir -p $(CLAUDE_DIR)/hooks $(CLAUDE_DIR)/skills
	@# CLAUDE.md
	@if [ -f $(CLAUDE_DIR)/CLAUDE.md ]; then \
		echo "  [SKIP] CLAUDE.md (already exists)"; \
	else \
		cp $(GLOBAL_DIR)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md; \
		echo "  [OK] CLAUDE.md"; \
	fi
	@# settings.json
	@if [ -f $(CLAUDE_DIR)/settings.json ]; then \
		echo "  [SKIP] settings.json (already exists)"; \
	else \
		cp $(GLOBAL_DIR)/settings.json $(CLAUDE_DIR)/settings.json; \
		echo "  [OK] settings.json"; \
	fi
	@# Hooks scripts
	@for script in $(GLOBAL_DIR)/hooks/*.sh; do \
		name=$$(basename $$script); \
		if [ -f $(CLAUDE_DIR)/hooks/$$name ]; then \
			echo "  [SKIP] hooks/$$name (already exists)"; \
		else \
			cp $$script $(CLAUDE_DIR)/hooks/$$name; \
			chmod +x $(CLAUDE_DIR)/hooks/$$name; \
			echo "  [OK] hooks/$$name"; \
		fi; \
	done
	@# Skills
	@for skill_dir in $(GLOBAL_DIR)/skills/*/; do \
		skill_name=$$(basename $$skill_dir); \
		if [ -d $(CLAUDE_DIR)/skills/$$skill_name ]; then \
			echo "  [SKIP] skills/$$skill_name (already exists)"; \
		else \
			mkdir -p $(CLAUDE_DIR)/skills/$$skill_name; \
			cp -r $$skill_dir* $(CLAUDE_DIR)/skills/$$skill_name/; \
			echo "  [OK] skills/$$skill_name"; \
		fi; \
	done
	@echo ""
	@echo "Done. Run 'make update' to overwrite existing files."

update: ## Force overwrite ~/.claude/ with latest from global/
	@echo "Updating AI engineering config in $(CLAUDE_DIR)..."
	@mkdir -p $(CLAUDE_DIR)/hooks $(CLAUDE_DIR)/skills
	@cp $(GLOBAL_DIR)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md
	@echo "  [OK] CLAUDE.md"
	@cp $(GLOBAL_DIR)/settings.json $(CLAUDE_DIR)/settings.json
	@echo "  [OK] settings.json"
	@cp $(GLOBAL_DIR)/hooks/*.sh $(CLAUDE_DIR)/hooks/
	@chmod +x $(CLAUDE_DIR)/hooks/*.sh
	@echo "  [OK] hooks/"
	@for skill_dir in $(GLOBAL_DIR)/skills/*/; do \
		skill_name=$$(basename $$skill_dir); \
		mkdir -p $(CLAUDE_DIR)/skills/$$skill_name; \
		cp -r $$skill_dir* $(CLAUDE_DIR)/skills/$$skill_name/; \
		echo "  [OK] skills/$$skill_name"; \
	done
	@echo ""
	@echo "Update complete. Restart Claude Code to apply changes."

diff: ## Show diff between global/ and ~/.claude/ (what would change)
	@echo "=== CLAUDE.md ===" && diff $(GLOBAL_DIR)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md || true
	@echo ""
	@echo "=== settings.json ===" && diff $(GLOBAL_DIR)/settings.json $(CLAUDE_DIR)/settings.json || true
	@echo ""
	@for script in $(GLOBAL_DIR)/hooks/*.sh; do \
		name=$$(basename $$script); \
		echo "=== hooks/$$name ==="; \
		diff $$script $(CLAUDE_DIR)/hooks/$$name || true; \
		echo ""; \
	done

check: ## Verify that ~/.claude/ matches global/
	@EXIT=0; \
	diff -q $(GLOBAL_DIR)/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md > /dev/null 2>&1 \
		|| { echo "  MISMATCH: CLAUDE.md"; EXIT=1; }; \
	diff -q $(GLOBAL_DIR)/settings.json $(CLAUDE_DIR)/settings.json > /dev/null 2>&1 \
		|| { echo "  MISMATCH: settings.json"; EXIT=1; }; \
	for script in $(GLOBAL_DIR)/hooks/*.sh; do \
		name=$$(basename $$script); \
		diff -q $$script $(CLAUDE_DIR)/hooks/$$name > /dev/null 2>&1 \
			|| { echo "  MISMATCH: hooks/$$name"; EXIT=1; }; \
	done; \
	for skill_dir in $(GLOBAL_DIR)/skills/*/; do \
		skill_name=$$(basename $$skill_dir); \
		[ -d $(CLAUDE_DIR)/skills/$$skill_name ] \
			|| { echo "  MISSING: skills/$$skill_name"; EXIT=1; }; \
	done; \
	if [ $$EXIT -eq 0 ]; then echo "OK: ~/.claude/ is up to date"; fi; \
	exit $$EXIT
