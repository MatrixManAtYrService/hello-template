{ pkgs, ... }:

let
  common = import ./common.nix { inherit pkgs; };
  inherit (common) makeCheck createAnalysisPackage;

  # Individual check definitions
  deadnixCheck = makeCheck {
    name = "deadnix";
    description = "Nix dead code analysis";
    dependencies = with pkgs; [ deadnix ];
    command = "deadnix -q .";
    verboseCommand = "deadnix .";
  };

  nixpkgsFmtCheck = makeCheck {
    name = "nixpkgs-fmt";
    description = "Nix file formatting";
    dependencies = with pkgs; [ nixpkgs-fmt ];
    command = ''find . -name "*.nix" -not -path "./.*" -not -path "./result*" -exec nixpkgs-fmt {} \;'';
    verboseCommand = ''find . -name "*.nix" -not -path "./.*" -not -path "./result*" -exec nixpkgs-fmt {} \;'';
  };

  statixCheck = makeCheck {
    name = "statix";
    description = "Nix static analysis";
    dependencies = with pkgs; [ statix ];
    command = "statix check .";
    verboseCommand = "statix check .";
  };
in
createAnalysisPackage {
  name = "nix-analysis";
  description = "Nix code analysis";
  checks = {
    deadnix = deadnixCheck;
    nixpkgs-fmt = nixpkgsFmtCheck;
    statix = statixCheck;
  };
}
