build:
	docker build -t mining/p2p .

master:
	docker run -it -p 3000:3000 --network mining --hostname master --name master -v $$(pwd)/keys:/keys -e HOSTNAME=master --rm mining/p2p

peer:
	docker run -it --network mining --hostname peer${peer} --name peer${peer} -e HOSTNAME=peer${peer} --rm  mining/p2p
