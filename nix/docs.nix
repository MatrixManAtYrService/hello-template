# Documentation generation for project
{ pkgs, constants, ... }:

let
  common = import ./common.nix { inherit pkgs; };
  inherit (common) makeCheck createAnalysisPackage;

  # Create a shell script that sets up the environment and runs pdoc
  pdocScript = pkgs.writeShellScript "pdoc-docs" ''
    set -euo pipefail

    # Set up Python environment
    export PYTHONPATH="src:$PYTHONPATH"

    # Ensure docs directory exists
    mkdir -p docs

    echo '📚 Generating ${constants.name} documentation...'

    # Store current git status of docs files before generation
    if git ls-files --error-unmatch docs/ >/dev/null 2>&1; then
      git_status_before=$(git status --porcelain docs/ || true)
    else
      git_status_before=""
    fi

    # Generate docs
    pdoc --output-directory docs ${constants.name}

    # Check if docs directory changed after generation
    if git ls-files --error-unmatch docs/ >/dev/null 2>&1; then
      git_status_after=$(git status --porcelain docs/ || true)
    else
      git_status_after=""
    fi

    if [[ "$git_status_before" != "$git_status_after" ]]; then
      echo "📝 Documentation files were updated:"
      echo "$git_status_after"
      echo ""
      echo "✅ Documentation has been regenerated"
      echo "💡 Consider committing these changes"
      exit 1
    else
      echo "✅ Documentation is up to date"
    fi

    echo "💡 Open docs/${constants.name}.html in your browser to view the documentation"
  '';

  # Create a single check that generates docs and detects changes
  pdocCheck = makeCheck {
    name = "pdoc";
    description = "Generate API documentation for ${constants.name}";
    dependencies = with pkgs; [ ];
    command = ''
      nix develop --command bash ${pdocScript}
    '';
    verboseCommand = ''
      nix develop --command bash ${pdocScript}
    '';
  };
in
createAnalysisPackage {
  name = "docs";
  description = "Documentation generation";
  checks = {
    pdoc = pdocCheck;
  };
}
