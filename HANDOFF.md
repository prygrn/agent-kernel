# Handoff — reprise de session (agent-kernel)

Ce fichier est un briefing de reprise, pas de la doc repo. Lis-le en entier avant d'agir.
Il te met dans le contexte exact d'une réflexion en cours et te dit comment te comporter.

---

## Qui est en face de toi

Ingénieur logiciel, 10 ans de C embarqué (systèmes), en transition web/mobile.
Seul humain sur ses projets. Orchestrateur d'agents. Fait des rushs d'app
(Shopify, mobile Expo/RN, web Astro/Next/Rails DDD), pas des gros SaaS.
Background système = raisonne en invariants, interfaces, cohérence de cache, endianness,
moindre privilège. Utilise ces analogies, elles portent.

## Comment tu te comportes (non négociable)

- Pragmatique avant tout. Droit au but. Pas de flatterie, pas d'édulcoration.
- Ne va JAMAIS dans son sens pour ménager son ego ou une appréhension. Si une idée est
  bancale, dis-le et dis pourquoi. Propose toujours l'option la plus raisonnable, pas la
  plus rassurante.
- Challenge activement : nomme le vrai problème sous le problème énoncé, corrige-toi si
  tu t'es mal exprimé, maintiens fermement ce qui doit l'être.
- Ton fin, un peu d'humour quand le contexte s'y prête. Jamais niais.
- Tu termines quand utile par UNE question qui cadre la suite, pas dix.
- Format : conversationnel, prose, pas de listes à puces gratuites ni de gras partout.
- Ne pars pas en excès de zèle : ne code/construis pas ce qui n'a pas été demandé. Si tu
  te surprends à le faire, c'est le signal d'arrêter (débordement de serviabilité).

## Ce qu'on construit

Un environnement agentique versionné. Architecture décidée : **2 repos**.

- `agent-kernel` (CE repo) — INVARIANTS, vrais pour tous les projets et toutes les stacks.
  Consommé en **submodule** → une amélioration profite à tous au prochain pull.
- `agent-modules` (séparé) — catalogue opt-in : langage / plateforme / direction artistique.
  Consommé en **copier-coller** → isolation projet.

## Les principes structurants (le socle)

1. Le vrai problème = **entropie de contexte** : la qualité des agents baisse quand le
   contexte se pollue (historique, décisions périmées, bruit). Pas un modèle qui fatigue.
2. **Mémoire normative** (specs + contrats) prime sur **mémoire narrative** (journal).
   En cas de contradiction journal vs spec : la spec gagne, le code est le bug à corriger.
3. **Contrat de feature** = projection des specs globales sur un périmètre. Léger (½ page) :
   objectif produit + conditions d'acceptation (= la QA, écrite en amont) + signatures de
   jonction si parallélisé. Référence absolue des agents dev/review/QA de la feature.
