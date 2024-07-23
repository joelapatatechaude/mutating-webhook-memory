# Mutating webhook for admission controller that set the Memory limit to the Memory Request value, when the Memory request value is defined

If for some reasons this work is usefull for you, don't use my container. Who knows what's inside!
Instead, inspect the code (it's simple) build your own container, and use it. See below for instructions

## Install python dependencies to run locally

```bash
pip install fastapi uvicorn
```

## Generate a test certificate
```bash
./generate-test-tls.sh
```
This will just generate a test crt / key pair. It's required because the webhook muse use tls. Those cert
are just here for test purpose for local run. A valid cert will be auto-generate on OpenShift.

## Run locally with:
```bash
python webhook.py
```

This will start a server on 0.0.0.0:8000

## Test localy

There is a helper test.sh function that test the server with some examples from the AdmissionReviewExamples folder.

```bash
./test.sh
```

## Build the container

The Containerfile is leveraging the Red Hat UBI-minimal base image. It's secured, slim, and will work on OpenShift out of the box. You may need to register for a Red Hat account, or you main need to use a different base image, and update it to meet OpenShift security requirements. Read this https://docs.openshift.com/container-platform/4.16/openshift_images/create-images.html#use-uid_create-images or this (it's an old post, but still valide) https://developers.redhat.com/blog/2020/10/26/adapting-docker-and-kubernetes-containers-to-run-on-red-hat-openshift-container-platform#

```bash
podman build . -t your_image_name
podman push your_image_name
```

## Deploy on your OpenShift cluster

There is a helm directory you can leverage. At the moment there is no template at all done, so you can also directly
use the resources defined in helm-mutating-webhook-memory/templates/*.yaml

### namespace.yaml
This just create a namespace called admission-webhook

### service.yaml
This create the service that will be used by the kubernetes admission controller `MutatingAdmissionWebhook` https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook

Note that a service certificate is automatically injected with the openshift annotation:
```
service.beta.openshift.io/serving-cert-secret-name: my-memory-tls
```
so in the my-memory-tls secret will be the key / cert used.

### deployment.yaml
The deployement uses my own image (you will want to change it for seurity reasons. It also mount and use the certs that were automatically created by the service (see service.yaml).

### mutatingWebhookConfiguration.yaml
This define the webhook. A few things to note:
The CA certificate automatically used to generate the certificates automatically via the service injection needs to be trusted. This can be done
with the simple annotation:
    service.beta.openshift.io/inject-cabundle: "true"

failurePolicy is set to Ignore. That's to ensure that if there is an issue witht he webhook server (crash, bug, crowdstrike), the pod get created without mutation.

timeout is set to 3 sec, I don't see any reasons why it would take longer.
