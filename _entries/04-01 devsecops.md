---
sectionid: devsecops
sectionclass: h2
title: Scanning your files
parent-id: security
---

### DevSecOps

DevSecOps, short for Development, Security, and Operations, is an approach to software development that integrates security practices into the software development and deployment process. It is important in modern software development for several key reasons:

- **Early Detection and Mitigation of Security Vulnerabilities**: DevSecOps focuses on identifying and addressing security issues at an early stage of development. This reduces the likelihood of security vulnerabilities making their way into the final product, saving time and resources that would otherwise be spent on fixing security flaws post-deployment.

- **Faster Response to Security Threats**: In a DevSecOps environment, security practices are automated and integrated into the development pipeline. This enables rapid response to security threats and the ability to push out security updates quickly. This is critical in a world where cyber threats are constantly evolving.

- **Compliance and Regulatory Requirements**: Many industries are subject to strict regulatory requirements related to data privacy and security (e.g., GDPR, HIPAA). DevSecOps helps organizations ensure compliance by embedding security measures into the development process, making it easier to meet these obligations.

- **Risk Reduction**: By integrating security practices from the outset, DevSecOps reduces the overall risk of security breaches and data loss. This helps organizations protect their reputation, customer trust, and financial assets.

- **Cost-Efficiency**: Fixing security vulnerabilities post-deployment can be expensive and time-consuming. DevSecOps reduces these costs by identifying and addressing security issues early in the development process.

- **Continuous Improvement**: DevSecOps encourages a culture of continuous improvement. Security measures and best practices are regularly reviewed and updated to adapt to the changing threat landscape.

- **Automation**: Automation is a key component of DevSecOps. Automated security testing, continuous monitoring, and threat detection tools help identify and address security issues more efficiently and consistently.

That's why you are going to improve the security of your application !

When you want to secure a containerize application you need to scan/test different components:

- your code, the one your wrote yourself
- the dependencies of your code (package nuget, maven, npm, etc)
- the dockerfile
- your manifest

Each of them require different tools. To analyse your code, you need a SAST (Static Analysis Security Testing) and for the dependencies, you need a SCA (Static Composition Analysis). You are going to focus on your dockerfile and kubernetes manifest. You goal is to include steps in your build pipeline to scan them and not to push the image if issues are found

You can use any tool of your choice, such as Trivy, [hadolint](https://kristhecodingunicorn.com/post/k8s_hadolint/) or [other tools](https://github.com/lgmorand/k8s-devSecOps) but you need to implement in your pipeline. You must lint your files but also check for vulnerabilities.

> Note: you may to use more than one tool ;-)


Trivy => une tache existe
