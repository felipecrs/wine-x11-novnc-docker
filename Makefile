build:
	docker build -t wine-x11-novnc-docker .

run: build
	docker run --rm -p 8080:8080 wine-x11-novnc-docker

shell: build
	docker run --rm -ti -p 8080:8080 wine-x11-novnc-docker bash
