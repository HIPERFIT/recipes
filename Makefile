all: docker_build run

docker_build:
	docker build -t hiperfit/recipes .

run:
	docker run -itp 8888:8888 \
		-v $(PWD)/notebooks:/notebooks \
	 	-v $(PWD)/.jupyter/:/home/jovyant/.jupyter/ \
		hiperfit/recipes

.PHONY: all docker_build run
