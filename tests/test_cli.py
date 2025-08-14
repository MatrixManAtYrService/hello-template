import subprocess
from pathlib import Path

# [[[cog
# import os
# project_name = os.environ["PROJECT_NAME"]
# greeting = os.environ["PROJECT_GREETING"]
# cog.outl(f"from {project_name} import cli")
# cog.outl()
# cog.outl(f'greeting = "{greeting}"')
# ]]]
from hello import cli

greeting = "hello world!"
# [[[end]]]

repo_root = Path(__file__).parent.parent


def test_msg() -> None:
    assert cli.message() == greeting


def test_stdout() -> None:
    # Same test but checking stdout specifically
    result = subprocess.run(["nix", "run"], cwd=repo_root, capture_output=True, text=True)

    assert result.returncode == 0
    assert "hello world!" in result.stdout
