---
sectionid: registry
sectionclass: h2
title: Push to a registry
parent-id: build
---

#### Publish your container image

To deploy a docker image, you first need to publish it a container registry. On Azure, the solution is Azure Container Registry but you may also decide to use an alternative such as [Harbor](https://goharbor.io).

Add steps to your pipeline to [push your images](https://goharbor.io/docs/1.10/working-with-projects/working-with-images/pulling-pushing-images/) to your registry (registry.gems.myengie.com)

{% collapsible %}

With Podman

``` bash
podman push --creds='$(REGISTRY_CREDS)' $(REGISTRY)/gems-training/studentXXX-$(BUILD_ID)
```



With Docker

``` bash
docker login <url-registry>

docker tag <image-name>[:TAG] <container-registry-IP>/<project-name>/<image-name>[:TAG]

docker push <container-registry-IP>/<namespace-name>/<image_name>
```


{% endcollapsible %}

> Warning: never forget that using latest tag is [most of the time a very bad practice](https://vsupalov.com/docker-latest-tag/). It's not mandatory in the lab but you should find a way to have an incremental tag number.
