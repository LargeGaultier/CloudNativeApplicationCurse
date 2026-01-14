# Plan Blue/Green (TP5)

## 1) Strategie et structure
- Conserver une base Postgres unique et partager son reseau avec les deux versions.
- Utiliser un reverse proxy Nginx comme point d'entree unique.
- Avoir deux stacks applicatives paralleles: blue et green.
- Ne jamais arreter l'ancienne version avant la bascule du proxy.

## 2) Fichiers Docker Compose proposes
- `docker-compose.base.yml`
  - postgres (volume nomme)
  - reverse-proxy (nginx)
  - reseau `app_net`
- `docker-compose.blue.yml`
  - backend-blue
  - frontend-blue
  - labels/hostname explicites
- `docker-compose.green.yml`
  - backend-green
  - frontend-green
  - labels/hostname explicites

Commandes:
- Demarrage blue:
  - `docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d`
- Demarrage green:
  - `docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d`

## 3) Reverse proxy et bascule
Option retenue: Nginx avec un include dynamique.
- `nginx.conf` contient:
  - `include /etc/nginx/conf.d/active_upstream.conf;`
- `active_upstream.conf` pointe vers blue OU green.

Bascule:
- Le pipeline ecrit `active_upstream.conf` (blue ou green).
- `docker exec reverse-proxy nginx -s reload`

Rollback:
- Re-ecrire `active_upstream.conf` vers l'ancienne couleur.
- Reload Nginx. Pas besoin d'arreter la nouvelle version.

Exemple rollback vers blue:
```
upstream app_backend { server backend-blue:3000; }
upstream app_frontend { server frontend-blue:80; }
```
Puis:
```
docker exec reverse-proxy nginx -s reload
```

## 4) Scenario de deploiement
- Etat initial: blue actif, green inactif.
- Deploiement:
  1) Construire/puller les images pour la couleur inactive (green).
  2) `docker compose ... green up -d` sans toucher blue.
  3) Healthcheck green (frontend + backend).
  4) Basculer le proxy vers green.
- Rollback:
  - Rebasculer le proxy vers blue en 1 commande.

## 5) CI/CD (blue-green-deploy)
- Le job lit la couleur active (fichier `active_color.env`).
- Il choisit la couleur inactive (blue ou green).
- Il deploie la couleur inactive, teste, puis bascule Nginx.
- Condition d'execution: uniquement sur la branche cible (ex: develop).

## 6) README
- Ajouter section "Blue/Green" avec:
  - roles blue/green
  - proxy routing
  - workflow de deploiement
  - rollback instantane
  - condition de branche
