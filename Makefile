APP_DIR = app
NAME = lovevery-demo-robzr
PLATFORMS = aarch64-linux x86_64-linux
PORT = 3000
# also-ref Dockerfile
WORKDIR = /opt/app


all :: image


$(APP_DIR)/Gemfile.lock : .make-image-base
	docker run -e BUNDLE_FROZEN=false --rm -v "$(PWD)/$(APP_DIR):$(WORKDIR)" \
	  "$(NAME)-base" bundle install
	@touch "$@" # bundle install will not always update mtime

.make-image : .make-image-bundled \
	      $(APP_DIR)/ \
              $(wildcard $(APP_DIR)/*) \
              $(wildcard $(APP_DIR)/**/*) 
	docker build -t "$(NAME)" --target image .
	@touch $@

.make-image-base : Dockerfile
	docker build -t "$(NAME)-base" --target image-base .
	@touch $@

.make-image-bundled : .make-image-base $(APP_DIR)/Gemfile.lock
	docker build --build-arg PLATFORMS="$(PLATFORMS)" \
	  -t "$(NAME)-bundled" --target image-bundled .
	@touch $@

.make-image-rails : .make-image-base
	docker build -t "$(NAME)-rails" --target image-rails .
	@touch $@

clean ::
	rm -f .make-*
	docker image rm -f "$(NAME)" "$(NAME)-bundled" "$(NAME)-base"
	docker image prune -a -f

image :: .make-image

image-base :: .make-image-base

image-bundled :: .make-image-bundled

image-rails :: .make-image-rails

lock :: $(APP_DIR)/Gemfile.lock

prune ::
	docker container prune -f
	docker image prune -a -f

run :: .make-image
	docker run -it -p "$(PORT):$(PORT)/tcp" "$(NAME)" server -b 0.0.0.0 -p "$(PORT)"

stub-app :: .make-image-rails
	@if [ -d "$(APP_DIR)" ] ; then \
	  echo "\nError: app directory already exists, aborting\n" ; \
	  exit 1 ; \
	fi
	docker run -v "$(PWD):$(WORKDIR)" \
	  "$(NAME)-rails" new --skip-bundle "$(APP_DIR)"

stub-route :: .make-image-bundled
	docker run -v "$(PWD)/$(APP_DIR):$(WORKDIR)" \
	  "$(NAME)-bundled" generate controller Articles index --skip-routes
