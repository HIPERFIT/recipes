include ./config

all: docker_build run

docker_build:
	docker build -t hiperfit/recipes .

run:
	docker run -itp $(PORT):$(PORT) \
	  --env-file ./config \
		-v $(PWD)/notebooks:/home/jovyan/work \
	 	-v $(PWD)/.jupyter/:/home/jovyan/.jupyter/ \
		hiperfit/recipes

.PHONY: all docker_build run
