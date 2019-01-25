#!/bin/bash
autodeletedb (){
echo "Welcome to use gaopeng's automatic script,let's begin to delete postgres."
echo "Deploy start!Please wait."
a=$1
echo "Now delete data director for kubernates-"$a" pod"
echo "Now automatic generate the postgres yaml file!"
echo "Generation Completed!"
echo "Now delete pod & service,please wait!"
kubectl delete -f /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml 
echo "Delete pod and service completed!"
echo "Now delete datafile from node!"
ansible kube-node -m shell -a "rm -rf /home/data/postgre-database-"$a""  >/dev/null 2>&1
rm -rf /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/ 
echo "Delete file completed!"
echo "Finished!Cleaned"
}
time autodeletedb $1
