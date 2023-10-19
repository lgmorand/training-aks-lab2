---
sectionid: scale
sectionclass: h2
title: Scale your application
parent-id: deploy
---

### Scaling

You deployed your application but you anticipate a high load of your application. The first solution is to manually scale out your application by increasing the number of instances of your application.

Connect to your cluster and increase the numbers of pods using the command line. Try to have 5 workings pods and try to find how by reading the [documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

{% collapsible %}

```sh
kubectl scale deployment/nginx-deployment --replicas=5
```

{% endcollapsible %}

It worked but is it a good practice to change the numbers of replicas directly in the cluster ? The answer is "no" because on the next run of your deployment pipeline, the number of replicas will come back to the original value. It is called "configuration drift" because your source of truth (the repository) is not equal to your production environment.

Edit your manifest accordingly and specify the number of replicas there. Run again your deployment pipeline.

#### Control the deployment

Your pipeline went fine but how do you ensure that your replicas are here ?

Connect to your cluster and list your deployment to check that you have **10** running containers.

{% collapsible %}

```sh
kubectl get pods
```

{% endcollapsible %}

Now, list your pods. How are your pods replicated accross the nodes ? List the pods in a way to see the nodes

{% collapsible %}

```sh
kubectl get pods -w
```

{% endcollapsible %}
