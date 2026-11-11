COMPOSE = docker compose -f srcs/docker-compose.yml
DATA    = $(HOME)/data

all:
	mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	$(COMPOSE) up -d --build

# stop and remove containers and netwokk
down:
	$(COMPOSE) down

# remove the images the project built
clean:
	$(COMPOSE) down -v --rmi all

# delete also the data files
fclean: clean
	docker run --rm -v $(DATA):/data debian:bookworm sh -c "rm -rf /data/*"

re: fclean all

# execute
ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

.PHONY: all down clean fclean re ps logs

