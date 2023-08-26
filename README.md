# Workstation Installation

## Introduction

Ce dépôt permet de réaliser l'installation d'un poste de travail de développeur
(back / front, peu importe) qui tourne sous un système Ubuntu.

Voici la liste des outils qui vont être installés :

| Outil           | Description                                                 |
|-----------------|-------------------------------------------------------------|
| atom            | Éditeur de texte                                            |
| bash-git-prompt | Prompt bash qui affiche des informations sur les dépôts Git |
| composer        | Gestionnaire de dépendances PHP                             |
| docker          | Logiciel de conteneurisation                                |
| golang          | Langage de programmation                                    |
| google-chrome   | Navigateur web                                              |
| jetbrains       | IDE PhpStorm et GoLand                                      |
| mattermost      | Logiciel de messagerie instantanée                          |
| php             | Langage de programmation 5.6 à 8.1 (avec les extensions)    |
| postman         | Logiciel pour tester les API REST                           |
| rustdesk        | Logiciel de prise de main à distance                        |
| seadrive        | Client pour SeaFile                                         |
| spotify         | Lecteur de musique en streaming                             |
| symfony-cli     | Binaire Symfony CLI                                         |
| toggl-track     | Tracker de temps                                            |
| volta           | Gestionnaire de versions de Node.js                         |

## Utilisation

Pour installer Ansible et le laisser faire son travail, il suffit de lancer le
script `install.sh` dans un terminal :

```bash
bash install.sh
```

Il va alors procéder à l'installation d'Ansible, puis va exécuter le playbook.
Votre mot de passe vous sera demandé deux fois (une fois pour l'installation
d'Ansible, puis une fois pour son exécution).

Une fois l'installation terminée, un reboot de la machine devra être effectué.
