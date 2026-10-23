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
