# TP6 - Monitoring & Observabilite

## Objectif
Mettre en place une stack locale d'observabilite (Prometheus, Grafana, Loki, Promtail) pour collecter metriques et logs de l'application conteneurisee, puis les visualiser.

## Monitoring vs observabilite
- Monitoring : surveiller des signaux connus (alertes, seuils, etats).
- Observabilite : comprendre un systeme via ses sorties (logs, metriques, traces) sans tout predefinir.

## 3 piliers
- Metriques : mesures numeriques (latence, taux d'erreur, CPU, RAM).
- Logs : evenements horodates.
- Traces : suivi d'une requete a travers les services (non implemente ici).

## Role de chaque composant
- Prometheus : scrape et stocke les metriques exposees par les services.
- Grafana : visualise metriques et logs via dashboards.
- Loki : stocke les logs.
- Promtail : collecte les logs (stdout / Docker) et les envoie vers Loki.

## Architecture (schema simple)
```
                        +--------------------+
                        |    Grafana         |
                        |  Dashboards        |
                        +---------+----------+
                                  |
                     +------------+------------+
                     |                         |
             +-------v-------+         +-------v-------+
             |  Prometheus   |         |     Loki      |
             | (metrics)     |         | (logs)        |
             +-------+-------+         +-------+-------+
                     |                         ^
                     |                         |
                     v                         |
         +-----------+-----------+     +-------+-------+
         | Backend NestJS / API  |     |   Promtail    |
         | /metrics endpoint     |     | (log agent)   |
         +-----------------------+     +---------------+
```

## Integration avec l'application
- Backend expose un endpoint `/metrics` (via @willsoto/nestjs-prometheus ou equivalent).
- Prometheus scrape ce endpoint (ex. `backend-blue:3000` ou `backend-green:3000`).
- Promtail lit les logs Docker (stdout) du backend et les pousse vers Loki.
- Grafana interroge Prometheus (metriques) et Loki (logs).

## Ports utiles
- Grafana : http://localhost:3000
- Prometheus : http://localhost:9090
- Loki : http://localhost:3100 (interne)
- Promtail : pas d'UI (agent)

## Notes blue/green
- Une seule couleur est active pour l'endpoint de metriques.
- La cible Prometheus pointe vers la couleur active.
- Lors d'un switch, on met a jour la cible (ou on utilise un alias de service).
