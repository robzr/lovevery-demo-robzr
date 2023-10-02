NAME = lovevery-demo-robzr-backend
DOCKER_IMAGE = ruby:3.2

image : .docker-made 

.docker-made : Gemfile.lock
	docker build --build-arg DOCKER_IMAGE="$(DOCKER_IMAGE)" -t "$(NAME)" .
	touch .docker-made

Gemfile.lock :
	docker run --rm -v "$$PWD":/usr/src/app -w /usr/src/app "$(DOCKER_IMAGE)" bundle install

all : Gemfile.lock .docker-made 

clean :
	rm -f .docker-made Gemfile.lock
