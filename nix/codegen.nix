{ pkgs, ... }:

let
  common = import ./common.nix { inherit pkgs; };
  inherit (common) makeCheck createAnalysisPackage;

  # Import version information
  version = import ./version.nix;

  # Convert version info to environment variables for Cog
  versionEnv = {
    HELLO_VERSION = version.python.version;
    HELLO_VERSION_MAJOR = toString version.major;
    HELLO_VERSION_MINOR = toString version.minor;
    HELLO_VERSION_PATCH = toString version.patch;
  };

  # List of files that contain Cog blocks for code generation
  files = [
    "nix/version.nix"
    "pyproject.toml"
    "src/hello/__init__.py"
    "src/hello/cli.py"
  ];

  # Generate version check
  generateVersionCheck = makeCheck {
    name = "generate-version";
    description = "Generate version information in source files";
    dependencies = with pkgs; [ python3Packages.cogapp ];
    environment = versionEnv;
    command = ''
      echo "Generating version information..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r ${file}") files)}
      echo "Version generation complete."
    '';
    verboseCommand = ''
      echo "Generating version information with verbose output..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r -v ${file}") files)}
      echo "Version generation complete."
    '';
  };

  # Trim whitespace check
  trimWhitespaceCheck = makeCheck {
    name = "trim-whitespace";
    description = "Trim trailing whitespace from source files";
    dependencies = with pkgs; [ gnused findutils ];
    command = ''
      echo "Trimming trailing whitespace..."
      find . -type f \( -name "*.py" -o -name "*.toml" -o -name "*.nix" -o -name "*.md" \) \
        -not -path "./.*" -not -path "./result*" -not -path "./build*" -not -path "./dist*" \
        -exec sed -i 's/[[:space:]]*$//' {} \;
      echo "Whitespace trimming complete."
    '';
    verboseCommand = ''
      echo "Trimming trailing whitespace with verbose output..."
      find . -type f \( -name "*.py" -o -name "*.toml" -o -name "*.nix" -o -name "*.md" \) \
        -not -path "./.*" -not -path "./result*" -not -path "./build*" -not -path "./dist*" \
        -print -exec sed -i 's/[[:space:]]*$//' {} \;
      echo "Whitespace trimming complete."
    '';
  };
in
createAnalysisPackage {
  name = "codegen";
  description = "Code generation (version sync and whitespace cleanup)";
  checks = {
    generate-version = generateVersionCheck;
    trim-whitespace = trimWhitespaceCheck;
  };
}
