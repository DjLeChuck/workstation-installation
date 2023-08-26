SHELL := /bin/bash

init_roles:
	@make update_umanit_roles

update_umanit_roles:
	@echo "Mise à jour des rôles..."
	@ansible-galaxy install -r requirements.yml -p roles -f > /dev/null
