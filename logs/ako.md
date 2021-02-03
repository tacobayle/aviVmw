https://medium.com/@kanrangsan/how-to-specify-internal-ip-for-kubernetes-worker-node-24790b2884fd
https://networkinferno.net/trouble-with-the-kubernetes-node-ip

```
helm repo add ako https://avinetworks.github.io/avi-helm-charts/charts/stable/ako
kubectl apply -f namespace_avi-system.yml
kubectl create secret docker-registry docker --docker-server=docker.io --docker-username=tacobayle --docker-password=***** --docker-email=nicolas.bayle@gmail.com -n avi-system
kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"docker\"}]}" -n avi-system
helm --debug install ako/ako --generate-name --version 1.3.1 -f values.yml --namespace=avi-system
kubectl patch serviceaccount ako-sa -p "{\"imagePullSecrets\": [{\"name\": \"docker\"}]}" -n avi-system
kubectl delete pod ako-0 -n avi-system
```

```
# Default values for ako.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: avinetworks/ako
  pullPolicy: IfNotPresent

### This section outlines the generic AKO settings
AKOSettings:
  logLevel: "INFO" #enum: INFO|DEBUG|WARN|ERROR
  fullSyncFrequency: "1800" # This frequency controls how often AKO polls the Avi controller to update itself with cloud configurations.
  apiServerPort: 8080 # Internal port for AKO's API server for the liveness probe of the AKO pod default=8080
  deleteConfig: "false" # Has to be set to true in configmap if user wants to delete AKO created objects from AVI
  disableStaticRouteSync: "false" # If the POD networks are reachable from the Avi SE, set this knob to true.
  clusterName: "cluster1" # A unique identifier for the kubernetes cluster, that helps distinguish the objects for this cluster in the avi controller. // MUST-EDIT
  cniPlugin: "flannel" # Set the string if your CNI is calico or openshift. enum: calico|canal|flannel|openshift
  #NamespaceSelector contains label key and value used for namespacemigration
  #Same label has to be present on namespace/s which needs migration/sync to AKO
  namespaceSelector:
    labelKey: ""
    labelValue: ""

### This section outlines the network settings for virtualservices.
NetworkSettings:
  ## This list of network and cidrs are used in pool placement network for vcenter cloud.
  ## Node Network details are not needed when in nodeport mode / static routes are disabled / non vcenter clouds.
  nodeNetworkList: []
  # nodeNetworkList:
  #   - networkName: "network-name"
  #     cidrs:
  #       - 10.0.0.1/24
  #       - 11.0.0.1/24
  subnetIP: "100.64.137.0" # Subnet IP of the vip network
  subnetPrefix: "24" # Subnet Prefix of the vip network
  networkName: "vxw-dvs-34-virtualwire-124-sid-1080123-sof2-01-vc08-avi-dev120" # Network Name of the vip network
  enableRHI: false # This is a cluster wide setting for BGP peering.

### This section outlines all the knobs  used to control Layer 7 loadbalancing settings in AKO.
L7Settings:
  defaultIngController: "true"
  l7ShardingScheme: "hostname"
  serviceType: ClusterIP #enum NodePort|ClusterIP
  shardVSSize: "LARGE" # Use this to control the layer 7 VS numbers. This applies to both secure/insecure VSes but does not apply for passthrough. ENUMs: LARGE, MEDIUM, SMALL
  passthroughShardSize: "SMALL" # Control the passthrough virtualservice numbers using this ENUM. ENUMs: LARGE, MEDIUM, SMALL

### This section outlines all the knobs  used to control Layer 4 loadbalancing settings in AKO.
L4Settings:
  advancedL4: "false" # Use this knob to control the settings for the services API usage. Default to not using services APIs: https://github.com/kubernetes-sigs/service-apis
  defaultDomain: "" # If multiple sub-domains are configured in the cloud, use this knob to set the default sub-domain to use for L4 VSes.

### This section outlines settings on the Avi controller that affects AKO's functionality.
ControllerSettings:
  serviceEngineGroupName: "SeGroupAko1" # Name of the ServiceEngine Group.
  controllerVersion: "20.1.3" # The controller API version
  cloudName: "cloudVmw" # The configured cloud name on the Avi controller.
  controllerHost: "10.41.135.79" # IP address or Hostname of Avi Controller
  tenantsPerCluster: "false" # If set to true, AKO will map each kubernetes cluster uniquely to a tenant in Avi
  tenantName: "admin" # Name of the tenant where all the AKO objects will be created in AVI. // Required only if tenantsPerCluster is set to True

nodePortSelector: # Only applicable if serviceType is NodePort
  key: ""
  value: ""

resources:
  limits:
    cpu: 250m
    memory: 300Mi
  requests:
    cpu: 100m
    memory: 200Mi

podSecurityContext: {}

rbac:
  # Creates the pod security policy if set to true
  pspEnable: false


avicredentials:
  username: admin
  password: Avi_2021
  certificateAuthorityData: # optional - used for controller identity verification


service:
  type: ClusterIP
  port: 80


persistentVolumeClaim: ""
mountPath: "/log"
logFile: "avi.log"
```

```
kubectl delete namespace avi-system
kubectl delete ClusterRoleBinding ako-crb
kubectl delete ClusterRole ako-cr
kubectl apply -f namespace_avi-system.yml
```

```
```

```
kubectl logs ako-0 -n avi-system
```