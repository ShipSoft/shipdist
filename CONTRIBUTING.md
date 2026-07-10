# Contributing to shipdist

`shipdist` holds the [alidist](https://github.com/alisw/alidist) recipes used to
build `FairShip` and its dependencies with `aliBuild`. As part of the SHiP
Collaboration, we follow a set of standards to keep the recipes clean and
consistent.

## Development Workflow

1. **Fork and Clone**: Create a fork of the repository and clone it locally.
2. **Environment**: The linting toolchain is provisioned with [pixi](https://pixi.sh):
   ```bash
   pixi install
   ```
3. **Pre-commit Hooks**: We use [`prek`](https://github.com/j178/prek) (a drop-in `pre-commit` replacement) to enforce coding standards. The hook tools come from the pixi `lint` environment, so versions are tracked in `pixi.lock` and run identically everywhere. Install the hooks once:
   ```bash
   pixi run install-hooks
   ```
   Run all hooks manually at any time with `pixi run lint`. This runs the recipe
   linters (`alidistlint`, `shellcheck`, `yamllint`) that also gate CI.
4. **Branching**: Create a feature branch for your changes.
5. **Commits**: We follow [Conventional Commits](https://www.conventionalcommits.org/) (validated by `commitizen`).
6. **Submission**: Open a Pull Request against the `main` branch. Ensure the CI passes (recipe checks and linting).
