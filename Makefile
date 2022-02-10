current_branch := $(shell git rev-parse --abbrev-ref HEAD)

build:
	docker build -t llparse/hive:$(current_branch) ./

push:
	docker push llparse/hive:$(current_branch)
