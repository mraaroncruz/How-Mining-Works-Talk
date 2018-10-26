build:
	docker build -t mining/auth .

run:
	docker run -it -p 3000:3000 --rm  -v $$(pwd)/keys:/keys mining/auth
