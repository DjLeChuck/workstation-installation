# UmanIT Full PHP

Installe toutes les versions de PHP et leurs extensions.

## Requirements

Il est nécessaire d'installer la clef GPG permettant de signer le dépôt.
Pour se faire, il faut utiliser le rôle [umanit.gpg](https://holygit.umanit.fr/umaninfra/ansible-subgroup/roles/umanit.gpg).

Un exemple est visible dans la partie [Example Playbook](#example-playbook).

## Role Variables

Liste des versions de PHP à installer

	full_php_versions

Liste des extensions de PHP à installer

	full_php_extensions

Produit cartésien des variables `full_php_versions` et `full_php_extensions`

	full_php_versions_extensions_product

Liste des extensions PHP inexistantes (permet d'exclure des valeurs de `full_php_versions_extensions_product`)

	full_php_unexisting_extensions

## Dependencies

- [umanit.gpg](https://holygit.umanit.fr/umaninfra/ansible-subgroup/roles/umanit.gpg)

## Example Playbook

```yaml
  - hosts: servers
    roles:
      - role: umanit.gpg
        gpg_key_content: |-
          -----BEGIN PGP PUBLIC KEY BLOCK-----

          mI0ESX35nAEEALKDCUDVXvmW9n+T/+3G1DnTpoWh9/1xNaz/RrUH6fQKhHr568F8
          hfnZP/2CGYVYkW9hxP9LVW9IDvzcmnhgIwK+ddeaPZqh3T/FM4OTA7Q78HSvR81m
          Jpf2iMLm/Zvh89ZsmP2sIgZuARiaHo8lxoTSLtmKXsM3FsJVlusyewHfABEBAAG0
          H0xhdW5jaHBhZCBQUEEgZm9yIE9uZMWZZWogU3Vyw72ItgQTAQIAIAUCSX35nAIb
          AwYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEE9OoKrlJnpsQjYD/jW1NlIFAlT6
          EvF2xfVbkhERii9MapjaUsSso4XLCEmZdEGX54GQ01svXnrivwnd/kmhKvyxCqiN
          LDY/dOaK8MK//bDI6mqdKmG8XbP2vsdsxhifNC+GH/OwaDPvn1TyYB653kwyruCG
          FjEnCreZTcRUu2oBQyolORDl+BmF4DjL
          =R5tk
          -----END PGP PUBLIC KEY BLOCK-----
        gpg_key_name: php.gpg
      - role: umanit.full_php
```

## License

MIT

## Author Information

Rôle créé par [UmanIT](https://www.umanit.fr/)
