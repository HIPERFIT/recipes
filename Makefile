build-docker:
	docker build -t recipes .

run:
	docker run -itp 8888:8888 -v $(PWD)/notebooks:/notebooks recipes
