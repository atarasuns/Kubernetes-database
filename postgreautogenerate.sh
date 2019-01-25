#!/bin/bash
autocreateDB (){
a=$1
echo "Welcome to use gaopeng's automatic script,let's begin to deploy postgres."
echo "Deploy start!Please wait."
c=$2
e=$3
echo "Step1:Now create data director for postgres-database-$a"
#ansible kube-node -m shell -a "rm -rf /home/data/postgre-database-"$a""  >/dev/null 2>&1
mkdir -p /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"
ansible kube-node -m shell -a "mkdir -p /home/data/postgre-database-"$a""  >/dev/null 2>&1
cat /etc/ansible/manifests/postgresql/postgres.yaml > /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
cat /etc/ansible/manifests/postgresql/postgresql.conf > /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgresql.conf
cat /etc/ansible/manifests/postgresql/pg_hba.conf > /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/pg_hba.conf
sed -i '/name/s/name: postgre-database.*$/name: postgre-database-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/name/s/name: postgre-service.*$/name: postgre-service-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/name/s/name: postgre-port.*$/name: postgre-port-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/name/s/name: postgre-container.*$/name: postgre-container-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/name/s/name: postgre-c-.*$/name: postgre-c-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/name/s/name: postgre-v-.*$/name: postgre-v-'$a'/g'  /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/path/s/postgre-database.*$/postgre-database-'$a'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/containerPort/s/containerPort:.*$/containerPort: '$c'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/port:/s/port:.*$/port: '$c'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/targetPort:/s/targetPort:.*$/targetPort: '$c'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/nodePort:/s/nodePort:.*$/nodePort: '$e'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i '/app/s/app:.*$/app: postgres-pv-'$a'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
sed -i 's/port = .*$/port = '$c'/g' /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgresql.conf
echo "Step2:Now automantic generate the postgres yaml file!"
echo "Generation Completed!"
echo "Step3:Now create pod & service,please wait!"
kubectl create -f /etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgres-"$a".yaml
echo "Pod and service created !"
f=`kubectl get po|grep postgre-database-$a-|awk '{print($3)}'`
until [[ $f = "Running" ]]
do
f=`kubectl get po|grep postgre-database-$a-|awk '{print($3)}'`
done
echo "Now create postgresql config file!"
echo "Creating completed!"
ansible `kubectl get po -o wide|grep postgre-database-$a-|awk '{print($7)}'` -m copy -a "src=/etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/postgresql.conf dest=/home/data/postgre-database-"$a"/" >/dev/null 2>&1
ansible `kubectl get po -o wide|grep postgre-database-$a-|awk '{print($7)}'` -m copy -a "src=/etc/ansible/manifests/postgresql/postgreyaml/posgres-"$a"/pg_hba.conf dest=/home/data/postgre-database-"$a"/" >/dev/null 2>&1
echo "Step4:Now initialize database schema!"
ansible `kubectl get po -o wide|grep postgre-database-$a-|awk '{print($7)}'` -m copy -a "src=/etc/ansible/manifests/postgresql/init.sql dest=/home/data/postgre-database-"$a"/" >/dev/null 2>&1
ansible `kubectl get po -o wide|grep postgre-database-$a-|awk '{print($7)}'` -m copy -a "src=/etc/ansible/manifests/postgresql/init.sh dest=/home/data/postgre-database-"$a"/" >/dev/null 2>&1
echo "Completed!"
echo "Step5:Now optimize postgresql database and restarting database !"
kubectl exec -i `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'` -- chown postgres:postgres /usr/lib/postgresql/10/bin/pg_ctl 
kubectl exec -i `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'` -- chmod +x /var/lib/postgresql/data/init.sh 
kubectl exec -i `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'` -- /var/lib/postgresql/data/init.sh >/dev/null 2>&1 
kubectl exec -i `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'` -- su - postgres -c "/usr/lib/postgresql/10/bin/pg_ctl restart -D /var/lib/postgresql/data -l /var/lib/postgresql/logfile" 
echo "Finished!Enjoying!"
s=`kubectl get po -o wide|grep postgre-database-$a-|awk '{print($6)}'|awk '{print($1)}'`
echo "Step6:now test port connectedness!"
kubectl logs --tail=1 `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'`|grep "accept connections" >/dev/null 2>&1 
until [ $? = 0 ]
do
sleep 0.1
kubectl logs --tail=1 `kubectl get po|grep postgre-database-$a-|awk '{print($1)}'`|grep "accept connections" >/dev/null 2>&1
done
netstat -anp|grep $e >/dev/null 2>&1
if [ $? = 0 ]
then
echo "Test Ok,$e can be connected!"
echo "Success creating database $a,for out the port is $e,for internal the port is $c,and the pod's internal ip is $s"
else
echo "Test faild,please remove the database and recreate it!"
fi
}
time autocreateDB $1 $2 $3
echo "Script executed ended"