4. **Convention transversale → kernel. Signature de jonction locale → contrat de feature.**
5. Review = agent distinct, standards élevés, review CONTRE le contrat (pas juste propreté).
6. **Intégration sémantique** (décisions des lots parallèles compatibles entre elles :
   centimes vs euros, null vs objet vide, qui fait l'auth) = À FAIRE AVANT LE MERGE.
   N'existe pas sur les features mono-lot.

## LA distinction centrale : règles (always) vs rôles (skills)

Deux natures de fichiers, chargées différemment. Ne pas les confondre.

- **Règles "always"** — git, méthodologie, conventions transversales, méta-règle.
  Invariants de fond, chargés par TOUS les agents, EN PERMANENCE, indépendamment de la
  tâche. Ce ne sont PAS des skills (un skill est conditionnel ; un invariant ne l'est pas).
  Restent du Markdown neutre.

- **Rôles "skills"** — reviewer, QA, implémenteur. Savoir-faire encapsulé, UN SEUL chargé
  à la fois, activé selon le rôle assigné à l'agent. C'est exactement l'activation d'un
  skill → on adopte le standard **Agent Skills** (agentskills.io) pour ces fichiers.
  Bénéfice : chargement par divulgation progressive (nom+description au repos, instructions
  complètes seulement à l'activation) → réduit l'entropie, et "un agent = un rôle" devient
  une propriété du système au lieu d'une discipline manuelle.

Jonction : un rôle/skill DÉCLARE sa dépendance aux règles `always/` dont il a besoin,
il ne les duplique pas. Ex : skill reviewer s'appuie sur conventions + methodology.

## Rôles : permissions déclaratives (moindre privilège)

Le principe GÉNÉRAL "W sur specs interdit par défaut" vit dans `always/methodology.md`
(invariant, vaut pour tous les rôles). L'APPLICATION par rôle (le tableau de permissions)
vit dans le SKILL.md du rôle. Ne pas redupliquer l'invariant dans chaque rôle.

Permissions sur des RESSOURCES GÉNÉRIQUES (jamais des fichiers nommés) :
code source, tests, contrat de feature, specs, journal, PR/diff.
Un rôle ne déborde pas parce qu'une capacité absente ne peut pas déborder : on câble
l'isolation, on ne la demande pas.

Trois niveaux d'accès (R/W ne suffit pas) :

- R — lit la ressource.
- W — écrit / modifie la ressource.
- PROPOSE — émet une recommandation sans l'appliquer (ni R ni W). Ex : le reviewer signale
  un écart ; un AUTRE rôle appliquera la correction.

Interdit par défaut, sauf rôle unique et explicite : W sur specs / contrat.
Un agent qui réécrit la spec pour faire passer son code inverse la hiérarchie normative
(le narratif réécrit le normatif). Faille qui contourne tout le reste. Verrouiller.

Patron de tête de SKILL.md de rôle :

```
  PRODUCES:       <la sortie unique du rôle>
  NEVER PRODUCES: <la borne négative explicite>
  DEPENDS ON:     <règles always/ référencées, non dupliquées>
  PERMISSIONS:
    source code      : R | W | PROPOSE | none
    tests            : R | W | PROPOSE | none
    feature contract : R | W | PROPOSE | none
    specs            : R | W | PROPOSE | none   # W interdit sauf rôle dédié
    journal          : R | W | PROPOSE | none
    PR / diff        : R | W | PROPOSE | none
```

Une permission déclarée est VÉRIFIABLE : une sortie hors permissions se voit sans juger
le fond. Cohérent avec la méta-règle (une contrainte vaut si elle est vérifiable).

## Skills & MCP : où ça se range

- **Skill** (savoir-faire, procédure, rôle encapsulé) : format Agent Skills, dossier avec
  SKILL.md. Portable (adopté par Claude Code, Cursor, Copilot, Gemini CLI, Codex, etc.).
  Invariant → kernel. Spécifique techno/plateforme → module.
- **Règle** (invariant de fond) : Markdown neutre, PAS un skill. Kernel ou module selon portée.
- **MCP** (connexion à un service, credentials) : NI kernel NI module. Config projet, secrets
  HORS git. On peut versionner la déclaration d'un MCP (serveur, outils) sans les secrets.
  Un skill qui a besoin d'un MCP le DÉCLARE en dépendance ; le projet le fournit.

Test de rangement (dans l'ordre) :

1. Contient un secret / une connexion à un service ? → config projet, hors git.
2. Sinon, vrai pour tous mes projets ? → kernel.
3. Sinon → module.

## Agnosticité outil (rappel)

La vérité est dans du Markdown neutre sous `rules/`. Aucun nom d'outil dans le kernel.
Chaque projet consommateur pose un fichier d'exposition MINCE (CLAUDE.md, .cursor/rules…)
qui ne fait que rediriger : "Read all rules under .agents/rules/ before acting."
Le jour où on quitte un outil, on supprime un fichier de 3 lignes. Décision actée :
règles en `.md` pur (pas de frontmatter propriétaire type .mdc). Pour les skills, viser le
cœur portable du standard, éviter les extensions propres à un outil.

Le fichier d'exposition couvre DEUX chemins : always/ (chargé en entier, toujours — hors format skill) et roles/ (skills chargés en divulgation progressive par l'outil). Il déclare seulement OÙ regarder, il ne réimplémente pas le chargement.

## Architecture du repo (cible)

```
agent-kernel/
  README.md
  HANDOFF.md            # ce fichier (temporaire : à jeter quand le setup est figé)
  rules/
    always/             # RÈGLES — chargées par tous, en permanence, Markdown neutre
      meta.md           # la méta-règle sur les règles (le standard)
      git.md
      methodology.md    # contrat de feature, review vs contrat, intégration sémantique,
                        #   hiérarchie normative, "W specs interdit par défaut"
      conventions.md    # conventions transversales (centimes, null, auth middleware…)
    roles/              # SKILLS (format Agent Skills) — un seul chargé, activé au besoin
      reviewer/
        SKILL.md
      qa/
        SKILL.md
      implementer/
        SKILL.md
```

Note : `always/` et `roles/` sont de NATURES différentes (voir la distinction centrale).
Les fichiers restent courts, à responsabilité unique → chargement sélectif, moins de bruit.

## La règle d'or (contre la paralysie)

**On n'extrait que ce qui a DÉJÀ été répété. Rien de spéculatif.**
Le repo se remplit par sédimentation, pas par anticipation. Process proportionné au risque
de la feature, pas court par principe. Une tâche n'existe pas tant qu'un fait concret
(projet qui démarre, pattern répété 2×) ne l'a pas déclenchée.

## La méta-règle sur les règles

Une règle : 1 phrase, non ambiguë, vérifiable, EN ANGLAIS, pas de "mais/sauf si"
(sinon = 2 règles), invariante. Concision par ATOMICITÉ, pas par style caveman.
Ce n'est pas un skill à aller chercher : c'est cette méta-règle, écrite une fois, dans
always/meta.md. Une fois posée, on peut demander à un agent "challenge cette règle" et il
a le critère pour dire : ambiguë / c'est deux règles / pas vérifiable.

## État d'avancement

FAIT (décidé) :

- Architecture 2 repos + noms + submodule vs copier-coller.
- Langue des règles : anglais. Style : phrases atomiques, pas caveman. Fichiers en .md pur.
- Distinction always (règles, toujours chargées) vs roles (skills, activés à la demande).
- Adoption du standard Agent Skills (agentskills.io) pour les rôles/skills.
- Règle de rangement skill / règle / MCP (secrets hors git).
- Permissions de rôle R/W/PROPOSE, invariant "W specs interdit" dans always/methodology.
- Un prompt d'agent "convertisseur de règles" existe (traite par lots, verdicts
  KEEP/REWRITE/SPLIT/MODULE/DROP, flag les contradictions). Prêt à l'emploi.

À FAIRE — tâche de CETTE semaine, une seule :

1. Créer le repo kernel + l'arborescence rules/always + rules/roles (fait ou en cours).
2. Écrire always/meta.md (la méta-règle — seul contenu VRAIMENT neuf).
3. Importer les règles communes éparpillées dans les anciens projets, TOUTES passées au
   filtre de la méta-règle via l'agent convertisseur. Ce premier import est aussi le
   premier NETTOYAGE : ce qui n'est pas invariant → module ou poubelle. Ranger chaque
   règle importée dans always/ (invariant de fond) ou en candidate rôle/skill.

EN SOMMEIL (ne pas construire tant que non déclenché par une 2e répétition) :

- Conversion effective des rôles en skills Agent Skills (viendra quand les rôles seront
  stabilisés — pour l'instant on pose juste la structure roles/).
- Skill d'orchestration du workflow, catalogue complet de modules, skill UI/UX maison,
  skills Shopify (scaffolding).

## Ce que tu peux faire maintenant, utilement

- Aider à finaliser always/meta.md si pas fait.
- Faire tourner / affiner le tri des règles importées (always vs rôle vs module vs drop).
- Aider à poser la structure du repo.
- Ne PAS partir construire les trucs en sommeil.

## Garde-fou pour toi-même

Mode par défaut : minimal, éprouvé, incrémental. Si tu veux tout mettre en place d'un coup
ou ajouter des règles non demandées : stop. Mets à jour la section "État d'avancement" de
ce fichier avant de clôturer une session, pour que la prochaine reprise reparte d'un état juste.
