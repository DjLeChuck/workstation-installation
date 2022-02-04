#!/bin/bash

set -e

# Liste des logiciels proposés à l'installation
CHOICES=(
  "atom" "Éditeur de texte" OFF
  "bash-git-prompt" "Prompt informatif pour git" OFF
  "blackfire" "Outils de profiling" OFF
  "chrome" "Navigateur web" OFF
  "clamav" "Antivirus avec GUI" OFF
  "docker" "Logiciel de conteneurisation" OFF
  "golang" "Langage de programmation" OFF
  "mattermost" "Logiciel de messagerie instantanée" OFF
  "php" "Langage de programmation 5.6 à 8.1 (avec les extensions)" OFF
  "phpstorm" "IDE spécialisé pour PHP, HTML, CSS et JavaScript" OFF
  "postman" "Outil pour tester les API REST" OFF
  "seadrive" "Client pour SeaFile" OFF
  "spotify" "Lecteur de musique en straming" OFF
  "steam" "Plateforme de jeux-vidéos" OFF
  "symfony" "Binaire Symfony CLI" OFF
  "tools" "Outils divers (vim, terminator)" OFF
  "toggl" "Tracker de temps" OFF
  "volta" "Gestionnaire de version de node" OFF
)

TITLE="Workstation Installer v0.1"
NC='\033[0m'
CYAN='\033[00;36m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
RED='\033[00;31m'

# Vérification préalable de la présence de flatpak qui doit être installé manuellement
if ! command -v flatpak &> /dev/null
then
    echo -e "${RED}flatpak est requis pour que le script fonctionne.\n\n${YELLOW}Veuillez suivre les instructions d'installation propres à votre distribution sur le site officiel :${CYAN} https://flatpak.org/setup/${NC}"
    exit
fi

# Empêche le lancement sans utiliser sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Merci de lancer le script avec sudo !${NC}"
  exit
fi

USER=${SUDO_USER:-$(whoami)}
USER_HOME=`eval echo ~$USER`

# Empêche le lancement en tant que root directement
if [ "root" == $"USER" ]; then
  echo -e "${RED}Merci de ne pas lancer le script en tant qu'utilisateur root !${NC}"
  exit
fi

echo -e "${YELLOW}Ce script va commencer par mettre à jour les dépendances du système et installer certains pré-requis.\n\nAprès cela vous pourrez sélectionner les différents logiciels que vous souhaitez installer.\n${NC}"
read -p "$(echo -e $CYAN"Appuyez sur Entrée pour continuer..."$NC)"

echo -e "${CYAN}\nMise à jour des dépendances et installation des paquets requis...${NC}"
apt update -qq
apt upgrade -yqq
apt install -yqq ca-certificates curl git gnupg gzip libnss3-tools wget

