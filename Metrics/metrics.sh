# #!/bin/bash

# cleanup() {
#     # Arrêter proprement le processus metrics
#     # kill "$metrics_pid"
#     exit 0
# }

INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
DATABASE="influx"
MEASUREMENT="influx"

# declare -a listePIDSurveilles=()
# declare -i index 


# # TODO : faire une fonction getMetrics qui prend en paramètre le PID et qui insère les données dans influxdb
# # 
# # Structure :
# #   Timestamp (géré par influxdb)
# #   Nom du processus
# #   Processus parent [optionnel]
# #   N° de PID
# #   CPU
# #   RAM
# #   NIC
# #   SD
# # 
# #   Sur une autre base de données (MySQL ?):
# #   Utilisateur
# #   Informations concernant la machine (à voir...)

# # Fonction de monitoring
# function getMetrics() {
#     # Récupérer les informations du processus
#     nom=$(ps -p $pid -o comm=)
#     # parent=$(ps -o comm= -p $(ps -o ppid= -p $pid))
#     cpu=$(ps -p $pid -o %cpu=)
#     ram=$(ps -p $pid -o %mem=)
#     nic=$(ps -p $pid -o nice=)
#     sd=$(ps -p $pid -o start=)
    
#     # Insérer les données dans influxdb
#     curl -i -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$DATABASE" --data-binary "$MEASUREMENT,process=$nom,parent=$parent,pid=$pid cpu=$cpu,ram=$ram,nic=$nic,sd=$sd"
# }


# # Fonctions outils
# function afficherListeSurveillance(){
#     # Vérifier si la liste n'est pas vide
#     if [ ${#listePIDSurveilles[@]} -eq 0 ]; then
#         echo "Aucun processus surveillé."
#         echo
#         return
#     else
#         # Afficher la liste des processus surveillés
#         echo "Liste des processus surveillés :"
#         printf "%-4s %-8s %-16s %-16s\n" "N°" "PID" "Nom" "Parent"
#         printf "%-4s %-8s %-16s %-16s\n" "---" "--------" "----------------" "----------------"

#         i=1
#         for pid in "${listePIDSurveilles[@]}"; do
#             nom_processus=$(ps -p $pid -o comm=)
#             parent=$(ps -p $pid -o ppid=)
#             printf "%-4s %-8s %-16s %-16s\n" "$i" "$pid" "$nom_processus" "$parent"
#             ((i++))
#         done

#         echo
#     fi
# }


# # Ajouts de PID
# function ajouterPIDlisteSurveillance() {
#     pid=$1
#     nomPid=$(ps -p $pid -o comm=)

#     # Vérifier si le processus a une commande et un nom
#     if [ -n "$nomPid" ]; then
#         # Vérifier si le PID ne fait pas déjà partie de la liste des processus surveillés. La liste peut être vide, donc il ne faut pas parcourir la liste
#         if [ ${#listePIDSurveilles[@]} -eq 0 ]; then
#             listePIDSurveilles+=("$pid")
#             echo "Processus $nomPid ($pid) ajouté à la liste des processus surveillés."
#         else
#             for pidSurveille in "${listePIDSurveilles[@]}"; do
#                 if [ $pidSurveille -eq $pid ]; then
#                     echo "Processus $nomPid ($pid) déjà surveillé."
#                     break
#                 else
#                     listePIDSurveilles+=("$pid")
#                     echo "Processus $nomPid ($pid) ajouté à la liste des processus surveillés."
#                     break
#                 fi
#             done
#         fi

#         # Fonction récursive pour ajouter les enfants des enfants
#         ajouterEnfantsSurveillance() {
#             local parent_pid=$1

#             # Parcourir les processus enfants
#             enfants=$(pgrep -P $parent_pid)
#             for enfant in $enfants; do
#                 # Vérifier si le processus a bien un nom, sinon on ne l'ajoute pas
#                 nomEnfant=$(ps -p $enfant -o comm=)
#                 if [ -z "$nomEnfant" ]; then
#                     echo "Processus avec PID $enfant n'a pas de commande ni de nom et ne sera pas ajouté à la liste."

#                 # Vérifier si le processus n'est pas déjà surveillé
#                 elif [[ ! " ${listePIDSurveilles[@]} " =~ $enfant ]]; then
#                     nomEnfant=$(ps -p $enfant -o comm=)
#                     if [ -n "$nomEnfant" ]; then
#                         listePIDSurveilles+=("$enfant")
#                         echo "Processus $nomEnfant ($enfant) ajouté à la liste des processus surveillés."
#                         ajouterEnfantsSurveillance "$enfant"  # Appel récursif pour ajouter les enfants des enfants
#                     fi
#                 else
#                     echo "Processus $nomEnfant ($enfant) déjà surveillé."
#                 fi
#             done
#         }

