{ pkgs, constants, ... }:

let
  common = import ./common.nix { inherit pkgs; };
  inherit (common) makeCheck createAnalysisPackage;

  # Import version information
  version = import ./version.nix;

  # Environment variables for version generation
  versionEnv = {
    VERSION = version.python.version;
    VERSION_MAJOR = toString version.major;
    VERSION_MINOR = toString version.minor;
    VERSION_PATCH = toString version.patch;
  };

  # Environment variables for constants/project template generation
  constantsEnv = {
    PROJECT_NAME = constants.name;
    PROJECT_GREETING = constants.greeting;
  };

  # Files that contain version information
  versionFiles = [
    "nix/version.nix"
    "pyproject.toml"
    "src/${constants.name}/__init__.py"
    "src/${constants.name}/cli.py"
  ];

  # Files that contain project constants/template information
  constantsFiles = [
    "pyproject.toml"
    "src/${constants.name}/cli.py"
    "tests/test_cli.py"
  ];

  # Generate version check
  generateVersionCheck = makeCheck {
    name = "generate-version";
    description = "Generate version information in source files";
    dependencies = with pkgs; [ python3Packages.cogapp ];
    environment = versionEnv;
    command = ''
      echo "Generating version information..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r ${file}") versionFiles)}
      echo "Version generation complete."
    '';
    verboseCommand = ''
      echo "Generating version information with verbose output..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r -v ${file}") versionFiles)}
      echo "Version generation complete."
    '';
  };

  # Generate constants check
  generateConstantsCheck = makeCheck {
    name = "generate-constants";
    description = "Generate project constants in source files";
    dependencies = with pkgs; [ python3Packages.cogapp ];
    environment = constantsEnv;
    command = ''
      echo "Generating project constants..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r ${file}") constantsFiles)}
      echo "Constants generation complete."
    '';
    verboseCommand = ''
      echo "Generating project constants with verbose output..."
      ${pkgs.lib.concatStringsSep "\n" (map (file: "cog -r -v ${file}") constantsFiles)}
      echo "Constants generation complete."
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
  description = "Code generation (version sync, constants, and whitespace cleanup)";
  checks = {
    generate-constants = generateConstantsCheck;
    generate-version = generateVersionCheck;
    trim-whitespace = trimWhitespaceCheck;
  };
}
