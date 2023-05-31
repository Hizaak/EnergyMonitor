# EnergyMonitor
Visualiser l'évolution en temps réel de la consommation énergétique de processus spécifiques.

# Dépendances
Un ordinateur sous Linux (pour le script d'analyse des PID) \
docker : https://docs.docker.com/engine/install/ubuntu/ (Ubuntu) ou https://docs.docker.com/desktop/install/archlinux/ (Arch-based distributions) \
docker-compose (si jamais la dépendance n'est pas inclue dans docker, en fonction de l'installation)

# Lancement du projet
- Placez vous à la racine du projet et exécutez ``./dockerenv/exec.sh``. Cela mettra en place l'environnement (pull des images > lancement des images)
- Lancez les mesures avec la commande ``./Metrics/metrics.sh``

## Réinitialiser le projet
- Placez vous à la racine du projet et exécutez ``./dockerenv/exec.sh wal``. Le paramètre "wal" permet de supprimer la base de données InfluxDB.

## Accéder au CLI
Vous pouvez accéder aux CLI en exécutant la commande ``docker exec -it < grafana | influxdb > /bin/sh`` mais le CLI en InfluxQL sera accessible avec la commande ``docker exec -it influxdb influx``.

# Visualisation
La visualisation est accessible à l'adresse [localhost:3000](localhost:3000).
