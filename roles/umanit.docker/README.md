# UmanIT Docker

Permet d'installer Docker.

## Requirements

Il est nécessaire d'installer la clef GPG permettant de signer le dépôt.
Pour se faire, il faut utiliser le rôle [umanit.gpg](https://holygit.umanit.fr/umaninfra/ansible-subgroup/roles/umanit.gpg).

Un exemple est visible dans la partie [Example Playbook](#example-playbook).

## Role Variables

Aucune.

## Dependencies

- [umanit.gpg](https://holygit.umanit.fr/umaninfra/ansible-subgroup/roles/umanit.gpg)

## Example Playbook

```yaml
  - hosts: servers
    roles:
      - role: umanit.gpg
        gpg_key_url: https://download.docker.com/linux/ubuntu/gpg
        gpg_key_name: docker.gpg
      - role: umanit.docker
```

## License

MIT

## Author Information

Rôle créé par [UmanIT](https://www.umanit.fr/)
