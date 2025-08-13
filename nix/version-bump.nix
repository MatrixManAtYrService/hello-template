# Version bumping script for project
{ pkgs, ... }:

let
  # Import version information
  version = import ./version.nix;

  # Script to bump version and regenerate files using Cog
  versionBumpScript = pkgs.writeShellScript "version-bump" ''
    set -euo pipefail

    # Parse command line arguments
    BUMP_TYPE=""
    VERBOSE=false

    while [[ $# -gt 0 ]]; do
      case $1 in
        --patch)
          BUMP_TYPE="patch"
          shift
          ;;
        --minor)
          BUMP_TYPE="minor"
          shift
          ;;
        --major)
          BUMP_TYPE="major"
          shift
          ;;
        --prerelease)
          BUMP_TYPE="prerelease"
          shift
          ;;
        -v|--verbose)
          VERBOSE=true
          shift
          ;;
        -h|--help)
          echo "Usage: version-bump [--patch|--minor|--major|--prerelease] [-v|--verbose] [-h|--help]"
          echo ""
          echo "Bump version in nix/version.nix and regenerate all dependent files using Cog."
          echo ""
          echo "Options:"
          echo "  --patch       Increment patch version (e.g., 0.1.0 -> 0.1.1)"
          echo "  --minor       Increment minor version (e.g., 0.1.0 -> 0.2.0)"
          echo "  --major       Increment major version (e.g., 0.1.0 -> 1.0.0)"
          echo "  --prerelease  Add prerelease timestamp (e.g., 0.1.0 -> 0.1.0-dev202512171234)"
          echo "  -v, --verbose Enable verbose output"
          echo "  -h, --help    Show this help message"
          echo ""
          echo "Prerelease format: devYYYYMMDDHHMM (UTC time)"
          echo "This is useful for CI iterations without bumping the actual version."
          echo ""
          echo "After updating version.nix, runs 'nix run .#codegen' to"
          echo "propagate changes via Cog to all files with version templates."
          exit 0
          ;;
        *)
          echo "Error: Unknown option $1"
          echo "Use --help for usage information"
          exit 1
          ;;
      esac
    done

    if [[ -z "$BUMP_TYPE" ]]; then
      echo "Error: Must specify --patch, --minor, --major, or --prerelease"
      echo "Use --help for usage information"
      exit 1
    fi

    # Check for uncommitted changes
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
      echo "Error: Uncommitted changes detected in working directory"
      echo ""
      echo "Please commit or stash your changes before bumping the version:"
      echo "  git add . && git commit -m \"Your changes\""
      echo "  # OR"
      echo "  git stash"
      echo ""
      echo "This prevents version bump conflicts with uncommitted work."
      exit 1
    fi

    # Get current version components from Nix
    CURRENT_MAJOR=${builtins.toString version.major}
    CURRENT_MINOR=${builtins.toString version.minor}
    CURRENT_PATCH=${builtins.toString version.patch}
    CURRENT_VERSION="$CURRENT_MAJOR.$CURRENT_MINOR.$CURRENT_PATCH"

    if [[ "$VERBOSE" == "true" ]]; then
      echo "Current version: $CURRENT_VERSION"
      echo "Bump type: $BUMP_TYPE"
    fi

    # Calculate new version components and set environment variables for Cog
    case $BUMP_TYPE in
      patch)
        export VERSION_MAJOR=$CURRENT_MAJOR
        export VERSION_MINOR=$CURRENT_MINOR
        export VERSION_PATCH=$((CURRENT_PATCH + 1))
        export VERSION_PRERELEASE=""
        NEW_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"
        ;;
      minor)
        export VERSION_MAJOR=$CURRENT_MAJOR
        export VERSION_MINOR=$((CURRENT_MINOR + 1))
        export VERSION_PATCH=0
        export VERSION_PRERELEASE=""
        NEW_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"
        ;;
      major)
        export VERSION_MAJOR=$((CURRENT_MAJOR + 1))
        export VERSION_MINOR=0
        export VERSION_PATCH=0
        export VERSION_PRERELEASE=""
        NEW_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"
        ;;
      prerelease)
        # Generate UTC timestamp in Python-compatible format: dev202512171234
        UTC_TIMESTAMP=$(${pkgs.coreutils}/bin/date -u '+dev%Y%m%d%H%M')
        export VERSION_MAJOR=$CURRENT_MAJOR
        export VERSION_MINOR=$CURRENT_MINOR
        export VERSION_PATCH=$CURRENT_PATCH
        export VERSION_PRERELEASE="$UTC_TIMESTAMP"
        NEW_VERSION="$CURRENT_MAJOR.$CURRENT_MINOR.$CURRENT_PATCH-$UTC_TIMESTAMP"

        if [[ "$VERBOSE" == "true" ]]; then
          echo "Generated prerelease timestamp: $UTC_TIMESTAMP"
        fi
        ;;
    esac

    echo "Bumping version: $CURRENT_VERSION -> $NEW_VERSION"

    # Update version.nix using Cog
    [[ "$VERBOSE" == "true" ]] && set -x
    ${pkgs.python3Packages.cogapp}/bin/cog -r nix/version.nix
    [[ "$VERBOSE" == "true" ]] && set +x

    # Run codegen to propagate the version changes via Cog
    [[ "$VERBOSE" == "true" ]] && set -x
    if [[ "$VERBOSE" == "true" ]]; then
      VERSION_MAJOR=$VERSION_MAJOR VERSION_MINOR=$VERSION_MINOR VERSION_PATCH=$VERSION_PATCH VERSION_PRERELEASE=$VERSION_PRERELEASE ${pkgs.nix}/bin/nix run .#codegen -- -v
    else
      VERSION_MAJOR=$VERSION_MAJOR VERSION_MINOR=$VERSION_MINOR VERSION_PATCH=$VERSION_PATCH VERSION_PRERELEASE=$VERSION_PRERELEASE ${pkgs.nix}/bin/nix run .#codegen
    fi
    [[ "$VERBOSE" == "true" ]] && set +x

    # Update uv.lock by running lock command
    [[ "$VERBOSE" == "true" ]] && set -x
    ${pkgs.uv}/bin/uv lock
    [[ "$VERBOSE" == "true" ]] && set +x

    echo "✅ Version bump complete: $CURRENT_VERSION -> $NEW_VERSION"
    echo "💡 All files with version templates have been updated via Cog"
    echo ""
    if [[ "$BUMP_TYPE" == "prerelease" ]]; then
      echo "🧪 Prerelease version created for CI testing"
      echo "💡 Use --patch/--minor/--major for final release"
    else
      echo "🚀 Ready to commit and release version $NEW_VERSION"
      echo ""
      echo "💡 Suggestion:"
      echo "git add . ; git commit -m \"Version: $NEW_VERSION\" ; git tag v$NEW_VERSION ; git push --tags origin main"
    fi
  '';

in
pkgs.stdenv.mkDerivation {
  pname = "version-bump";
  inherit (version) version;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${versionBumpScript} $out/bin/version-bump
    chmod +x $out/bin/version-bump
  '';

  meta = with pkgs.lib; {
    description = "Version bumping script with prerelease support";
    mainProgram = "version-bump";
    platforms = platforms.unix;
  };
}
