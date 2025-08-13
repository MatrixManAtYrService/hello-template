import subprocess
from pathlib import Path

# [[[cog
# import os
# project_name = os.environ.get("PROJECT_NAME", "hello")
# cog.out(f"from {project_name} import cli")
# ]]]
from hello import cli

# [[[end]]]

repo_root = Path(__file__).parent.parent


def test_msg() -> None:
    # [[[cog
    # import os
    # greeting = os.environ.get("PROJECT_GREETING", "hello world!")
    # cog.out(f'    assert cli.message() == "{greeting}"')
    # ]]]
    assert cli.message() == "hello world!"
    # [[[end]]]


def test_stdout() -> None:
    # Same test but checking stdout specifically
    result = subprocess.run(["nix", "run"], cwd=repo_root, capture_output=True, text=True)

    assert result.returncode == 0
    # [[[cog
    # import os
    # greeting = os.environ.get("PROJECT_GREETING", "hello world!")
    # cog.out(f'    assert "{greeting}" in result.stdout')
    # ]]]
    assert "hello world!" in result.stdout
    # [[[end]]]
