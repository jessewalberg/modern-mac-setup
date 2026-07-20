# Project Runtimes

A machine-wide runtime is shared mutable state. Projects should declare their own versions so the same repository behaves consistently across machines and over time.

This guide uses two complementary tools:

- `uv` for Python versions, environments, dependencies, projects, scripts, and Python CLI tools;
- `mise` for Node.js, Go, Java, Ruby, Terraform, and other project-scoped developer tools.

Using both to manage the same Python installation is possible but creates unnecessary ambiguity. The default policy is `uv` for Python and `mise` for other runtimes.

## Python with uv

Create or adopt a project:

```bash
mkdir example-python
cd example-python
uv init
uv python pin 3.14
uv add requests
uv run python -c 'import requests; print(requests.__version__)'
```

Use the Python version supported by the project; `3.14` is only an example. Commit the project's `pyproject.toml`, `uv.lock`, and relevant version file. Do not commit `.venv`.

For a one-off Python command-line tool:

```bash
uvx ruff check .
```

For a tool that must remain available outside one project:

```bash
uv tool install ruff
```

Prefer `uvx` for occasional use because it keeps the environment disposable and reduces long-lived global state. Avoid `sudo pip install`, and avoid mutating uv-managed tool environments with direct `pip` commands.

Official documentation:

- [uv overview](https://docs.astral.sh/uv/)
- [Projects](https://docs.astral.sh/uv/concepts/projects/)
- [Python versions](https://docs.astral.sh/uv/concepts/python-versions/)
- [Tools](https://docs.astral.sh/uv/concepts/tools/)

## Other runtimes with mise

Inside a project, select the exact versions required by that project. Replace the placeholders below with real supported versions:

```bash
cd existing-project
mise use node@X.Y.Z
mise use go@X.Y.Z
mise install
mise current
```

Review and commit the generated `mise.toml` or other version file. The committed project configuration, not the new-Mac guide, becomes the source of truth.

Useful checks:

```bash
mise doctor
mise current
mise outdated
```

The shell snippet activates `mise` as directories change. Avoid putting secret values directly in committed `mise.toml` files. Use ignored local environment files or an approved secrets manager for sensitive data.

Official documentation:

- [mise overview](https://mise.jdx.dev/)
- [Installation](https://mise.jdx.dev/installing-mise.html)
- [Configuration](https://mise.jdx.dev/configuration.html)
- [Environments](https://mise.jdx.dev/environments/)

## Containers and databases

Containers are not a universal prerequisite. Choose Docker Desktop, OrbStack, Podman, Colima, or another platform according to licensing, team compatibility, Kubernetes needs, networking behavior, and resource use.

Do not install multiple container desktop platforms merely to compare them on a production machine. They may compete for sockets, virtual machines, login items, networking helpers, and substantial disk space.

Databases should usually be project-scoped through containers, a local service declared in a project Brewfile, or a managed remote environment. Avoid auto-starting every database at login.

## Global tools that deserve scrutiny

Before installing a global package from npm, PyPI, RubyGems, Cargo, or another registry, ask:

1. Can the project declare it as a development dependency?
2. Can it run ephemerally through `uvx`, `npx`, or `mise exec`?
3. Does installation execute publisher-controlled lifecycle scripts?
4. Is the exact package name verified against the upstream project?
5. Is the tool still maintained and needed?

This reduces typosquatting, dependency drift, and invisible machine requirements.

Continue with [Applications and preferences](05-apps-and-preferences.md).
