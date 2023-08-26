# UmanIT Volta

Permet d'installer [Volta](https://volta.sh/).

# Requirements

Aucun.

# Role Variables

Utilisateur pour lequel installer Volta (utilisateur en cours par défaut)

	volta_user

Home de l'utilisateur pour lequel installer Volta (home de l'utilisateur en
cours par défaut)

	volta_user_home: https://download.docker.com/linux/ubuntu/gpg


# Dependencies

Aucune.

## Example Playbook

```yaml
  - hosts: servers
    roles:
       - { role: umanit.volta }
```

## License

MIT

## Author Information

Rôle créé par [UmanIT](https://www.umanit.fr/)
