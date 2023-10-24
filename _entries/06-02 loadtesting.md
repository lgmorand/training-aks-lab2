---
sectionid: loadtesting
sectionclass: h2
title: Loadtesting
parent-id: autoscaling
---

Our scaling configuration is ready but it's now time to test it. There are plenty of tools dedicated to such tasks. Normally your company offers a load testing service maybe based on 3rd party products such as Locust, Gatling, k6, etc. You may also use [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/overview-what-is-azure-load-testing) service which is a SaaS version and can be set up in few seconds.

> Important: if your applications are privatly exposed you may need advanced configuration which require additional rights. In case you don't have these rights, we recommend to use [a simple Ubuntu docker image](https://hub.docker.com/r/centminmod/docker-ubuntu-nghttp2-minimal) which contained load testing tool such as h2load or a simpler alternative, to use a docker image containing [vegeta](https://github.com/peter-evans/vegeta-docker).

**Using Azure Load Testing**
{% collapsible %}

In the Azure Portal, navigate to your shared resource group and click on your Azure Load Testing resource.

- Click the **Quick test** button to create a new test. In the **Quick test** blade, enter your ingress IP as the URL.
- Set the number of virtual users to **250**, test duration to **240** seconds, and the ramp up time of **60**.
- Click the **Run test** button to start the test.
- If you are familiar with creating JMeter tests, you can also create a JMeter test file and upload it to Azure Load Testing.

![Azure Load Testing](assets/load-test-setup.png)

As the test is running, run the following command to watch the deployment scale.

```bash
kubectl get deployment helloworld -w
```

In a different terminal tab, you can also run the following command to watch the Horizontal Pod Autoscaler reporting metrics as well.

```bash
kubectl get hpa -w
```

Which after some time should show something like this. It's normal that it takes few seconds/minutes.

```bash
azure [ ~ ]$ kubectl get hpa
NAME                           REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
keda-hpa-my-app-scaledobject   Deployment/helloworld   2%/50%    1         100       1          20s
```

After a few minutes, you should start to see the number of replicas increase as the load test runs.

In addition to viewing your application metrics from the Azure Load Testing service, you can also view detailed metrics from your managed Grafana instance and/or Container Insights from the Azure Portal, so be sure to check that out as well.

{% endcollapsible %}

**Using vegeta**

If you are using [vegeta](https://github.com/peter-evans/vegeta-docker), deploy it within the cluster and do it using command line only. It's a temporary tool so we don't need to put it in your code repository.

{% collapsible %}

The following command:

- creates a pod (because restart=Never, else it would be a deployment)
- using the image peterevans/vegeta
- and pass it a starting command which:
  - uses the /tic endpoint
  - from the IP of your pod
  - start loadtesting during 30 seconds
  - with 1000 requests per second
  - generate a report

```bash
kubectl run vegeta --rm --attach --restart=Never --image="peterevans/vegeta" -- sh -c \
"echo 'GET http://10.244.0.25/tic' | vegeta attack -rate=1000 -duration=30s | tee results.bin | vegeta report"
```

As soon as you run it, in another shell (or in the Web portal) you should see your deployment helloworld to scale out.

```bash
kubectl get hpa -w
```

Which after some time should show something like this. It's normal that it takes few seconds/minutes.

```bash
azure [ ~ ]$ kubectl get hpa
NAME                           REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
keda-hpa-helloworld-scaledobject   Deployment/helloworld   762%/50%    1         100       18          20s
```

{% endcollapsible %}
