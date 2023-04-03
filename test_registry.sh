#docker run --rm  -d --name docker_registry_proxy -it \
#       -p 0.0.0.0:3128:3128 -e ENABLE_MANIFEST_CACHE=true \
#       -v $(pwd)/docker_mirror_cache:/docker_mirror_cache \
#       -v $(pwd)/docker_mirror_certs:/ca \
#       rpardini/docker-registry-proxy:0.6.2

docker run -p 5000:5000 --rm  -d --name registry -v /tmp/registry:/var/lib/registry -e REGISTRY_PROXY_REMOTEURL="https://registry-1.docker.io"  registry:2

