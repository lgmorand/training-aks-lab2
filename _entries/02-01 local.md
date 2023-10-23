---
sectionid: local
sectionclass: h2
title: Build locally
parent-id: build
---

#### Get the `webapp` source code

Download the `webapp` from the Github repository: [hello-world.zip](https://stoakslab2.z6.web.core.windows.net/source/hello-world.zip). If you are using the Cloud Shell you can either download and upload the files, or you can use *[wget](https://doc.ubuntu-fr.org/wget)* and *[unzip](https://doc.ubuntu-fr.org/zip)* commands.

{% collapsible %}

```sh
wget -O hello-world.zip https://stoakslab2.z6.web.core.windows.net/source/hello-world.zip
unzip hello-world.zip
cd hello-world
cd nodejs
```

{% endcollapsible %}

> **Tip**: Once downloaded, it may be useful to look and read some of the files contained in the ZIP.

#### Build a Docker image

To run the app in Docker, you need to add a [Dockerfile](https://docs.docker.com/build/building/packaging/#dockerfile) describing how the app will be built and run.

Create a new file named `Dockerfile` at the root of the app code and fill it with instructions on how to build and run the app. We could build the app and then containerize the result, but it also smart to do the build within the container and guaranty the same behavior of the build part too. To do that, you will have to use multi-stage build.

> **Hint** Refer to Docker's [language-specific guide](https://docs.docker.com/language/) to write your dockerfile and try to find within the code, the command to build (compile) the app.

{% collapsible %}

```dockerfile
FROM node:lts

ENV NODE_ENV=production

# Copy app code and install dependencies
WORKDIR /app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm ci
COPY . .

# Start the app
EXPOSE 80
CMD [ "node", "server.js" ]
```

{% endcollapsible %}

Now that you have a Dockerfile, you need to use it to build a Docker image.

Use `docker build` to create the image.

{% collapsible %}

```sh
# Run this command in the root of the nodejs directory, where you created a Dockerfile
docker build -t helloworld .
```

{% endcollapsible %}

#### Run the app

Use `docker run` to start a new container from the image you have just created. Use the port 9000 for your test (or any available one).

{% collapsible %}

```sh
# Use the port 9000 to serve the app
docker run -it -p 9000:80 helloworld
```

{% endcollapsible %}

Finally, load the app URL [http://localhost:9000](http://localhost:9000) in a browser and make sure you see a `Hello world` message.

> **Resources**
>
> * <https://docs.docker.com/get-started/02_our_app/>
> * <https://docs.docker.com/language/>
> * <https://docs.docker.com/engine/reference/builder/>

Ok, you know how to containerize an application to test it locally, but let's now do it properly following DevOps principles.
