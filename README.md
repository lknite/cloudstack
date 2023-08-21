under development

### Goal ###
Create a container capable of running apache cloudstack which can be used along with clusterapi to deploy kubernetes clusters to xcp-ng.

```
$ cat base/Chart.yaml 
apiVersion: v2
name: cloudstack
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
appVersion: "1.0"

dependencies:
- name: mysql
  version: 9.9.0
  repository: https://charts.bitnami.com/bitnami

$ cat base/values.yaml 
mysql:

  auth:
    ## @param auth.rootPassword Password for the `root` user. Ignored if existing secret is provided
    ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mysql#setting-the-root-password-on-first-run
    ##
    rootPassword: "passwordgoeshere"

  primary:
    persistence:
      accessModes:
      - ReadWriteMany

$ cat base/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cloudstack
  name: cloudstack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudstack
  strategy: {}
  template:
    metadata:
      labels:
        app: cloudstack
    spec:
      initContainers:
      - name: init-wait
        image: alpine
        command: ["sh", "-c", "for i in $(seq 1 300); do nc -zvw1 cloudstack-mysql 3306 && exit 0 || sleep 3; done; exit 1"]
      containers:
      - image: harbor.vc-prod.k.home.net/cloudstack/cloudstack:latest
        name: cloudstack
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
        command: ['sh', '-c']
        args:
        - if [ ! -f /tmp/db_initialized ]; then cloudstack-setup-databases cloud:password@cloudstack-mysql.cloudstack.svc --deploy-as=roo
t:passwordhere; fi;
          touch /tmp/db_initialized;
          source /etc/default/cloudstack-management;
          pushd /var/log/cloudstack/management;
          /usr/bin/java $JAVA_DEBUG $JAVA_OPTS -cp $CLASSPATH $BOOTSTRAP_CLASS
```
