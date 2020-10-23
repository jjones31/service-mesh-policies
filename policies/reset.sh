#!/bin/bash

oc delete handler allow-handler -n fs-mesh-dev
oc delete handler allow-handler -n istio-system

oc delete instance allow-instance -n fs-mesh-dev
oc delete instance allow-instance -n istio-system

oc delete rule allow-rule -n fs-mesh-dev
oc delete rule allow-rule -n istio-system

# Egress
oc delete handler allow-egress-handler -n fs-mesh-dev
oc delete handler allow-egress-handler -n istio-system

oc delete instance allow-egress-instance -n fs-mesh-dev
oc delete instance allow-egress-instance -n istio-system

oc delete rule allow-egress-rule -n fs-mesh-dev
oc delete rule allow-egress-rule -n istio-system

# Logging
oc delete handler logentryhandler -n fs-mesh-dev
oc delete handler logentryhandler -n istio-system

oc delete instance logentryrequest -n fs-mesh-dev
oc delete instance logentryrequest -n istio-system

oc delete rule logentryrule -n fs-mesh-dev
oc delete rule logentryrule -n istio-system