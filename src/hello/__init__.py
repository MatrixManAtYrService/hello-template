"""
# hello

For public repos (or private ones with enterprise subscriptions), you can enable github pages in *settings* and API docs will appear at [https://{username}.github.io/{repo}/{package name}.html](https://matrixmanatyrservice.github.io/hello-template/hello.html).

Docstrinsg on public functions get included in the docs.
More on this [here](https://pdoc.dev/docs/pdoc.html).
"""
# [[[cog
# import os
# version = os.environ.get("VERSION", "0.1.0-dev")
# cog.out(f'__version__ = "{version}"')
# ]]]
__version__ = "0.1.0-dev202512170800"
# [[[end]]]
