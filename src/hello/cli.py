from typing import Annotated

import typer

# [[[cog
# import os
# version = os.environ.get("VERSION", "0.1.0-dev")
# cog.out(f'__version__ = "{version}"')
# ]]]
__version__ = "0.1.0-dev202512170800"
# [[[end]]]

app = typer.Typer(help="Hello world CLI application")


def message() -> str:
    # [[[cog
    # import os
    # greeting = os.environ.get("PROJECT_GREETING", "hello world!")
    # cog.out(f'    return "{greeting}"')
    # ]]]
    return "hello world!"
    # [[[end]]]


def version_callback(value: bool) -> None:
    """Show version and exit."""
    if value:
        # [[[cog
        # import os
        # project_name = os.environ.get("PROJECT_NAME", "hello")
        # cog.out(f'        typer.echo(f"{project_name} {{__version__}}")')
        # ]]]
        typer.echo(f"hello {__version__}")
        # [[[end]]]
        raise typer.Exit()


@app.command()
def hello(
    version: Annotated[
        bool,
        typer.Option(
            "--version",
            callback=version_callback,
            is_eager=True,
            help="Show version and exit",
        ),
    ] = False,
) -> None:
    """Print a friendly greeting."""
    typer.echo(message())


def main() -> None:
    app()
