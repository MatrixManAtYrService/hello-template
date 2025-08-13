[![Test](https://github.com/MatrixManAtYrService/hello-template/workflows/Test/badge.svg)](https://github.com/MatrixManAtYrService/hello-template/actions/workflows/test.yml)

# hello

This is a project template, it merely says "hello world" when you run it.
The idea is that it's a stand-in for similar projects which do something more useful.

## Using as a Template

To use this as a template for your own project:

1. **Copy this repository**
2. **Update `nix/constants.nix`** - Change the `name` and `greeting` values:
   ```nix
   {
     name = "my-project";        # Your project name
     greeting = "Hello there!";  # Your CLI greeting message
   }
   ```
3. **Run the code generator** to apply changes:
   ```bash
   nix run .#codegen
   ```
4. Consider enabling github pages and updating the module docs in [src/hello/__init__.py](src/hello/__init__.py).
5. **Rename the source directory**: `mv src/hello src/my-project`
6. **Update CI badge** in README.md to point to your repository
7. **Regenerate `uv.lock`**
   ```
   nix develop --command "uv lock"
   ````
8. search the repo for "hello" to fix any other references (likely among the python source files)

The code generator will automatically update:
- `pyproject.toml` (project name and entry points)
- Python source files (import statements, greeting message, version output)
- Test files (imports and assertions)
- Documentation generation

## Things to try

Things to try from a shell with `uv` after cloning this repo:
```
$ uv run hello
hello world!

$ uv run hello --version
hello 0.1.1-dev202512170800

$ uv run pytest
# runs tests
```

Things to try from any shell with the `nix` command (no need to clone it first):

```
$ nix run github:MatrixManAtYrService/hello-template
hello world!

$ nix build github:MatrixManAtYrService/hello-template
$ ./result/bin/hello
hello world!
```

Things to try from the nix devshell defined in [flake.nix](./flake.nix):
```
$ ./steps.sh
# runs linters
# runs tests
# generates ./docs

$ hello
hello world!

$ pytest
# runs tests

$ hello --version
hello 0.1.1-dev202512170800

$ nix run .#version-bump -- --minor
Bumping version: 0.1.1 -> 0.2.0
...
💡 Suggestion:
  git add . ; git commit -m "Version: 0.2.0" ; git tag v0.2.0 ; git push --tags origin main

$ hello --version
hello 0.2.0
```

note for direnv users: if you change pyproject.toml you may need to delete ./direnv and rerun `direnv allow`, I'm not sure why but otherwise you sometimes get a stale cached environment.

note for agents: for one-off cases you can also access the devshell environment like `nix develop --command {the command}`
