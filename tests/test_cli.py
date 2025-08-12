import subprocess
from pathlib import Path

from hello import cli

repo_root = Path(__file__).parent.parent


def test_msg() -> None:
    assert cli.message() == "hello world!"


def test_stdout() -> None:
    # Same test but checking stdout specifically
    result = subprocess.run(["nix", "run"], cwd=repo_root, capture_output=True, text=True)

    assert result.returncode == 0
    assert "hello world" in result.stdout
