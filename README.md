# ProjektZespolowy

## Setup

Once per machine/clone — full details in [AGENTS.md](AGENTS.md#local-setup):

```bash
winget install --id GitHub.cli        # or: brew install gh
gh auth login
gh auth refresh -s project
git config core.hooksPath .githooks
```

## Contributing

- Working standards, roles, branching, commits, and TDD rules: [AGENTS.md](AGENTS.md)
- Architecture decisions: [docs/adr/](docs/adr/README.md)
- Contributors and roles: [docs/CONTRIBUTORS.md](docs/CONTRIBUTORS.md)
