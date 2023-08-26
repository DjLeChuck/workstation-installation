#!/bin/bash

set -e

NC='\033[0m'
CYAN='\033[00;36m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
RED='\033[00;31m'

# Empêche le lancement via sudo
if [ "$EUID" == 0 ]; then
  echo -e "${RED}Merci de NE PAS lancer le script avec sudo !${NC}"
  exit
fi

# Empêche le lancement en tant que root directement
if [ "root" == "$USER" ]; then
  echo -e "${RED}Merci de ne pas lancer le script en tant qu'utilisateur root !${NC}"
  exit
fi

echo -e "${CYAN}\nMise à jour des dépendances et installation des paquets requis...${NC}"
DEBIAN_FRONTEND=noninteractive sudo apt-get update -qq < /dev/null > /dev/null
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -yqq < /dev/null > /dev/null
DEBIAN_FRONTEND=noninteractive sudo apt-get install -yqq python3 ansible < /dev/null > /dev/null

echo -e "${CYAN}\nLancement du playbook Ansible...${NC}"
echo -e "${YELLOW}Saisissez votre mot de passe lorsque le prompt vous affiche \"BECOME password: \"${NC}"
ansible-playbook -i 00_inventory.yml -K playbook.yml

echo -e "${GREEN}\nInstallation terminée !${NC} ${YELLOW}L'ordinateur va redémarrer lorsque vous appuierez sur Entrée.${NC}"
read -p "$(echo -e $CYAN"Appuyez sur Entrée pour continuer..."$NC)"
#sudo shutdown -r now