#         # Demander si l'utilisateur veut surveiller les processus enfants
#         read -r -p "Voulez-vous surveiller les processus enfants ? [O/n] " response
#         if [[ $response =~ ^([oO])$ ]]; then
#             ajouterEnfantsSurveillance "$pid"
#         fi
#     else
#         echo "Processus avec PID $pid n'a pas de commande ni de nom et ne sera pas ajouté à la liste."
#     fi
#     echo
# }



# function listerPIDpourAjouter() {
#     # Proposer à l'utilisateur de saisir un nom de processus
#     read -r -p "Nom du processus à surveiller : " nom
    
#     # Récupérer la liste des PID
#     pids=$(pgrep "$nom")
    
#     # Afficher la liste des PID et le nom du processus à côté
#     echo "Processus $nom :"
#     printf "%-4s %-8s %-16s %-16s\n" "N°" "PID" "Nom" "Parent"
#     printf "%-4s %-8s %-16s %-16s\n" "---" "--------" "----------------" "----------------"
#     # Récupérer la variable index
#     index=1
#     pid_array=()
#     for pid in $pids; do
#         nom_processus=$(ps -p $pid -o comm=)
#         if [ -n "$nom_processus" ]; then
#             if [ $pid -eq 1 ] && [ "$nom_processus" = "systemd" ]; then
#                 printf "%-4s %-8s %-16s\n" "$index" "$pid" "$nom_processus"
#             else
#                 parent=$(ps -o comm= -p $(ps -o ppid= -p $pid))
#                 if [ -n "$parent" ]; then
#                     printf "%-4s %-8s %-16s %-16s\n" "$index" "$pid" "$nom_processus" "$parent"
#                 fi
#             fi
#             pid_array+=("$pid")
#             index=$((index+1))
#             listerEnfants "$pid"
#         fi
#     done
    
#     # Demander à l'utilisateur de sélectionner un PID
#     read -r -p "Sélectionnez un N° : " selected_number
    
#     # Vérifier si le numéro de PID sélectionné est valide
#     if [[ $selected_number =~ ^[0-9]+$ && $selected_number -ge 1 && $selected_number -le ${#pid_array[@]} ]]; then
#         # Récupérer le PID correspondant au numéro sélectionné
#         selected_pid=${pid_array[$((selected_number-1))]}
#         echo "PID sélectionné : $selected_pid"
#         ajouterPIDlisteSurveillance "$selected_pid"
#     else
#         echo "Numéro de PID invalide."
#     fi
# }


# function listerEnfants(){
#     local parent_pid=$1
    
#     enfants=$(pgrep -P $parent_pid)
#     for enfant in $enfants; do
#         nom_parent=$(ps -o comm= -p $(ps -o ppid= -p $enfant))
#         nom_enfant=$(ps -p $enfant -o comm=)
#         if [ -n "$nom_enfant" ]; then
#             printf "%-4s %-8s %-16s %-16s\n" "$index" "$enfant" "$nom_enfant" "$nom_parent"
#             pid_array+=("$enfant")
#             index=$((index+1))
#             listerEnfants "$enfant" "$index"
#         fi

#     done
# }



# function ajouterPIDparNom(){
#     # Proposer à l'utilisateur de saisir un nom de processus
#     read -r -p "Nom du processus à surveiller : " nom
#     # Récupérer la liste des PID
#     pids=$(pgrep "$nom")
    
#     # Surveiller chacun des processus retournés
#     for pid in $pids
#     do
#         ajouterPIDlisteSurveillance "$pid"
#     done
# }


# function ajouterPIDparPID(){
#     # Proposer à l'utilisateur de saisir un nom de processus
#     read -r -p "PID du processus à surveiller : " pid
#     # Récupérer la liste des PID
#     ajouterPIDlisteSurveillance "$pid"
# }

# # Suppression de PID
# function listerPIDpourSupprimer(){
#     # Vérifier si la liste est vide
#     if [ ${#listePIDSurveilles[@]} -eq 0 ]; then
#         echo "Aucun processus surveillé."
#         echo
#         menuPrincipal
#         return
#     fi

#     # Afficher la liste des PID et le nom du processus à côté
#     echo "Processus surveillés :"
#     printf "%-4s %-8s %-16s %-16s\n" "N°" "PID" "Nom" "Parent"
#     printf "%-4s %-8s %-16s %-16s\n" "---" "--------" "----------------" "----------------"
    
