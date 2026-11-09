COMPOSE = docker compose -f srcs/docker-compose.yml
DATA    = $(HOME)/data

all:
	mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	docker run --rm -v $(DATA):/data debian:bookworm sh -c "rm -rf /data/*"

re: fclean all

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

.PHONY: all down clean fclean re ps logs

