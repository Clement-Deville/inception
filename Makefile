WORKDIR=./srcs/

build:
	docker compose --project-directory $(WORKDIR) build
up:
	docker compose --project-directory $(WORKDIR) up -d 

stop:
	docker compose --project-directory $(WORKDIR) stop

down:
	docker compose --project-directory $(WORKDIR) down

re: down build up

refresh: build up

ps: 
	docker compose --project-directory $(WORKDIR) ps