#     i=1
#     pid_array=()
#     for pid in "${listePIDSurveilles[@]}"; do
#         nom_processus=$(ps -p $pid -o comm=)
#         parent=$(ps -o comm= -p $(ps -o ppid= -p $pid))
#         printf "%-4s %-8s %-16s %-16s\n" "$i" "$pid" "$nom_processus" "$parent"
#         pid_array+=("$pid")
#         ((i++))

#     done



    
#     # Demander à l'utilisateur de sélectionner un PID
#     read -r -p "Sélectionnez un N° : " selected_number
    
#     # Vérifier si le numéro de PID sélectionné est valide
#     if [[ $selected_number =~ ^[0-9]+$ && $selected_number -ge 1 && $selected_number -le ${#pid_array[@]} ]]; then
#         # Récupérer le PID correspondant au numéro sélectionné
#         selected_pid=${pid_array[$((selected_number-1))]}
#         echo "PID sélectionné : $selected_pid"
#         supprimerPIDlisteSurveillance "$selected_pid"
#     else
#         echo "Numéro de PID invalide."
#     fi
# }

# function supprimerPIDlisteSurveillance(){
#     pid=$1
#     nomPid=$(ps -p $pid -o comm=)
#     # Vérifier si le PID ne fait pas déjà partie de la liste des processus surveillés. La liste peut être vide, donc il ne faut pas parcourir la liste
#     if [ ${#listePIDSurveilles[@]} -eq 0 ]; then
#         listePIDSurveilles+=("$pid")
#         clear
#         echo "La liste de surveillance est déjà vide !"
#         echo
#     else
#         index=-1
#         for i in "${!listePIDSurveilles[@]}"; do
#             if [ ${listePIDSurveilles[$i]} -eq $pid ]; then
#                 index=$i
#                 break
#             fi
#         done
#         if [ $index -ne -1 ]; then
#             unset 'listePIDSurveilles[index]'
#             echo "Le processus $nomPid ($pid) n'est plus surveillé."
#         else
#             echo "Le processus parent ($pid) n'était pas surveillé."
#         fi
#         # Demander si l'utilisateur veut arrêter de surveiller les processus enfants
#         read -r -p "Voulez-vous arrêter de surveiller les processus enfants ? [O/n] " response
#         if [[ $response =~ ^([oO])$ ]]; then
#             # Parcourir les processus enfants
#             enfants=$(pgrep -P $pid)
#             for enfant in $enfants; do
#                 # Vérifier si le processus n'est pas déjà surveillé
#                 if [[ ! " ${listePIDSurveilles[@]} " =~ $enfant ]]; then
#                     nomEnfant=$(ps -p $enfant -o comm=)
#                     listePIDSurveilles+=("$enfant")
#                     echo "Le processus $nomEnfant ($enfant) n'était pas surveillé."
#                 else
#                     index=-1
#                     for i in "${!listePIDSurveilles[@]}"; do
#                         if [ ${listePIDSurveilles[$i]} -eq $enfant ]; then
#                             index=$i
#                             break
#                         fi
#                     done
#                     if [ $index -ne -1 ]; then
#                         unset 'listePIDSurveilles[index]'
#                         echo "Le processus $nomEnfant ($enfant) n'est plus surveillé."
#                     fi
#                 fi
#                 # Supprimer les enfants des enfants récursivement
#                 supprimerPIDlisteSurveillance "$enfant"
#             done
#         fi
#         echo
#     fi
# }

# function supprimerPIDparNom(){
#     # Proposer à l'utilisateur de saisir un nom de processus
#     echo "R - Retour"
#     read -r -p "Nom du processus à arrêter de surveiller : " nom

#     if [[ $nom =~ ^[rR]$ ]]; then
#         clear
#         menuSupprimer
#     else
#         # Récupérer la liste des PID
#         pids=$(pgrep "$nom")
        
#         # Surveiller chacun des processus retournés
#         for pid in $pids
#         do
#             supprimerPIDlisteSurveillance "$pid"
#         done
#     fi

# }

# function supprimerPIDparPID(){
#     # Proposer à l'utilisateur de saisir un nom de processus
#     echo "R - Retour"
#     read -r -p "PID du processus à arrêter de surveiller : " pid
#     if [[ $pid =~ ^[0-9]+$ ]]; then
#         # Récupérer la liste des PID
#         supprimerPIDlisteSurveillance "$pid"
#     elif [[ $pid =~ ^[rR]$ ]]; then
#         clear
#         menuSupprimer
#     else
#         echo "Numéro de PID invalide."
#     fi
# }


