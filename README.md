# Introduction
OpenShift Service Mesh (OSSM) provides the ability to add policies for authorization and telemetry. This repository represents my exploration into the varios ways to limit
egress traffic from single control plane with two different namespaces/projects as members. 

### Cluster Baseline
In order to setup the cluster, run the following scripts. 

#### Initialize Projects

```
oc apply -f 0-projects.yaml 
```

This will create three different projects, "istio-system", "fs-mesh-dev", and "fs-mesh-qa". 

#### Install ServiceMesh
```
oc apply -f 1-sm-operator-install.yaml
```
NOTE: This will take some time to install the dependencies of OSSM. Please wait until Elasticsearch, Jaeger, Kiali, and ServiceMesh operators have installed.

#### Control Plane Installation
```
oc apply -f 2-service-mesh.yaml
```
The control plane consists of 13 different services. You should wait for all 13 containers to start before proceeding to deploy the sleep application. 

```
oc get pods -n istio-system
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-5c6fcd5bf7-lwstc                  2/2     Running   0          19m
ior-df7654496-xhfs5                       1/1     Running   0          20m
istio-citadel-64797dccf6-84n78            1/1     Running   0          22m
istio-egressgateway-8656bccb6d-8x4w9      1/1     Running   0          20m
istio-galley-858fb6647-t2j65              1/1     Running   0          21m
istio-ingressgateway-7789988b56-gctdp     1/1     Running   0          20m
istio-pilot-969f74856-cbvsf               2/2     Running   0          20m
istio-policy-5b46944fdc-vqk5x             2/2     Running   0          20m
istio-sidecar-injector-5678f8b95b-pz7hm   1/1     Running   0          19m
istio-telemetry-6dbcf89d7d-s4nbn          2/2     Running   0          20m
jaeger-74df484d98-fw468                   2/2     Running   0          21m
kiali-854cbc566b-jpcl6                    1/1     Running   0          17m
prometheus-7fc9c6d99-2cdck                2/2     Running   0          21m
```

#### Base Application Deployment
This example uses the sleep container so we can use curl in the terminal window. This will enable us to attempt to connect to www.google.com.

```
oc apply -f 3-sleep-workload.yaml -n fs-mesh-dev
oc apply -f 4-sleep-workload-qa.yaml -n fs-mesh-qa
```

This completes the baseline setup for the cluster. At this point, you can test with:

```
export SOURCE_POD=$(oc get pod -l app=sleep -o jsonpath={.items..metadata.name} -n fs-mesh-dev )

oc exec "$SOURCE_POD" -n fs-mesh-dev -c sleep -- curl -sL -o /dev/null -D - https://edition.cnn.com/politics
```

you will not get a response. This is because the ServiceMeshControlPlane has *outboundTrafficPolicy* set to REGISTRY_ONLY. Since www.google.com is not in the service registry, it will not work. 

### Set egress rules

Deny all egress from fs-mesh-dev namespace

Deny all egress frmo fs-mesh-qa namespace

Allow only access to edition.cnn.com  from istio-system namespace

`oc apply -f ./policies/0-egressnetworkpolicy.yaml`

## Configure egress gateway to access edition.cnn.com

`oc apply -f ./policies/1-cnn-gateway.yml`

### Enabling CNN Access in fs-mesh-dev and fs-mesh-qa
In order to get curl to work in fs-mesh-dev.sleep and fs-mesh-qa.sleep,, add a ServiceEntry resource.

```
oc apply -f ./policies/2-cnn-serviceEntries.yml
```

Setup virtual service to route calls to edition.cnn.com to the egress gateway:

```
oc apply -f ./policies/3-cnn-virtualService.yml
```

Test access to editon.cnn.com from fs-mesh-dev

`oc exec "$SOURCE_POD" -n fs-mesh-dev -c sleep -- curl -sL -o /dev/null -D - https://edition.cnn.com/politics`

Test access to editon.cnn.com from fs-mesh-qa

```
export SOURCE_POD2=$(oc get pod -l app=sleep-qa -o jsonpath={.items..metadata.name} -n fs-mesh-qa )

oc exec "$SOURCE_POD2" -n fs-mesh-qa -c sleep-qa -- curl -sL -o /dev/null -D - https://edition.cnn.com/politics 

```
