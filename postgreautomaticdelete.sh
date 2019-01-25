#!/bin/bash
echo "Welcome to use gaopeng's automatic script,let's begin to delete postgres."
echo "Deploy start!Please wait."
b=9000
echo "Please insert the database number which you want delete!"
read a
d=20000
until [ $a -lt 1 ]
do 
c=$(($a + $b))
e=$(($a + $d))
echo "Now delete data director in kubernates' "$a" pod"
sed -i '/name/s/name: postgre-database.*$/name: postgre-database-'$a'/g'  postgres.yaml
sed -i '/name/s/name: postgre-service.*$/name: postgre-service-'$a'/g'  postgres.yaml
sed -i '/name/s/name: postgre-port.*$/name: postgre-port-'$a'/g'  postgres.yaml
sed -i '/name/s/name: postgre-container.*$/name: postgre-container-'$a'/g'  postgres.yaml
sed -i '/name/s/name: postgre-c-.*$/name: postgre-c-'$a'/g'  postgres.yaml
sed -i '/name/s/name: postgre-v-.*$/name: postgre-v-'$a'/g'  postgres.yaml
sed -i '/path/s/postgre-database.*$/postgre-database-'$a'/g' postgres.yaml
sed -i '/containerPort/s/containerPort:.*$/containerPort: '$c'/g' postgres.yaml
sed -i '/port:/s/port:.*$/port: '$c'/g' postgres.yaml
sed -i '/targetPort:/s/targetPort:.*$/targetPort: '$c'/g' postgres.yaml
sed -i '/nodePort:/s/nodePort:.*$/nodePort: '$e'/g' postgres.yaml
sed -i '/app/s/app:.*$/app: postgres-pv-'$a'/g' postgres.yaml
sed -i 's/port = .*$/port = '$c'/g' postgresql.conf
mkdir -p postgreyaml >/dev/null 2>&1
echo "Now automatic generate the postgres yaml file!"
echo "Generation Completed!"
echo "Now delete pod & service,please wait!"
kubectl delete -f postgres.yaml
echo "Delete pod and service completed!"
echo "Now delete datafile from node!"
ansible kube-node -m shell -a "rm -rf /home/data/postgre-database-"$a""  >/dev/null 2>&1
echo "Delete file completed!"
echo "Finished!Cleaned"
a=$(($a - 1))
done
echo "All databases deleted completed,thank you for using gaopeng's scrpit,if you have any question,just contact me."
