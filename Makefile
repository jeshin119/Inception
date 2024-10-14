WP_DATA = /home/jeshin/data/wordpress
DB_DATA = /home/jeshin/data/mariadb

all: up

up: build
	@mkdir -p $(WP_DATA);
	@mkdir -p $(DB_DATA);
	docker-compose -f ./srcs/docker-compose.yml up -d

down:
	docker-compose -f ./srcs/docker-compose.yml down

stop:
	docker-compose -f ./srcs/docker-compose.yml stop

start:
	docker-compose -f ./srcs/docker-compose.yml start

build:
	docker-compose -f ./srcs/docker-compose.yml build

clean:
	@docker stop $$(docker ps -qa) 2>.log || true
	@docker rm $$(docker ps -qa) 2>.log || true
	@docker rmi -f $$(docker images -qa) 2>.log || true
	@docker volume rm $$(docker volume ls -q) 2>.log || true
	@docker network rm inception 2>.log || true
 
re: clean up

prune: clean
	@docker system prune -a --volumes -f