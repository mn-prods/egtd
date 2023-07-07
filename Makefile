.DEFAULT_GOAL := help

# takes in positional parameters
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# export environemnt variables from dev.env file
ifneq (,$(wildcard ./dev.env))
    include dev.env
    export
endif

##help: @ show commands of this makefile
help:
	@fgrep -h "##" $(MAKEFILE_LIST)| sort | fgrep -v fgrep | tr -d '##'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
##start: @ docker-compose up
start: 
	docker-compose --env-file ./dev.env up -d

##stop: @ docker-compose down
stop: 
	docker-compose --env-file ./dev.env down

##build: @ docker-compose build
build:
	docker-compose build

##logs: @ show logs -follow
logs:
	docker-compose logs --follow

##restart: @ stop -> start
restart: stop start

##code: @ open current workspace in vscode
code: 
	code workspace.code-workspace

##be-logs: @ show backend logs
be-logs: 
	docker logs --follow "backend-${APP_NAME}"

##fe-logs: @ show frontend logs
fe-logs: 
	docker logs --follow "frontend-${APP_NAME}"

##be-sh: @ enter backend shell and launch bash
be-sh: 
	docker exec -it "backend-${APP_NAME}" bash

##fe-sh: @ enter frontend shell and launch bash
fe-sh: 
	docker exec -it "frontend-${APP_NAME}" bash

##migrate: @ generate migration (takes migration name as positional argument)
migrate:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:generate --name=$(RUN_ARGS)

##run-migration: @ run migrations
run-migration:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:run

##revert-migration: @ revert last migration
revert-migration:
	@docker exec -it "backend-${APP_NAME}" npm run typeorm:revert

gitcrypt-init:
	cd backend && git-crypt init
	cd frontend && git-crypt init
	git-crypt init
	cp ${GITCRYPT_KEY_PATH} backend/.git/git-crypt/keys/default
	cp ${GITCRYPT_KEY_PATH} frontend/.git/git-crypt/keys/default
	cp ${GITCRYPT_KEY_PATH} .git/git-crypt/keys/default