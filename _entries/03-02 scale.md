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
kubectl scale deployment/helloworld --replicas=5
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
kubectl get pods -o wide
```

You should see something like this and you can see that pods are deployed on the different nodes of your cluster.

```sh
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
helloworld-75d9b9d44c-7f7rh   1/1     Running   0          40s   10.244.0.10   aks-agentpool-14914408-vmss000000   <none>           <none>
helloworld-75d9b9d44c-ctdrv   1/1     Running   0          40s   10.244.0.11   aks-agentpool-14914408-vmss000000   <none>           <none>
helloworld-75d9b9d44c-kqmdv   1/1     Running   0          40s   10.244.1.9    aks-agentpool-14914408-vmss000001   <none>           <none>
helloworld-75d9b9d44c-kw47c   1/1     Running   0          40s   10.244.1.8    aks-agentpool-14914408-vmss000001   <none>           <none>
helloworld-75d9b9d44c-qjkg2   1/1     Running   0          77m   10.244.1.7    aks-agentpool-14914408-vmss000001   <none>           <none>
```

{% endcollapsible %}
