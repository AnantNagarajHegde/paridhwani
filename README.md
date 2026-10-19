# Paridhwani — Learn. Play. Belong.

Master repository for the Paridhwani RPG-based Kannada-learning project. It brings the four independently versioned development areas together as Git submodules.

## Repositories

| Area | Repository | Scope |
|---|---|---|
| Product & Game Experience | [`product-game-experience`](https://github.com/AnantNagarajHegde/product-game-experience) | Product concept, world, story, characters, quests, progression, and player experience. |
| Language & Learning | [`language-learning`](https://github.com/AnantNagarajHegde/language-learning) | Kannada curriculum, learning content, feedback, and English → Kanglish → Kannada progression. |
| NLP & Intelligence | [`nlp-intelligence`](https://github.com/AnantNagarajHegde/nlp-intelligence) | Kanglish handling, transliteration, conversation, response evaluation, and adaptation. |
| Research, Evaluation & Integration | [`research-evaluation-integration`](https://github.com/AnantNagarajHegde/research-evaluation-integration) | Research, requirements, evaluation, user testing, integration coordination, and documentation. |

## Clone

Clone this repository with its submodules:

```sh
git clone --recurse-submodules https://github.com/AnantNagarajHegde/paridhwani.git
```

If the master repository was cloned without submodules, initialize them with:

```sh
git submodule update --init --recursive
```

Each submodule has its own Git history and can also be cloned and worked on independently.
