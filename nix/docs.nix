# Documentation generation for project
{ pkgs, constants, ... }:

let
  common = import ./common.nix { inherit pkgs; };
  inherit (common) makeCheck createAnalysisPackage;

  # Create a Python script for post-processing documentation
  postProcessScript = pkgs.writeText "post_process_docs.py" ''
    import re
    import subprocess
    import sys
    from pathlib import Path


    def get_command_output(command: str) -> str:
        """Run a command and return its output."""
        try:
            result = subprocess.run(
                command.split(),
                capture_output=True,
                text=True,
                check=True,
                cwd="."  # Ensure we're in the right directory
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            return f"Error running command: {e}"


    def process_html_file(file_path: Path) -> None:
        """Process an HTML file to replace template placeholders."""
        print(f"Processing {file_path}")

        with open(file_path, 'r') as f:
            content = f.read()

        # Replace # DOCS_OUTPUT: command placeholders
        def replace_output(match):
            command = match.group(1).strip()
            output = get_command_output(command)
            return output

        content = re.sub(r'# DOCS_OUTPUT:\s*([^\n]+)', replace_output, content)

        # Write back the processed content
        with open(file_path, 'w') as f:
            f.write(content)


    if __name__ == "__main__":
        docs_dir = Path("docs")

        # Process all HTML files in the docs directory
        for html_file in docs_dir.rglob("*.html"):
            process_html_file(html_file)

        print("✅ Post-processing complete")
  '';

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

    # Post-process the generated docs to replace template placeholders
    echo '🔄 Post-processing documentation templates...'
    PYTHONPATH="src:$PYTHONPATH" python ${postProcessScript}

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