# # Affichage de menus
# function menuPrincipal(){
#     while true; do
#         echo "Bienvenue dans le script de surveillance de processus !"
        
#         PS3="Choisissez une action : "
        
#         items=("AJOUTER un PID à la liste"
#             "RETIRER un PID de la liste"
#             "AFFICHER la liste des PID surveillés"
#             "$(tput setaf 1)QUITTER$(tput sgr0)")
        
#         select _ in "${items[@]}"
#         do
#             case $REPLY in
#                 1) clear && menuSurveiller;;
#                 2) clear && menuSupprimer;;
#                 3) clear && afficherListeSurveillance;;
#                 4) echo "Au revoir !" && exit;;
#                 *) clear && echo "Oups - choix inconnu $REPLY" && menuPrincipal;;
#             esac
#             break
#         done
#     done
# }

# function menuSurveiller(){
#     PS3="Choisissez une action : "
    
#     items=("Rechercher des processus (par nom)"
#            "Choisir un processus par nom"
#            "Choisir un processus par PID"
#            "$(tput setaf 3)RETOUR$(tput sgr0)"
#            "$(tput setaf 1)QUITTER$(tput sgr0)")
    
#     select _ in "${items[@]}"
#     do
#         case $REPLY in
#             1) clear && listerPIDpourAjouter;;
#             2) clear && ajouterPIDparNom;;
#             3) clear && ajouterPIDparPID;;
#             4) clear && menuPrincipal;;
#             5) echo "Au revoir !" && exit;;
#             *) clear && echo "Oups - choix inconnu $REPLY" && menuSurveiller;;
#         esac
#         break
#     done
# }

# function menuSupprimer(){
#     PS3="Choisissez une action dans : "
    
#     items=("Lister les processus surveillés"
#            "Retirer un processus par nom"
#            "Retirer un processus par PID"
#            "$(tput setaf 3)RETOUR$(tput sgr0)"
#            "$(tput setaf 1)QUITTER$(tput sgr0)")
    
#     select _ in "${items[@]}"
#     do
#         case $REPLY in
#             1) clear && listerPIDpourSupprimer;;
#             2) clear && supprimerPIDparNom;;
#             3) clear && supprimerPIDparPID;;
#             4) clear && menuPrincipal;;
#             5) echo "Au revoir !" && exit;;
#             *) clear && echo "Oups - choix inconnu $REPLY" && menuSupprimer;;
#         esac
#         break
#     done
# }


# # Main
# function main(){
#     # getMetrics &
#     # metrics_pid=$!
#     clear
#     menuPrincipal
# }

# main


# pstree -p -A 1 | grep -oP '\(\K\d+\)' | tr -d ')' | tr '\n' ' '


# # Structure :
# #   Timestamp (géré par influxdb)
# #   Nom du processus
# #   Processus parent [optionnel]
# #   N° de PID
# #   CPU
# #   RAM
# #   NIC
# #   SD
# # 
# #   Sur une autre base de données (MySQL ?):
# #   Utilisateur
# #   Informations concernant la machine (à voir...)

# Ce programme sert à insérer les données dans influxdb
while true; do
    start=$(date +%s%N)
#     listePID=$(pstree -p -A 1 | grep -oP '\(\K\d+\)' | tr -d ')' | tr '\n' ' ')
    listePID=$(pgrep -d ' ' .)
    for PID in $listePID; do
       if [ -n "$(ps -p $PID -o comm=)" ]; then
            NAME=$(ps -p $PID -o comm= --no-headers)

            USER=$(ps -p $PID -o user=)

            if [ $PID -eq 1 ] || [ $PID -eq 2 ]; then
                PARENT="aucun"
            else

                PARENT=$(ps -o comm= -p $(ps -o ppid= -p $PID))
            fi

            CPU=$(shuf -i 0-100 -n 1)
            RAM=$(shuf -i 40-300 -n 1)
            SD=$(shuf -i 30-200 -n 1)
            NIC=$(shuf -i 0-10 -n 1)

            QUERY="curl -s -XPOST 'http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$DATABASE' --data-binary '$MEASUREMENT user=\"$USER\",name=\"$NAME\",parent=\"$PARENT\",PID=$PID,CPU=$CPU,RAM=$RAM,SD=$SD,NIC=$NIC'"

            eval $QUERY
        fi
    done
    echo "--------------------------------------------------"
    end=$(date +%s%N)
    echo "Temps d'exécution : $(echo "scale=3; ($end - $start) / 1000000000" | bc) secondes"
    sleep 1
done
