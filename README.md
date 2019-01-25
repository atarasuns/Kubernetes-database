Document
Use shell &amp; ansible &amp; k8s script to create postgresql database with configfile , tables ,schemas and users automatically .
When we want to use one-tenant one-database design , The cost is too high. To reduce the cost , containerization is a good way , but docker cannot afford a stable environment for databases.
So we can use k8s to manage our databases.
This repository will tell you how to create ,initialize , manage multi databases in kubernates automatically.

1.You need a k8s environment and deploy ansible tools. Then upload the postgres yaml file to /etc/ansible/manifests/postgresql/
 postgres yaml:
 apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: postgre-database-1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres-pv-1
    spec:
      containers:
      - name: postgre-container-1
        image: postgres:10.5
        ports:
        - containerPort: 9001
        volumeMounts:
        - mountPath: "/var/lib/postgresql/data"
          name: postgre-c-1
        - mountPath: "/etc/localtime"
          name: host-time
      volumes:
        - name: postgre-c-1
          hostPath: 
            path: /home/data/postgre-database-1
        - name: host-time
          hostPath:
            path: /etc/localtime
---

apiVersion: v1
kind: Service
metadata:
  name: postgre-service-1
  labels:
    app: postgres-pv-1
spec:
  type: NodePort
  ports:
  - name: postgre-port-1
    protocol: "TCP"
    port: 9001
    nodePort: 20001
    targetPort: 9001
------------------------------------------------------------------------------------------------
2.Create file: /etc/ansible/manifests/postgresql
  mkdir -p /etc/ansible/manifests/postgresql
3.Upload your initialize sql file to /etc/ansible/manifests/postgresql and rename to init.sql.
Content of init.sql
For example:
 CREATE DATABASE test;
 ALTER ROLE test WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD '123456';
 CREATE SCHEMA test;
 CREATE TABLE test.t1 (
    id numeric NOT NULL,
    name varchar,
    description character varying(100),
    isactive numeric);
This init.sql file will help you to init your database's objects.
4.Execute the script to create postgresql database.
 When you execute the script , It will create postgresql database in k8s and init database.
 After execute finished , you will database can be connected and also you can find all tables and schemas in it.
The script include three parameters ,the first one is tenant id ,second one is internal port ,last one is out port.
When you execute the script ,you must identity the three parameter.
for example:
/etc/ansible/manifests/postgresql/postgreautogenerate.sh 1 9001 20001
Then it will create a database with id=1 internal-port=9001 outport=20001 , and you can access the database using any of k8s' node ips and outport.
