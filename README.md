K3d-HOW TO - Exercises - nginx

SETUP CLUSTER: (maybe some overkill, but good practice and near production setup(quorum,HA,specific nodes))
> k3d version
k3d version v5.6.0
k3s version v1.27.5-k3s1 (default)

> k3d cluster create --servers 3 --agents 5 k3d-cluster --port '8080:80@loadbalancer'

>  kubectl label nodes k3d-k3d-cluster-agent-1 k3d-k3d-cluster-agent-2 k3d-k3d-cluster-agent-3 node-role.kubernetes.io/worker=""

> kubectl label nodes k3d-k3d-cluster-agent-0 node-role.kubernetes.io/monitor=""

> kubectl label nodes k3d-k3d-cluster-agent-4 node-role.kubernetes.io/infra=""

CREATE K8S RESOURCES:
Which order and why?
How to expose?
CLI:
> kubectl create namespace nginx-ns	
With declarative: (yaml below)
> kubectl apply -f nginx-1-namespace.yml

VERIFY SO THE LB WORKING:
By changing the nginx index for each node/pod
either script this or manually
e.g
Pods:
nginx-deployment-57d84f57dc-7kxtz
nginx-deployment-57d84f57dc-lfsrn
nginx-deployment-57d84f57dc-s4t6m

> kubectl exec --stdin --tty -n nginx-ns pods/nginx-deployment-57d84f57dc-7kxtz -- sh

vim /usr/share/nginx/html/index.html
service nginx reload





nginx-1-namespace.yml
> cat  nginx-1-namespace.yml
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ns


nginx-1-deployment.yml
This will deploy the nginx app
> cat nginx-1-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: nginx-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80


nginx-1-svc.yml
> cat nginx-1-svc.yml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: nginx-ns
spec:
  ports:
  - name: 80-80
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP




nginx-1-ingress.yml
> cat nginx-1-ingress.yml
# apiVersion: networking.k8s.io/v1beta1 # for k3s < v1.19
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  namespace: nginx-ns
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80


Additional information:
https://k3d.io/v5.4.6/
https://k3d.io/v5.4.6/usage/exposing_services/



