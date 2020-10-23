#!/bin/bash

oc delete gateway google-web-egressgateway -n fs-mesh-dev
oc delete gateway google-web-egressgateway -n istio-system

oc delete destinationrule egressgateway-for-google-dr -n fs-mesh-dev
oc delete destinationrule egressgateway-for-google-dr -n istio-system

oc delete virtualservice direct-google-through-egress-gateway -n fs-mesh-dev
oc delete virtualservice direct-google-through-egress-gateway -n istio-system