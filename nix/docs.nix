# Documentation generation for hello project
{ pkgs, ... }:

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

    # Generate hello docs
    echo '📚 Generating hello documentation...'
    pdoc --output-directory docs hello
    echo '📚 Generated hello docs in ./docs/ directory'

    echo '📚 Documentation has been generated in docs/ directory'
    echo '💡 Open docs/hello.html in your browser to view the documentation'
  '';

  # Create a single check that generates all docs
  pdocCheck = makeCheck {
    name = "pdoc";
    description = "Generate API documentation for hello";
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
