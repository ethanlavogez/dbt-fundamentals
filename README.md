# dbt Fundamentals — adapté pour DuckDB

J'ai réalisé ce projet pour **apprendre dbt avec DuckDB**, en suivant le cours **dbt Fundamentals** de dbt Labs. Le cours étant conçu pour Snowflake, je l'ai adapté pour qu'il tourne **entièrement en local avec DuckDB**, la base de données avec laquelle je souhaitais travailler.

Le projet transforme les données brutes d'une boutique fictive (*Jaffle Shop*) et de son prestataire de paiement (*Stripe*) en tables propres, testées et prêtes pour l'analyse.

## Stack

- **dbt v2** (moteur Fusion) + extension dbt pour VS Code
- **DuckDB** comme base de données locale (aucun compte cloud nécessaire)
- **Git / GitHub** pour le versioning

## Architecture

Le projet suit le découpage en couches recommandé par dbt :

```
SOURCES (raw)                 STAGING (nettoyage)              MARTS (tables finales)

jaffle_shop.customers  →  stg_jaffle_shop_customers  ───────────────────────┐
                                                                            ├→ dim_customers
jaffle_shop.orders     →  stg_jaffle_shop_orders     ─┐                     │
                                                      ├→ fct_orders ────────┘
stripe.payment         →  stg_stripe__payments       ─┘
```

| Couche | Rôle | Matérialisation |
|---|---|---|
| **Sources** | Données brutes chargées dans la base `raw`, déclarées en YAML | — |
| **Staging** | Un modèle par source : renommage des colonnes, conversion des montants (centimes → dollars) | Vue |
| **Marts** | Tables métier : un fait (`fct_orders`) et une dimension (`dim_customers`) | Table |

### Modèles

- **`stg_jaffle_shop_customers`**, **`stg_jaffle_shop_orders`**, **`stg_stripe__payments`** : nettoyage des trois tables sources.
- **`fct_orders`** : une ligne par commande, avec le client et le montant total payé (paiements réussis uniquement).
- **`dim_customers`** : une ligne par client, avec ses dates de première et dernière commande, son nombre de commandes et le montant total dépensé (`lifetime_value`).

## Tests

- **Tests génériques** (YAML) : `unique` et `not_null` sur les clés, `accepted_values` sur le statut des commandes, `relationships` pour garantir que chaque commande appartient à un client existant.
- **Test singulier** (SQL) : vérifie qu'aucune commande n'a un montant total de paiements négatif.

## Adaptations pour DuckDB

Le cours étant conçu pour Snowflake, plusieurs adaptations ont été nécessaires :

- **Chargement des données brutes** : la macro `macros/load_raw.sql` crée la base `raw` à partir des CSV du dossier `raw_data/`, et ajoute les colonnes techniques `_etl_loaded_at` et `_batched_at` présentes dans le setup Snowflake.
- **Nom de la base** : le fichier s'appelle `raw.duckdb`, car DuckDB nomme la base d'après le fichier. Les références `raw.jaffle_shop.*` du cours fonctionnent ainsi sans modification.
- **Limites rencontrées** : `dbt source freshness` n'est pas encore implémenté pour l'adaptateur DuckDB (bêta) dans dbt v2.

## Ce que j'ai appris.

- Structurer un projet dbt en couches (sources → staging → marts) et appliquer les conventions de nommage (`stg_`, `fct_`, `dim_`)
- Utiliser `source()` et `ref()` pour construire automatiquement le DAG
- Écrire des tests génériques et singuliers pour garantir la qualité des données
