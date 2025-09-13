# Scritps


now i want to learn kuberneets from scractch concetp to installation and every topic bit by bit make a lesson plan

 sleep 10 && kubectl get nodes && echo "--- Pods status ---" && kubectl get pods -A

 kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

 kubectl apply -f Scritps/dashboard-admin.yaml

 kubectl -n kubernetes-dashboard create token admin-user

 kubectl proxy --address='0.0.0.0' --port=8080 --accept-hosts='^.*' &


 http://31.97.229.208:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

 eyJhbGciOiJSUzI1NiIsImtpZCI6IjV2WWVKdkJudzMwN0otcjhMTnNtaTljb1JESGZ4dWtnX2lrSzQ5YjdkSE0ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzU3NTA4MzE4LCJpYXQiOjE3NTc1MDQ3MTgsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiZjkxM2I5N2UtMjkzMC00ZTFkLWExNDMtMDFiNjRmZWU4NGZmIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiMDE4ZjZmZDgtMDRjYy00Yzk1LTg4ZjktNWY3ZDBmYmIxZjAxIn19LCJuYmYiOjE3NTc1MDQ3MTgsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.ObLnj5r_52IoAh8lnOAXhWMx86HlBPRkc8Bwt7fvxcesqtDbXsKhckihzWWb1bqROakYD3_kksDFiex2R_3ApCZjSB-o3jsb2H7e9QEqhiVKyUE0ZVvXq5V_cYSrAnsQSJl3JJrx1bxilRR2nRS5xo566ZAvBVz09-c7t1WW2x1Hvq7YosvDIX6amUfTN9m1l1Xm_CtKasA4E73lZCl9JC9H0Jk3R15N7yGKLaz-pOTLILfphyok3ej-mV9oKmVtA0KV3r0rwsgp2bw-IJ3wr2Pf2Bh864RqRa4Y_93C-N9wF6M7QHJ_JTgBO7zjQ-RSZyN06veQKPgp26ek6KYFtA