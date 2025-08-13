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

    # Generate project docs
    echo '📚 Generating ${constants.name} documentation...'
    pdoc --output-directory docs ${constants.name}
    echo '📚 Generated ${constants.name} docs in ./docs/ directory'

    echo '📚 Documentation has been generated in docs/ directory'
    echo '💡 Open docs/${constants.name}.html in your browser to view the documentation'
  '';

  # Create a single check that generates all docs
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
