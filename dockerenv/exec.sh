#!/bin/bash

sudo chmod -R 777 ./volumes

# Récupérer les identifiants des containers à supprimer
container_ids=$(docker ps -a -q)

# Vérifier si des containers existent
if [ -n "$container_ids" ]; then
  # Stopper tous les containers
  docker stop $container_ids
  # Supprimer tous les containers
  docker rm $container_ids
fi

# Vérifier si un paramètre est fourni
if [ -n "$1" ]; then
  # Vérifier si le paramètre est égal à "wal"
  if [ "$1" = "wal" ]; then
    # Supprimer le répertoire "./influxdb_data/wal"
    sudo rm -rf ./volumes/influxdb_data/wal
    echo "Répertoire './volumes/influxdb_data/wal' supprimé."
  fi
fi

# Exécuter docker-compose up en arrière-plan
docker-compose up -d

sudo chmod -R 777 ./volumes

# Vérifier le code de sortie de docker-compose up
if [ $? -eq 0 ]; then
  echo "FAIT !"
fi
