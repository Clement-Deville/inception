WORKDIR=./srcs/

all: build up

build:
	docker compose --env-file .env --project-directory $(WORKDIR) build
upd:
	docker compose --env-file .env --project-directory $(WORKDIR) up -d

up:
	docker compose --env-file .env --project-directory $(WORKDIR) up

stop:
	docker compose --env-file .env --project-directory $(WORKDIR) stop

down:
	docker compose --env-file .env --project-directory $(WORKDIR) down

remove_volume:
	echo "[i] Removing volumes:"
	sudo rm -Ir ~/data/*

re: down remove_volume build up

refresh: build up

ps:
	docker compose --env-file .env --project-directory $(WORKDIR) ps

## GENERATING SECRETS

secrets:
	./srcs/scripts/generate_secrets.sh

## FOR CLEANING SECRETS

clean_sec:
	rm ./secrets/*

.PHONY: secrets
