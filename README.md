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

This completes the baseline setup for the cluster. At this point, if you terminal into the sleep container and issue:

```
curl www.google.com
```

you will not get a response. This is because the ServiceMeshControlPlane has *outboundTrafficPolicy* set to REGISTRY_ONLY. Since www.google.com is not in the service registry, it will not work. 

### Enabling Google Access in fs-mesh-dev
In order to get curl to work in fs-mesh-dev.sleep, add a ServiceEntry resource.

```
oc apply -f policies/1-google-service-entry.yaml -n fs-mesh-dev
```

Now, open a terminal to the sleep pod and execute issue the curl command. You should see a response back from google. However, since the ServiceEntry is using the exportTo ".", executing 
curl from fs-mesh-qa will not work. 

