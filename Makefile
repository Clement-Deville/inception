WORKDIR=./srcs/

build:
	docker compose --project-directory $(WORKDIR) build
upd:
	docker compose --project-directory $(WORKDIR) up -d

up:
	docker compose --project-directory $(WORKDIR) up

stop:
	docker compose --project-directory $(WORKDIR) stop

down:
	docker compose --project-directory $(WORKDIR) down

re: down build up

refresh: build up

ps:
	docker compose --project-directory $(WORKDIR) ps

## GENERATING SECRETS

secrets:
	./srcs/scripts/generate_secrets.sh

## FOR CLEANING SECRETS

clean_sec:
	rm ./secrets/*

.PHONY: secrets
