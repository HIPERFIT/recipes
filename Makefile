all: docker_build run

docker_build:
	docker build -t recipes .

run:
	docker run -itp 8888:8888 \
		-v $(PWD)/notebooks:/notebooks \
	 	-v $(PWD)/.jupyter/:/home/jovyant/.jupyter/ \
		recipes

.PHONY: all docker_build run
