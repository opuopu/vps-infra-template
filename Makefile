# ব্যবহার: make <কমান্ড>   (যেমন make setup)
VAULT_PASS := $(HOME)/.ansible/vault_pass.txt
APP ?= backend

.PHONY: help init ping bootstrap setup env encrypt edit-env view-env logs

help:
	@echo "make init       - একবার: vault password + env ফাইল + git hook"
	@echo "make bootstrap  - নতুন VPS এ একবার (root দিয়ে): deploy user, root login বন্ধ"
	@echo "make setup      - Docker, firewall, Traefik, SSL, env (যতবার খুশি)"
	@echo "make env        - শুধু env পাঠাও + অ্যাপ রিস্টার্ট"
	@echo "make edit-env APP=backend  - env এডিট (encrypted থেকেই)"
	@echo "make ping / make logs"

init:
	@mkdir -p $(HOME)/.ansible && chmod 700 $(HOME)/.ansible
	@[ -f $(VAULT_PASS) ] || (openssl rand -base64 32 > $(VAULT_PASS) && chmod 600 $(VAULT_PASS) && echo "✅ vault password তৈরি: $(VAULT_PASS)  (password manager এ ব্যাকআপ রাখো!)")
	@mkdir -p env certs && for f in env.example/*.env; do [ -f env/$$(basename $$f) ] || cp $$f env/; done
	@if [ -d .git ]; then ln -sf ../../scripts/check-env-encrypted.sh .git/hooks/pre-commit; fi
	@echo "✅ এখন env/*.env এ আসল মান বসাও, তারপর make encrypt"

encrypt:
	@for f in env/*.env certs/*.key; do [ -e $$f ] || continue; head -n1 $$f | grep -q '^\$$ANSIBLE_VAULT' || ansible-vault encrypt $$f; done
	@echo "✅ সব env আর key encrypted"

edit-env:
	ansible-vault edit env/$(APP).env

view-env:
	ansible-vault view env/$(APP).env

ping:
	ansible all -m ping

bootstrap:
	ansible-playbook bootstrap.yml -e ansible_user=root

setup:
	@./scripts/check-env-encrypted.sh
	ansible-playbook site.yml

env:
	@./scripts/check-env-encrypted.sh
	ansible-playbook site.yml --tags env

logs:
	ansible all -m command -a "docker logs traefik --tail 50"
