# Kubernetes Dashboard Access Instructions

## Dashboard URL
Access the Kubernetes Dashboard at:
```
http://31.97.229.208:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## Login Token
Use this token to log into the dashboard:
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IjV2WWVKdkJudzMwN0otcjhMTnNtaTljb1JESGZ4dWtnX2lrSzQ5YjdkSE0ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzU3NTA4MzE4LCJpYXQiOjE3NTc1MDQ3MTgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiZjkxM2I5N2UtMjkzMC00ZTFkLWExNDMtMDFiNjRmZWU4NGZmIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiMDE4ZjZmZDgtMDRjYy00Yzk1LTg4ZjktNWY3ZDBmYmIxZjAxIn19LCJuYmYiOjE3NTc1MDQ3MTgsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.ObLnj5r_52IoAh8lnOAXhWMx86HlBPRkc8Bwt7fvxcesqtDbXsKhckihzWWb1bqROakYD3_kksDFiex2R_3ApCZjSB-o3jsb2H7e9QEqhiVKyUE0ZVvXq5V_cYSrAnsQSJl3JJrx1bxilRR2nRS5xo566ZAvBVz09-c7t1WW2x1Hvq7YosvDIX6amUfTN9m1l1Xm_CtKasA4E73lZCl9JC9H0Jk3R15N7yGKLaz-pOTLILfphyok3ej-mV9oKmVtA0KV3r0rwsgp2bw-IJ3wr2Pf2Bh864RqRa4Y_93C-N9wF6M7QHJ_JTgBO7zjQ-RSZyN06veQKPgp26ek6KYFtA
```

## Steps to Access:
1. Open your web browser
2. Go to the dashboard URL above
3. Select "Token" authentication method
4. Paste the token above
5. Click "Sign In"

## What You'll See:
- **Nodes**: Your cluster nodes status
- **Pods**: All running pods across namespaces
- **Services**: Kubernetes services
- **Deployments**: Application deployments
- **ConfigMaps & Secrets**: Configuration data
- **Events**: Cluster events and logs
- **Resource Usage**: CPU, Memory metrics

## Alternative CLI Commands:
```bash
# View all pods
kubectl get pods -A

# View nodes
kubectl get nodes -o wide

# View services
kubectl get svc -A

# View deployments
kubectl get deployments -A

# View cluster info
kubectl cluster-info

# Generate new token (if needed)
kubectl -n kubernetes-dashboard create token admin-user
```

## Stop Dashboard:
```bash
# Find the proxy process
ps aux | grep "kubectl proxy"
# Kill it
kill <PID>
```
