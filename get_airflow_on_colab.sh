#!/bin/sh

apt-get install -q postgresql
sudo -u postgres /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/data init
sudo -u postgres /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/data -l /var/lib/postgresql/10/logfile start
sudo -u postgres psql -c "CREATE USER root;"
sudo -u postgres psql -c "CREATE DATABASE airflow;"

pip install -q apache-airflow[postgresql,gcp]
airflow initdb

cd /root/airflow && patch -p0 << EOS
--- airflow.cfg	2019-10-17 09:53:26.000000000 +0900
+++ airflow3.cfg	2019-10-17 09:30:03.000000000 +0900
@@ -54,12 +54,12 @@ default_timezone = utc

 # The executor class that airflow should use. Choices include
 # SequentialExecutor, LocalExecutor, CeleryExecutor, DaskExecutor, KubernetesExecutor
-executor = SequentialExecutor
+executor = LocalExecutor

 # The SqlAlchemy connection string to the metadata database.
 # SqlAlchemy supports many different database engine, more information
 # their website
-sql_alchemy_conn = sqlite:////root/airflow/airflow.db
+sql_alchemy_conn = postgres://localhost/airflow

 # The encoding for the databases
 sql_engine_encoding = utf-8
EOS
airflow initdb