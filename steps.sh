#!/usr/bin/env bash
set -euo pipefail

# Check if nom (nix output monitor) is available
if command -v nom &> /dev/null; then
    NIX_CMD="nom"
else
    NIX_CMD="nix"
    echo "🔍 Using nix (nom not found)"
    echo "try: `nix develop --command ./steps.sh` for more transparent nix output"
fi

set -x

# Code generation first (constants, versions, tool configs)
nix run .#codegen

# Analysis second
nix run .#nix-analysis
nix run .#python-analysis
