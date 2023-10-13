---
sectionid: scale
sectionclass: h2
title: Scale your application
parent-id: build
---

### Scaling

You deployed your application but you anticipate a high load of your application.



#### Control the deployment

Your pipeline went fine but how do you ensure that your replicas are here ?

Connect to your cluster and list your deployment to check that you have 10 running containers.

Now, list your pods. How are your pods replicated accross the nodes ? List the pods in a way to see the nodes

kubectl get pods -w