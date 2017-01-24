.PHONY: bin image push release clean

TAG=vancluever/gravitational_teleport
COMMIT_SHA256_SHORT ?= 45dcc18

image: bin
	docker build --tag $(TAG):latest --tag $(TAG):$(COMMIT_SHA256_SHORT) \
		--build-arg TELEPORT_COMMIT_SHA256=$(COMMIT_SHA256_SHORT) .

push: image
	docker push $(TAG):latest

release: push

clean:
	docker rmi -f $(TAG)
