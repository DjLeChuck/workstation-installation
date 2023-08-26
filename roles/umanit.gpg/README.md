
# UmanIT GPG

Installation d'une clef GPG dans le dossier `/usr/share/keyrings` afin de
pouvoir signer un dépôt APT par la suite.

## Requirements

Auncun.

## Role Variables

Il n'y a aucune valeur par défaut sur les variables, il faut donc
**obligatoirement** fournir `gpg_key_name` et `gpg_key_url` ou
`gpg_key_content` (mais pas les deux).

Nom de la clef GPG à créer dans `/usr/share/keyrings`

	gpg_key_name: docker.gpg

URL de la clef GPG à créer

	gpg_key_url: https://download.docker.com/linux/ubuntu/gpg

Contenu de la clef GPG à créer (alternative à l'utilisation de `gpg_key_url`)

	gpg_key_content: |-
		-----BEGIN PGP PUBLIC KEY BLOCK-----
		[...]
		-----END PGP PUBLIC KEY BLOCK-----

## Dependencies

Aucune.

## Example Playbook

Ce rôle s'utilise exclusivement via un `include_role` dans une autre tâche.

L'exemple ci-dessous va télécharger la clef GPG de Docker et l'enregistrer dans
`/usr/share/keyrings/docker.gpg`.
Il ne restera plus qu'à utiliser ce chemin dans l'ajout de votre dépôt (par
exemple : `deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable`)

```yaml
  - hosts: servers
    tasks:
      - name: Ajout de la clef
        include_role:
          name: umanit.gpg
        vars:
          gpg_key_url: https://download.docker.com/linux/ubuntu/gpg
          gpg_key_name: docker.gpg
```

## License

MIT

## Author Information

Rôle créé par [UmanIT](https://www.umanit.fr/)
