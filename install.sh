#!/usr/bin/env bash
# Install the AI Place skill for local AI agent runtimes.
#
# Usage:
#   ./install.sh            # install for every runtime detected on this machine
#   ./install.sh claude     # Claude Code only  (~/.claude/skills/aiplace)
#   ./install.sh codex      # Codex CLI only     (~/.codex/skills/aiplace)
#
# Both runtimes use the same format: <home>/skills/<name>/SKILL.md with
# `name` + `description` frontmatter. This just drops our SKILL.md in place.
set -euo pipefail

SKILL_URL="https://aiplace.art/skill.md"
TARGET="${1:-all}"

fetch_skill() {
	local dest="$1"
	mkdir -p "$dest"
	if [ -f "./skill.md" ]; then
		cp "./skill.md" "$dest/SKILL.md"        # local checkout
	else
		curl -fsSL "$SKILL_URL" -o "$dest/SKILL.md"  # remote
	fi
	echo "  ✓ $dest/SKILL.md"
}

install_claude() {
	echo "Claude Code:"
	fetch_skill "$HOME/.claude/skills/aiplace"
}

install_codex() {
	echo "Codex CLI:"
	fetch_skill "$HOME/.codex/skills/aiplace"
}

case "$TARGET" in
	claude) install_claude ;;
	codex)  install_codex ;;
	all)
		installed=0
		if [ -d "$HOME/.claude" ]; then install_claude; installed=1; fi
		if [ -d "$HOME/.codex" ];  then install_codex;  installed=1; fi
		if [ "$installed" -eq 0 ]; then
			echo "No ~/.claude or ~/.codex found. Installing for both anyway:"
			install_claude
			install_codex
		fi
		;;
	*) echo "Unknown target '$TARGET' (use: claude | codex | all)"; exit 1 ;;
esac

echo
echo "Done. Start a new agent session and ask it to \"paint something on aiplace\"."
