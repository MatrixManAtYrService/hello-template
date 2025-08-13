# Single source of truth for version information across project
let
  # The code below is generated, see nix/version-bump.nix for the code that generates it.
  #
  # It's also ok to update it by hand.
  # Since the code generation step reads its previous state before generating its new state, your edits will
  # be respected.
  #
  # [[[cog
  # import os
  # cog.outl(f'  major = {os.environ.get("VERSION_MAJOR", "0")};')
  # cog.outl(f'  minor = {os.environ.get("VERSION_MINOR", "1")};')
  # cog.outl(f'  patch = {os.environ.get("VERSION_PATCH", "0")};')
  # cog.outl(f'  prerelease = "{os.environ.get("VERSION_PRERELEASE", "dev202512170800")}"; # Set by --prerelease, empty for stable releases')
  # ]]]
  major = 0;
  minor = 1;
  patch = 0;
  prerelease = "dev202512170800"; # Set by --prerelease, empty for stable releases
  # [[[end]]]

  # Synthesized version strings from components
  baseVersion = "${builtins.toString major}.${builtins.toString minor}.${builtins.toString patch}";
  version = baseVersion + (if prerelease != "" then "-${prerelease}" else "");
in
{
  # Export version components
  inherit major minor patch prerelease;

  # Synthesized version strings
  inherit version;

  # Package-specific formats
  python = {
    # Referenced in: pyproject.toml, src/PROJECT_NAME/__init__.py, src/PROJECT_NAME/cli.py
    # Used as: Python package version
    inherit version;
  };
}