SOFTWARES=$(whiptail --title "$TITLE" --checklist "Liste des logiciels à installer" 26 86 $((${#CHOICES[@]} / 3)) "${CHOICES[@]}" 3>&1 1>&2 2>&3)

# Quitte si aucun logiciel n'a été sélectionné
if [ -z "$SOFTWARES" ]; then
  echo -e "${RED}Aucun logiciel sélectionné.${NC}"
  exit
fi

declare -A FLATPAK_SOFTWARES=(
  ['"atom"']="io.atom.Atom"
  ['"mattermost"']="com.mattermost.Desktop"
  ['"phpstorm"']="com.jetbrains.PhpStorm"
  ['"postman"']="com.getpostman.Postman"
  ['"steam"']="com.valvesoftware.Steam"
  ['"spotify"']="com.spotify.Client"
  ['"toggl"']="com.toggl.TogglDesktop"
)

# Intersection des logiciels sélectionnés avec ceux disponibles via flatpak
FLATPAK_TO_INSTALL=$(echo ${SOFTWARES[@]} ${!FLATPAK_SOFTWARES[@]} | sed 's/ /\n/g' | sort | uniq -d)

# Installation des paquets flatpak
FLATPAK_INSTALL_STR=""
for i in ${FLATPAK_TO_INSTALL}; do
  SOFTWARES=("${SOFTWARES[@]/$i}") # Retrait du logiciel de la liste

  FLATPAK_INSTALL_STR="${FLATPAK_INSTALL_STR} ${FLATPAK_SOFTWARES[$i]}"
done

if [ "" != "$FLATPAK_INSTALL_STR" ]; then
  echo -e "${CYAN}\nInstallation des paquets via flatpak...${NC}"
  sudo -i -u $USER flatpak install flathub --noninteractive -y --or-update $FLATPAK_INSTALL_STR
fi

ALERT_DOCKER_POSTINSTALL=0
APT_INSTALL_STR=""
for SOFTWARE in $SOFTWARES; do
  case $SOFTWARE in
    '"blackfire"')
      wget -q -O - https://packages.blackfire.io/gpg.key | apt-key add - > /dev/null 2>&1
      echo "deb http://packages.blackfire.io/debian any main" > /etc/apt/sources.list.d/blackfire.list

      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} blackfire"
      ;;
    '"chrome"')
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - > /dev/null 2>&1
      echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} google-chrome-stable"
      ;;
    '"clamav"')
      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} clamtk clamtk-gnome"
      ;;
    '"docker"')
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" > /etc/apt/sources.list.d/docker.list

      ALERT_DOCKER_POSTINSTALL=1
      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} docker-ce docker-ce-cli docker-compose"
      ;;
    '"golang"')
      add-apt-repository -y ppa:longsleep/golang-backports > /dev/null 2>&1

      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} golang"
      ;;
    '"php"')
      add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1

      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} \
      php5.6-amqp php5.6-bcmath php5.6-cli php5.6-common php5.6-curl \
      php5.6-fpm php5.6-gd php5.6-imagick php5.6-imap php5.6-intl php5.6-json \
      php5.6-ldap php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-opcache \
      php5.6-pgsql php5.6-readline php5.6-soap php5.6-sqlite3 php5.6-xdebug \
      php5.6-xml php5.6-xsl php5.6-zip \
      php7.0-amqp php7.0-bcmath php7.0-cli php7.0-common php7.0-curl \
      php7.0-fpm php7.0-gd php7.0-imagick php7.0-imap php7.0-intl php7.0-json \
      php7.0-ldap php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache \
      php7.0-pgsql php7.0-readline php7.0-soap php7.0-sqlite3 php7.0-xdebug \
      php7.0-xml php7.0-xsl php7.0-zip \
      php7.1-amqp php7.1-bcmath php7.1-cli php7.1-common php7.1-curl \
      php7.1-fpm php7.1-gd php7.1-imagick php7.1-imap php7.1-intl php7.1-json \
      php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-opcache \
      php7.1-pgsql php7.1-readline php7.1-soap php7.1-sqlite3 php7.1-xdebug \
      php7.1-xml php7.1-xsl php7.1-zip \
      php7.2-amqp php7.2-bcmath php7.2-cli php7.2-common php7.2-curl \
      php7.2-fpm php7.2-gd php7.2-imagick php7.2-imap php7.2-intl php7.2-json \
      php7.2-ldap php7.2-mbstring php7.2-mcrypt php7.2-mysql php7.2-opcache \
      php7.2-pgsql php7.2-readline php7.2-soap php7.2-sqlite3 php7.2-xdebug \
      php7.2-xml php7.2-xsl php7.2-zip \
      php7.3-amqp php7.3-bcmath php7.3-cli php7.3-common php7.3-curl \
      php7.3-fpm php7.3-gd php7.3-imagick php7.3-imap php7.3-intl php7.3-json \
      php7.3-ldap php7.3-mbstring php7.3-mcrypt php7.3-mysql php7.3-opcache \
      php7.3-pgsql php7.3-readline php7.3-soap php7.3-sqlite3 php7.3-xdebug \
      php7.3-xml php7.3-xsl php7.3-zip \
      php7.4-amqp php7.4-bcmath php7.4-cli php7.4-common php7.4-curl \
      php7.4-fpm php7.4-gd php7.4-imagick php7.4-imap php7.4-intl php7.4-json \
      php7.4-ldap php7.4-mbstring php7.4-mcrypt php7.4-mysql php7.4-opcache \
      php7.4-pgsql php7.4-readline php7.4-soap php7.4-sqlite3 php7.4-xdebug \
      php7.4-xml php7.4-xsl php7.4-zip \
      php8.0-amqp php8.0-bcmath php8.0-cli php8.0-common php8.0-curl \
      php8.0-fpm php8.0-gd php8.0-imagick php8.0-imap php8.0-intl php8.0-ldap \
      php8.0-mbstring php8.0-mcrypt php8.0-mysql php8.0-opcache php8.0-pgsql \
      php8.0-readline php8.0-soap php8.0-sqlite3 php8.0-xdebug php8.0-xml \
      php8.0-xsl php8.0-zip \
      php8.1-amqp php8.1-bcmath php8.1-cli php8.1-common php8.1-curl \
      php8.1-fpm php8.1-gd php8.1-imagick php8.1-imap php8.1-intl php8.1-ldap \
      php8.1-mbstring php8.1-mcrypt php8.1-mysql php8.1-opcache php8.1-pgsql \
      php8.1-readline php8.1-soap php8.1-sqlite3 php8.1-xdebug php8.1-xml \
      php8.1-xsl php8.1-zip"
      ;;
    '"seadrive"')
      wget -q https://linux-clients.seafile.com/seafile.asc -O /usr/share/keyrings/seafile-keyring.asc
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/seafile-keyring.asc] https://linux-clients.seafile.com/seadrive-deb/focal/ stable main" > /etc/apt/sources.list.d/seadrive.list

      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} seadrive-gui"
      ;;
    '"tools"')
      SOFTWARES=("${SOFTWARES[@]/$SOFTWARE}") # Retrait du logiciel de la liste
      APT_INSTALL_STR="${APT_INSTALL_STR} terminator vim"
      ;;
  esac
done

# Installation des paquets apt
if [ "" != "$APT_INSTALL_STR" ]; then
  echo -e "${CYAN}\nInstallation des paquets via apt...${NC}"
  apt update -qqq
  apt install -yqqq $APT_INSTALL_STR
fi

# Post-installation de docker
if [ "$ALERT_DOCKER_POSTINSTALL" -eq 1 ]; then
  usermod -aG docker $USER
  systemctl enable docker.service
fi

# Installation des cas particuliers restants
echo -e "${CYAN}\nInstallation des logiciels restants...${NC}"
for SOFTWARE in $SOFTWARES; do
  case $SOFTWARE in
    '"bash-git-prompt"')
      su -c "git clone -q https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1" $USER
      cat <<EOT>> $USER_HOME/.bashrc

if [ -f ~/.bash-git-prompt/gitprompt.sh ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Solarized
    GIT_PROMPT_FETCH_REMOTE_STATUS=0
    . ~/.bash-git-prompt/gitprompt.sh
fi
EOT
      ;;
    '"symfony"')
      su -c "wget -q https://get.symfony.com/cli/installer -O - | bash" $USER
      cat <<EOT>> $USER_HOME/.bashrc

export PATH="\$HOME/.symfony/bin:\$PATH"
EOT
      ;;
    '"volta"')
      su -c "curl -s https://get.volta.sh | bash" $USER
      ;;
  esac
done

echo -e "${GREEN}\n\nInstallation de la machine terminée ! Merci de la re-démarrer avant de continuer.${NC}"
