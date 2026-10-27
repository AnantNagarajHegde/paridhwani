# Paridhwani — Learn. Play. Belong.

Master repository for the Paridhwani RPG-based Kannada-learning project. It brings the three active development areas together as independently versioned Git submodules.

## Repositories

| Area | Repository | Scope |
|---|---|---|
| Language Engine | [`language-engine`](https://github.com/AnantNagarajHegde/language-engine) | Kannada curriculum and content, English → Kanglish → Kannada progression, Kanglish processing, transliteration, conversational intelligence, response evaluation, feedback, and adaptation. |
| Game | [`game`](https://github.com/AnantNagarajHegde/game) | Product experience, world, story, characters, quests, progression, and game interface. |
| Integration Pipeline | [`integration-pipeline`](https://github.com/AnantNagarajHegde/integration-pipeline) | Research, requirements, resource tracking, evaluation, user testing, cross-component integration, and project documentation. |

Learning design and NLP are grouped in Language Engine. Each submodule keeps its own Git history and can be worked on independently.

## Clone

Clone this repository with its submodules:

```sh
git clone --recurse-submodules https://github.com/AnantNagarajHegde/paridhwani.git
```

For a master repo cloned without submodules, initialize them with:

```sh
git submodule update --init --recursive
```

## Automatic component updates

Each component repository has a GitHub Actions workflow that dispatches an update event to this master repository after a push to its `main` branch. The master workflow fetches the latest `main` commit from all three components, updates the submodule pointers, and pushes a commit to `main`. It also runs hourly as a fallback and can be started manually with **Actions → Update component pointers → Run workflow**.

### Required Actions secrets

Create fine-grained personal access tokens with the permissions below, then add them as repository Actions secrets. Do not commit token values to the repositories.

- In the **master repository**, add `SUBMODULES_READ_TOKEN`: grant **Contents: read-only** on `game`, `language-engine`, and `integration-pipeline`.
- In **each component repository**, add `MASTER_REPO_DISPATCH_TOKEN`: grant **Contents: read and write** on the `paridhwani` master repository. The repository-dispatch API requires Contents write access on its target repository.

The master workflow uses its built-in `GITHUB_TOKEN` with `Contents: read and write` to commit updated submodule pointers. The notification workflows only run for pushes to `main`; feature branches update the master after they are merged into `main`.
