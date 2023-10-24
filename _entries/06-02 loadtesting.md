---
sectionid: loadtesting
sectionclass: h2
title: Loadtesting
parent-id: autoscaling
---

Our scaling configuration is ready but it's now time to test it. There are plenty of tools dedicated to such tasks. Normally your company offers a load testing service maybe based on 3rd party products such as Locust, Gatling, k6, etc. You may also use [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/overview-what-is-azure-load-testing) service which is a SaaS version and can be set up in few seconds.

> Important: if your applications are privatly exposed you may need advanced configuration which require additional rights. In case you don't have these rights, we recommend to use [a simple Ubuntu docker image](https://hub.docker.com/r/centminmod/docker-ubuntu-nghttp2-minimal) which contained load testing tool such as h2load.

**Using Azure Load Testing**
{% collapsible %}


> In the Azure Portal, navigate to your shared resource group and click on your Azure Load Testing resource.
> Click the **Quick test** button to create a new test. In the **Quick test** blade, enter your ingress IP as the URL. 
> 
> Set the number of virtual users to **250**, test duration to **240** seconds, and the ramp up time of **60**.
> 
> Click the **Run test** button to start the test.



> If you are familiar with creating JMeter tests, you can also create a JMeter test file and upload it to Azure Load Testing.

![Azure Load Testing](assets/load-test-setup.png)


> As the test is running, run the following command to watch the deployment scale.


```bash
kubectl get deployment azure-voting-app -w
```


> In a different terminal tab, you can also run the following command to watch the Horizontal Pod Autoscaler reporting metrics as well.


```bash
kubectl get hpa -w
```

After a few minutes, you should start to see the number of replicas increase as the load test runs.

In addition to viewing your application metrics from the Azure Load Testing service, you can also view detailed metrics from your managed Grafana instance and/or Container Insights from the Azure Portal, so be sure to check that out as well.

{% endcollapsible %}

**Using h2load**

{% collapsible %}
{% endcollapsible %}

