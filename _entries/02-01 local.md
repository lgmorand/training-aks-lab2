---
sectionid: local
sectionclass: h2
title: Build locally
parent-id: build
---

#### Get the `webapp` source code

Download the `webapp` from the Github repository: [hello-worlds.zip](https://github.com/lgmorand/aks-workshop/raw/main/sample-app/hello-worlds.zip). If you are using the Cloud Shell you can either download and upload the files, or you can use *[wget](https://doc.ubuntu-fr.org/wget)* and *[unzip](https://doc.ubuntu-fr.org/zip)* commands.

{% collapsible %}

```sh
wget -O hello-worlds.zip https://github.com/lgmorand/engie-aks-lab2/raw/main/sample-app/hello-worlds.zip
unzip hello-worlds.zip
cd hello-worlds
cd nodejs
```

{% endcollapsible %}

> **Tip**: Once downloaded, it may be useful to look and read some of the files contained in the ZIP.

#### Build a Docker image

To run the app in Docker, you need to add a [Dockerfile](https://docs.docker.com/build/building/packaging/#dockerfile) describing how the app will be built and run.

Create a new file named `Dockerfile` at the root of the app code and fill it with instructions on how to build and run the app.

> **Hint** Refer to Docker's [language-specific guide](https://docs.docker.com/language/)

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
docker build -t webapp .
```

{% endcollapsible %}

#### Run the app

Use `docker run` to start a new container from the image you have just created. Use the port 9000 for your test (or any available one).

{% collapsible %}

```sh
# Use the port 9000 to serve the app
docker run -it -p 9000:80 webapp
```

{% endcollapsible %}

Finally, load the app URL [http://localhost:9000](http://localhost:9000) in a browser and make sure you see a `Hello world` message.

> **Resources**
>
> * <https://docs.docker.com/get-started/02_our_app/>
> * <https://docs.docker.com/language/>
> * <https://docs.docker.com/engine/reference/builder/>