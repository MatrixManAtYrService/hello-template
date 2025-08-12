from typing import Annotated

import typer

# [[[cog
# import os
# version = os.environ.get("HELLO_VERSION", "0.1.0-dev")
# cog.out(f'__version__ = "{version}"')
# ]]]
__version__ = "0.1.1-dev202508122307"
# [[[end]]]

app = typer.Typer(help="Hello world CLI application")


def message() -> str:
    return "hello world!"


def version_callback(value: bool) -> None:
    """Show version and exit."""
    if value:
        typer.echo(f"hello {__version__}")
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
