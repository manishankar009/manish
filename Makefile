# env vars

# load balancer settings
LB_INTERNAL ?= false
# LB_EXT_IP ?=
# LB_INT_IP ?=
# LB_METRICS_IP ?=
# LB_RESTRICTED_IP ?=

# kube lego : 0 - disable, 1 - enable
KUBE_LEGO = 0

# expose special ports: 0 - disable, 1 - enable set number via vsts pipeline
EXPOSE_PORT ?= 0

ifndef ENV
$(error ENV is not set)
endif

ifndef RESOURCE_GROUP
$(error RESOURCE_GROUP is not set)
endif

ifndef ARM_CLIENT_ID
$(error ARM_CLIENT_ID is not set)
endif

ifndef ARM_CLIENT_SECRET
$(error ARM_CLIENT_SECRET is not set)
endif

#common
# SECRETS=$(shell az keyvault secret list --vault-name $(ENV) | jq  ".[]|.id" | grep secrets- | awk -F "/" '{print $$NF}'| sed 's/\"//g'| tr -d '\n')
KUBE_MASTERS=$(shell kubectl get nodes --selector=kubernetes.io/role=master -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | sed 's/ /,/g')

# # vars from keyvault
# ifeq ($(SECRETS),)
#
define read_kv
  $(shell az keyvault secret show  --vault-name $(1) --name $(2) | jq -r '.value' | tr -d '\n' )
endef
X509=$(strip $(call read_kv,$(ENV),x509))
DELOITTE=$(strip $(call read_kv,$(ENV),deloitte))
PRODUCT=$(strip $(call read_kv,$(ENV),product))
STAGE=$(strip $(call read_kv,$(ENV),stage))
ASPNET_ENV=$(strip $(call read_kv,$(ENV),aspnet-env))
BACKUP_SHARE=$(strip $(call read_kv,$(ENV),backup-share))
BACKUP_SHARE_KEY=$(strip $(call read_kv,$(ENV),backup-share-key))
BACKUP_SHARE_SAS=$(strip $(call read_kv,$(ENV),backup-share-sas))
SUBSCRIPTION_ID=$(strip $(call read_kv,$(ENV),subscriptionid))
TENANT_ID=$(strip $(call read_kv,$(ENV),tenantid))
CLIENT_ID=$(strip $(call read_kv,$(ENV),clientid))
CLIENT_SECRET=$(strip $(call read_kv,$(ENV),clientsecret))
SP2_TENANT_ID=$(strip $(call read_kv,$(ENV),sp2-tenantid))
SP2_CLIENT_ID=$(strip $(call read_kv,$(ENV),sp2-clientid))
OBJECT_ID=$(strip $(call read_kv,$(ENV),objectid))
AUTH_TENANT_ID=$(strip $(call read_kv,$(ENV),auth-tenantid))
AUTH_CLIENT_ID=$(strip $(call read_kv,$(ENV),auth-clientid))
AUTH_CLIENT_SECRET=$(strip $(call read_kv,$(ENV),auth-clientsecret))
DOCKER_REGISTRY=$(strip $(call read_kv,$(ENV),docker-registry))
DOCKER_USERNAME=$(strip $(call read_kv,$(ENV),docker-username))
DOCKER_PASSWORD=$(strip $(call read_kv,$(ENV),docker-password))
MONGO_HOST=$(strip $(call read_kv,$(ENV),mongo-host))
MONGO_USERNAME=$(strip $(call read_kv,$(ENV),mongo-username))
MONGO_PASSWORD=$(strip $(call read_kv,$(ENV),mongo-password))
MONGO_ADMIN_PASSWORD=$(strip $(call read_kv,$(ENV),mongo-admin-password))
MONGO_KEY=$(strip $(call read_kv,$(ENV),mongo-key))
MONGO_STOR_KEY=$(strip $(call read_kv,$(ENV),mongo-store-key))
TAXPLATFORM_CER=$(strip $(call read_kv,$(ENV),taxplatform-cer))
TAXPLATFORM_CLIENT=$(strip $(call read_kv,$(ENV),taxplatform-client))
TAXPLATFORM_URL=$(strip $(call read_kv,$(ENV),taxplatform-url))
SDS_URL=$(strip $(call read_kv,$(ENV),sds-url))
OMNITURE_ACCOUNT=$(strip $(call read_kv,$(ENV),omniture-account))
CA_CERT=$(strip $(call read_kv,$(ENV),ca-crt))
CA_KEY=$(strip $(call read_kv,$(ENV),ca-wopass-key))
MONGO_TRADECHAINWEB_CERT=$(strip $(call read_kv,$(ENV),mongo-TradechainWeb-pem))
MONGO_TRADECHAINWORKPAPER_CERT=$(strip $(call read_kv,$(ENV),mongo-TradechainWorkpaper-pem))
MONGO_ANALYTICS-UI_CERT=$(strip $(call read_kv,$(ENV),mongo-AnalyticsUi-pem))
MONGO_ESPRESSO_CERT=$(strip $(call read_kv,$(ENV),mongo-Espresso-pem))
MONGO_AUDITLOG_CERT=$(strip $(call read_kv,$(ENV),mongo-AuditLog-p12))
MONGO_BUNDLE_CERT=$(strip $(call read_kv,$(ENV),mongo-Bundle-p12))
MONGO_BROKER_CERT=$(strip $(call read_kv,$(ENV),mongo-Broker-p12))
MONGO_CLIENT_CERT=$(strip $(call read_kv,$(ENV),mongo-Client-p12))
MONGO_DATAREQUEST_CERT=$(strip $(call read_kv,$(ENV),mongo-DataRequest-p12))
MONGO_ENGAGEMENT_CERT=$(strip $(call read_kv,$(ENV),mongo-Engagement-p12))
MONGO_INFORMATICA_CERT=$(strip $(call read_kv,$(ENV),mongo-Informatica-p12))
MONGO_NOTIFICATION_CERT=$(strip $(call read_kv,$(ENV),mongo-Notification-p12))
MONGO_PREPORCHESTRATOR_CERT=$(strip $(call read_kv,$(ENV),mongo-PrepOrchestrator-p12))
MONGO_SECURITY_CERT=$(strip $(call read_kv,$(ENV),mongo-Security-p12))
MONGO_STAGING_CERT=$(strip $(call read_kv,$(ENV),mongo-Staging-p12))
MONGO_WORKPAPER_CERT=$(strip $(call read_kv,$(ENV),mongo-WorkPaper-p12))
MONGO_EXPORTER_CERT=$(strip $(call read_kv,$(ENV),mongo-MongoExporter-pem))
MONGO_CORPTAX_CERT=$(strip $(call read_kv,$(ENV),mongo-Corptax-pem))
MONGO_BACKUP_CERT=$(strip $(call read_kv,$(ENV),mongo-Backup-pem))
MONGO_BACKUP_ENCRYPT_CERT=$(strip $(call read_kv,$(ENV),Mongo-encryptor-pem))
RABBIT_SERVER_CERT=$(strip $(call read_kv,$(ENV),rabbit-Server-pem))
RABBIT_SERVER_KEY=$(strip $(call read_kv,$(ENV),rabbit-Server-Key-pem))
RABBIT_ERLANG_COOKIE=$(strip $(call read_kv,$(ENV),rabbit-erlang-cookie))
RABBIT_ADMIN_CERT=$(strip $(call read_kv,$(ENV),rabbit-Admin-pem))
RABBIT_ANALYTICS-UI_CERT=$(strip $(call read_kv,$(ENV),rabbit-Analytics-ui-pem))
RABBIT_CORPTAX_CERT=$(strip $(call read_kv,$(ENV),rabbit-Corptax-pem))
RABBIT_AUDITLOG_CERT=$(strip $(call read_kv,$(ENV),rabbit-Auditlog-p12))
RABBIT_BUNDLE_CERT=$(strip $(call read_kv,$(ENV),rabbit-Bundle-p12))
RABBIT_BROKER_CERT=$(strip $(call read_kv,$(ENV),rabbit-Broker-p12))
RABBIT_CLIENT_CERT=$(strip $(call read_kv,$(ENV),rabbit-Client-p12))
RABBIT_DATAREQUEST_CERT=$(strip $(call read_kv,$(ENV),rabbit-Datarequest-p12))
RABBIT_ENGAGEMENT_CERT=$(strip $(call read_kv,$(ENV),rabbit-Engagement-p12))
RABBIT_INFORMATICA_CERT=$(strip $(call read_kv,$(ENV),rabbit-Informatica-p12))
RABBIT_NOTIFICATION_CERT=$(strip $(call read_kv,$(ENV),rabbit-Notification-p12))
RABBIT_PREPORCHESTRATOR_CERT=$(strip $(call read_kv,$(ENV),rabbit-Prep-orchestrator-p12))
RABBIT_SECURITY_CERT=$(strip $(call read_kv,$(ENV),rabbit-Security-p12))
RABBIT_STAGING_CERT=$(strip $(call read_kv,$(ENV),rabbit-Staging-p12))
RABBIT_WORKPAPER_CERT=$(strip $(call read_kv,$(ENV),rabbit-Workpaper-p12))
RECERTIFICATION=$(strip $(call read_kv,$(ENV),recertification))
REDIS_ANALYTICS-UI_CERT=$(strip $(call read_kv,$(ENV),redis-Analytics-ui-pem))
REDIS_DATAREQUEST_CERT=$(strip $(call read_kv,$(ENV),redis-Datarequest-p12))
REDIS_PREPORCHESTRATOR_CERT=$(strip $(call read_kv,$(ENV),redis-Prep-orchestrator-p12))
REDIS_ENGAGEMENT_CERT=$(strip $(call read_kv,$(ENV),redis-Engagement-p12))
REDIS_INFORMATICA_CERT=$(strip $(call read_kv,$(ENV),redis-Informatica-p12))
REDIS_STAGING_CERT=$(strip $(call read_kv,$(ENV),redis-Staging-p12))
RABBIT_HOST=$(strip $(call read_kv,$(ENV),rabbit-host))
RABBIT_USERNAME=$(strip $(call read_kv,$(ENV),rabbit-username))
RABBIT_PASSWORD=$(strip $(call read_kv,$(ENV),rabbit-password))
REDIS_HOST=$(strip $(call read_kv,$(ENV),redis-host))
REDIS_PASSWORD=$(strip $(call read_kv,$(ENV),redis-password))
MYSQL_HOST=$(strip $(call read_kv,$(ENV),mysql-host))
MYSQL_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-password))
MYSQL_JOBSERVER_USERNAME=$(strip $(call read_kv,$(ENV),mysql-jobserver-username))
MYSQL_JOBSERVER_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-jobserver-password))
JOBSERVER_UI_USERNAME=$(strip $(call read_kv,$(ENV),jobserver-ui-username))
JOBSERVER_UI_PASSWORD=$(strip $(call read_kv,$(ENV),jobserver-ui-password))
MYSQL_INFORMATICA_USERNAME=$(strip $(call read_kv,$(ENV),mysql-informatica-username))
MYSQL_INFORMATICA_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-informatica-password))
MYSQL_CORTEXADMIN_USERNAME=$(strip $(call read_kv,$(ENV),mysql-cortexadmin-username))
MYSQL_CORTEXADMIN_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-cortexadmin-password))
MYSQL_CORTEXBACKUP_USERNAME=$(strip $(call read_kv,$(ENV),mysql-cortexbackup-username))
MYSQL_CORTEXBACKUP_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-cortexbackup-password))
MYSQL_REPL_USERNAME=$(strip $(call read_kv,$(ENV),mysql-repl-username))
MYSQL_REPL_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-repl-password))
MYSQL_MONITORING_USERNAME=$(strip $(call read_kv,$(ENV),mysql-monitoring-username))
MYSQL_MONITORING_PASSWORD=$(strip $(call read_kv,$(ENV),mysql-monitoring-password))
MYSQL_SERVER_CERT=$(strip $(call read_kv,$(ENV),mysql-Server-pem))
MYSQL_JOBSERVER_CERT=$(strip $(call read_kv,$(ENV),mysql-Jobserver-pem))
MSSQL_ENG_HOST=$(strip $(call read_kv,$(ENV),mssql-eng-host))
MSSQL_ENG_POOL=$(strip $(call read_kv,$(ENV),mssql-eng-pool))
MSSQL_ENG_USERNAME=$(strip $(call read_kv,$(ENV),mssql-eng-username))
MSSQL_ENG_PASSWORD=$(strip $(call read_kv,$(ENV),mssql-eng-password))
MSSQL_INT_HOST=$(strip $(call read_kv,$(ENV),mssql-int-host))
MSSQL_INT_POOL=$(strip $(call read_kv,$(ENV),mssql-int-pool))
MSSQL_INT_USERNAME=$(strip $(call read_kv,$(ENV),mssql-int-username))
MSSQL_INT_PASSWORD=$(strip $(call read_kv,$(ENV),mssql-int-password))
MAT_HOST=$(strip $(call read_kv,$(ENV),mat-host))
MAT_DB=$(strip $(call read_kv,$(ENV),mat-db))
MAT_USERNAME=$(strip $(call read_kv,$(ENV),mat-username))
MAT_PASSWORD=$(strip $(call read_kv,$(ENV),mat-password))
SAP_HOST=$(strip $(call read_kv,$(ENV),sap-host))
SAP_USERNAME=$(strip $(call read_kv,$(ENV),sap-username))
SAP_PASSWORD=$(strip $(call read_kv,$(ENV),sap-password))
SPARK_HOST=$(strip $(call read_kv,$(ENV),spark-host))
SPARK_USERNAME=$(strip $(call read_kv,$(ENV),spark-username))
SPARK_PASSWORD=$(strip $(call read_kv,$(ENV),spark-password))
DATALAKE_HOST=$(strip $(call read_kv,$(ENV),datalake-host))
DATALAKE_CLIENT_ID=$(strip $(call read_kv,$(ENV),datalake-clientid))
DATALAKE_CLIENT_SECRET=$(strip $(call read_kv,$(ENV),datalake-clientsecret))
DATALAKE_TENANT=$(strip $(call read_kv,$(ENV),datalake-tenant))
INFORMATICA_SHARE=$(strip $(call read_kv,$(ENV),informatica-share))
INFORMATICA_HOST=$(strip $(call read_kv,$(ENV),informatica-host))
INFORMATICA_APP=$(strip $(call read_kv,$(ENV),informatica-app))
INFORMATICA_PASSWORDKEY=$(strip $(call read_kv,$(ENV),informatica-passwordkey))
BROKER_ENCRYPTIONKEY=$(strip $(call read_kv,$(ENV),broker-encryption-key))
INFORMATICA_USERNAME=$(strip $(call read_kv,$(ENV),informatica-username))
INFORMATICA_PASSWORD=$(strip $(call read_kv,$(ENV),informatica-password))
INFORMATICA_ORG=$(strip $(call read_kv,$(ENV),informatica-org))
MYSQL_INFORMATICA_CLOUD_CERT=$(strip $(call read_kv,$(ENV),mysql-Informatica-cloud-pem))
ENCRYPT_MYSQL_KEY=$(strip $(call read_kv,$(ENV),Mysql-encryptor-pem))
MSSQL_ENCRYPT_KEY=$(strip $(call read_kv,$(ENV),mssql-encrypt-key))
SFTP_PASSWORDKEY=$(strip $(call read_kv,$(ENV),sftp-passwordkey))
TABLEAU_HOST=$(strip $(call read_kv,$(ENV),tableau-host))
TABLEAU_USERNAME=$(strip $(call read_kv,$(ENV),tableau-username))
TABLEAU_PASSWORD=$(strip $(call read_kv,$(ENV),tableau-password))
TABLEAU_CERT=$(strip $(call read_kv,$(ENV),tableau-cert))
TABLEAU_CL_ROLE=$(strip $(call read_kv,$(ENV),tableau-cl-role))
TABLEAU_ENGAGEMENT_ROLE=$(strip $(call read_kv,$(ENV),tableau-engagement-role))
EXUM_ACCOUNT=$(strip $(call read_kv,$(ENV),exum-account))
EXUM_PASSWORD=$(strip $(call read_kv,$(ENV),exum-password))
EXUM_FLAG=$(strip $(call read_kv,$(ENV),exum-flag))
SESSION_SECRET=$(strip $(call read_kv,$(ENV),session-secret))
ARTIFACTORY_URL=$(strip $(call read_kv,$(ENV),artifactory-url))
ARTIFACTORY_USERNAME=$(strip $(call read_kv,$(ENV),artifactory-username))
ARTIFACTORY_PASSWORD=$(strip $(call read_kv,$(ENV),artifactory-password))
DOMAIN=$(strip $(call read_kv,$(ENV),domain))
APP_NAME1=$(strip $(call read_kv,$(ENV),app-name1))
APP_NAME2=$(strip $(call read_kv,$(ENV),app-name2))
APP_NAME3=$(strip $(call read_kv,$(ENV),app-name3))
APP_NAME4=$(strip $(call read_kv,$(ENV),app-name4))
APP_NAME5=$(strip $(call read_kv,$(ENV),app-name5))
APP_NAME6=$(strip $(call read_kv,$(ENV),app-name6))
TLS_CRT=$(strip $(call read_kv,$(ENV),tls-crt))
TLS_KEY=$(strip $(call read_kv,$(ENV),tls-key))
METRICS_TLS_CRT=$(strip $(call read_kv,$(ENV),metrics-tls-crt))
METRICS_TLS_KEY=$(strip $(call read_kv,$(ENV),metrics-tls-key))
RESTRICTED_TLS_CRT=$(strip $(call read_kv,$(ENV),restricted-tls-crt))
RESTRICTED_TLS_KEY=$(strip $(call read_kv,$(ENV),restricted-tls-key))
INT_TLS_CRT=$(strip $(call read_kv,$(ENV),int-tls-crt))
INT_TLS_KEY=$(strip $(call read_kv,$(ENV),int-tls-key))
OMS_WSID=$(strip $(call read_kv,$(ENV),oms-wsid))
OMS_KEY=$(strip $(call read_kv,$(ENV),oms-key))
APPINSIGHTS_ANALYTICS_UI=$(strip $(call read_kv,$(ENV),appinsights-analytics-ui))
APPINSIGHTS_ANALYTICS_WORKER=$(strip $(call read_kv,$(ENV),appinsights-analytics-worker))
APPINSIGHTS_AUDITLOG=$(strip $(call read_kv,$(ENV),appinsights-auditlog))
APPINSIGHTS_BUNDLE=$(strip $(call read_kv,$(ENV),appinsights-bundle))
APPINSIGHTS_CLIENT=$(strip $(call read_kv,$(ENV),appinsights-client))
APPINSIGHTS_DATAREQUEST=$(strip $(call read_kv,$(ENV),appinsights-datarequest))
APPINSIGHTS_ENGAGEMENT=$(strip $(call read_kv,$(ENV),appinsights-engagement))
APPINSIGHTS_EXTRACTION_UI=$(strip $(call read_kv,$(ENV),appinsights-extraction-ui))
APPINSIGHTS_INFORMATICA=$(strip $(call read_kv,$(ENV),appinsights-informatica))
APPINSIGHTS_NOTIFICATION=$(strip $(call read_kv,$(ENV),appinsights-notification))
APPINSIGHTS_PREP_ORCHESTRATOR=$(strip $(call read_kv,$(ENV),appinsights-prep-orchestrator))
APPINSIGHTS_SECURITY=$(strip $(call read_kv,$(ENV),appinsights-security))
APPINSIGHTS_SFTP=$(strip $(call read_kv,$(ENV),appinsights-sftp))
APPINSIGHTS_STAGING=$(strip $(call read_kv,$(ENV),appinsights-staging))
APPINSIGHTS_WORKPAPER=$(strip $(call read_kv,$(ENV),appinsights-workpaper))
APPINSIGHTS_CORPTAX=$(strip $(call read_kv,$(ENV),appinsights-corptax))
APPINSIGHTS_JOBSERVER=$(strip $(call read_kv,$(ENV),appinsights-jobserver))
APPINSIGHTS_SCHEDULER=$(strip $(call read_kv,$(ENV),appinsights-scheduler))
APPINSIGHTS_BROKER=$(strip $(call read_kv,$(ENV),appinsights-broker))
GCSPREAD11_LIC_KEY_CORPTAX=$(strip $(call read_kv,$(ENV),gcsspreadkey-corptax))
NOTIFY_EMAIL=$(strip $(call read_kv,$(ENV),notify-email))
AUTH_ING_TENANT_ID=$(strip $(call read_kv,$(ENV),k8s-auth-tenant-id))
AUTH_ING_APP_ID=$(strip $(call read_kv,$(ENV),ingress-appid))
FILEDELETIONDAYS=$(strip $(call read_kv,$(ENV),filedeletiondays))
AUTH_ING_APP_SECRET=$(strip $(call read_kv,$(ENV),ingress-app-secret))
# Certificates

# Init
CERT_SVC1_CRT=$(strip $(call read_kv,$(ENV),cert-svc1-crt))
CERT_SVC1_P12=$(strip $(call read_kv,$(ENV),cert-svc1-p12))
CERT_SVC1_PASSWORD=$(strip $(call read_kv,$(ENV),cert-svc1-password))

# Main
CERT_SPN_PASSWORD=$(strip $(call read_kv,$(ENV),cert-spn-password))

# KEK
CERT_SVC2_PASSWORD=$(strip $(call read_kv,$(ENV),cert-svc2-password))

# SMTP_USERNAME=$(strip $(call read_kv,$(ENV),smtp-username))
# SMTP_PASSWORD=$(strip $(call read_kv,$(ENV),smtp-password))
# SMTP_HOST=$(strip $(call read_kv,$(ENV),smtp-host))
# SMTP_PORT=$(strip $(call read_kv,$(ENV),smtp-port))

ifndef PRODUCT
$(error PRODUCT is not set, product keyvault secret)
endif

ifndef STAGE
$(error STAGE is not set, stage keyvault secret)
endif

ifndef ASPNET_ENV
$(error ASPNET_ENV is not set, aspnet-env keyvault secret)
endif

ifndef BACKUP_SHARE
$(error BACKUP_SHARE is not set, backup-share keyvault secret)
endif

ifndef BACKUP_SHARE_KEY
$(error BACKUP_SHARE_KEY is not set, backup-share-key keyvault secret)
endif

ifndef SUBSCRIPTION_ID
$(error SUBSCRIPTION_ID is not set, subscriptionid keyvault secret)
endif

ifndef TENANT_ID
$(error TENANT_ID is not set, tenantid keyvault secret)
endif

ifndef CLIENT_ID
$(error CLIENT_ID is not set, clientid keyvault secret)
endif

ifndef CLIENT_SECRET
$(error CLIENT_SECRET is not set, clientsecret keyvault secret)
endif

ifndef SP2_TENANT_ID
$(error SP2_TENANT_ID is not set, sp2-tenantid keyvault secret)
endif

ifndef SP2_CLIENT_ID
$(error SP2_CLIENT_ID is not set, sp2-clientid keyvault secret)
endif

ifndef OBJECT_ID
$(error OBJECT_ID is not set, objectid keyvault secret)
endif

ifndef AUTH_TENANT_ID
$(error AUTH_TENANT_ID is not set, auth-tenantid keyvault secret)
endif

ifndef AUTH_CLIENT_ID
$(error AUTH_CLIENT_ID is not set, auth-clientid keyvault secret)
endif

ifndef AUTH_CLIENT_SECRET
$(error AUTH_CLIENT_SECRET is not set, auth-clientsecret keyvault secret)
endif

ifndef DOCKER_REGISTRY
$(error DOCKER_REGISTRY is not set, docker-registry keyvault secret)
endif

ifndef DOCKER_USERNAME
$(error DOCKER_USERNAME is not set, docker-username keyvault secret)
endif

ifndef DOCKER_PASSWORD
$(error DOCKER_PASSWORD is not set, docker-password keyvault secret)
endif

ifndef MONGO_HOST
$(error MONGO_HOST is not set, mongo-host keyvault secret)
endif

ifndef MONGO_USERNAME
$(error MONGO_USERNAME is not set, mongo-username keyvault secret)
endif

ifndef MONGO_PASSWORD
$(error MONGO_PASSWORD is not set, mongo-password keyvault secret)
endif

ifndef MONGO_ADMIN_PASSWORD
$(error MONGO_ADMIN_PASSWORD is not set, mongo-password keyvault secret)
endif


ifndef MONGO_KEY
$(error MONGO_KEY is not set, mongo-key keyvault secret)
endif

ifndef RABBIT_SERVER_CERT
$(error RABBIT_SERVER_CERT is not set, rabbit-Server-pem keyvault secret)
endif

ifndef RABBIT_SERVER_KEY
$(error RABBIT_SERVER_KEY is not set, rabbit-Server-key-pem keyvault secret)
endif

ifndef RABBIT_ERLANG_COOKIE
$(error RABBIT_ERLANG_COOKIE is not set, rabbit-erlang-cookie keyvault secret)
endif

ifndef RABBIT_HOST
$(error RABBIT_HOST is not set, rabbit-host keyvault secret)
endif

ifndef RABBIT_USERNAME
$(error RABBIT_USERNAME is not set, rabbit-username keyvault secret)
endif

ifndef RABBIT_PASSWORD
$(error RABBIT_PASSWORD is not set, rabbit-password keyvault secret)
endif

ifndef REDIS_HOST
$(error REDIS_HOST is not set, redis-host keyvault secret)
endif

ifndef REDIS_PASSWORD
$(error REDIS_PASSWORD is not set, redis-password keyvault secret)
endif

ifndef ENCRYPT_MYSQL_KEY
$(error ENCRYPT_MYSQL_KEY is not set, encrypt-Mysql-encryptor-pem keyvault secret)
endif

ifndef MYSQL_HOST
$(error MYSQL_HOST is not set, mysql-host keyvault secret)
endif

ifndef MYSQL_PASSWORD
$(error MYSQL_PASSWORD is not set, mysql-password keyvault secret)
endif

ifndef JOBSERVER_UI_USERNAME
$(error JOBSERVER_UI_USERNAME is not set, jobserver-ui-username keyvault secret)
endif

ifndef JOBSERVER_UI_PASSWORD
$(error JOBSERVER_UI_PASSWORD is not set, jobserver-ui-password keyvault secret)
endif

ifndef MYSQL_JOBSERVER_USERNAME
$(error MYSQL_JOBSERVER_USERNAME is not set, mysql-jobserver-username keyvault secret)
endif

ifndef MYSQL_JOBSERVER_PASSWORD
$(error MYSQL_JOBSERVER_PASSWORD is not set, mysql-jobserver-password keyvault secret)
endif

ifndef MYSQL_INFORMATICA_USERNAME
$(error MYSQL_INFORMATICA_USERNAME is not set, mysql-informatica-username keyvault secret)
endif

ifndef MYSQL_INFORMATICA_PASSWORD
$(error MYSQL_INFORMATICA_PASSWORD is not set, mysql-informatica-password keyvault secret)
endif

ifndef MYSQL_REPL_USERNAME
$(error MYSQL_REPL_USERNAME is not set, mysql-repl-username keyvault secret)
endif

ifndef MYSQL_REPL_PASSWORD
$(error MYSQL_REPL_PASSWORD is not set, mysql-repl-password keyvault secret)
endif

ifndef MYSQL_MONITORING_USERNAME
$(error MYSQL_MONITORING_USERNAME is not set, mysql-monitoring-username keyvault secret)
endif

ifndef MYSQL_MONITORING_PASSWORD
$(error MYSQL_MONITORING_PASSWORD is not set, mysql-monitoring-password keyvault secret)
endif

ifndef MYSQL_CORTEXADMIN_USERNAME
$(error MYSQL_CORTEXADMIN_USERNAME is not set, mysql-cortexadmin-username keyvault secret)
endif

ifndef MYSQL_CORTEXADMIN_PASSWORD
$(error MYSQL_CORTEXADMIN_PASSWORD is not set, mysql-cortexadmin-password keyvault secret)
endif

ifndef MYSQL_CORTEXBACKUP_USERNAME
$(error MYSQL_CORTEXBACKUP_USERNAME is not set, mysql-cortexbackup-username keyvault secret)
endif

ifndef MYSQL_CORTEXBACKUP_PASSWORD
$(error MYSQL_CORTEXBACKUP_PASSWORD is not set, mysql-cortexbackup-password keyvault secret)
endif

ifndef MSSQL_ENG_HOST
$(error MSSQL_ENG_HOST is not set, mssql-eng-host keyvault secret)
endif

ifndef MSSQL_ENG_POOL
$(error MSSQL_ENG_POOL is not set, mssql-eng-pool keyvault secret)
endif

ifndef MSSQL_ENG_USERNAME
$(error MSSQL_ENG_USERNAME is not set, mssql-eng-username keyvault secret)
endif

ifndef MSSQL_ENG_PASSWORD
$(error MSSQL_ENG_PASSWORD is not set, mssql-eng-password keyvault secret)
endif

ifndef MSSQL_INT_HOST
$(error MSSQL_INT_HOST is not set, mssql-int-host keyvault secret)
endif

ifndef MSSQL_INT_POOL
$(error MSSQL_INT_POOL is not set, mssql-int-pool keyvault secret)
endif

ifndef MSSQL_INT_USERNAME
$(error MSSQL_INT_USERNAME is not set, mssql-int-username keyvault secret)
endif

ifndef MSSQL_INT_PASSWORD
$(error MSSQL_INT_PASSWORD is not set, mssql-int-password keyvault secret)
endif

ifndef MAT_HOST
$(error MAT_HOST is not set, mat-host keyvault secret)
endif

ifndef MAT_DB
$(error MAT_DB is not set, mat-db keyvault secret)
endif

ifndef MAT_USERNAME
$(error MAT_USERNAME is not set, mat-username keyvault secret)
endif

ifndef MAT_PASSWORD
$(error MAT_PASSWORD is not set, mat-password keyvault secret)
endif

ifndef SAP_HOST
$(error SAP_HOST is not set, sap-host keyvault secret)
endif

ifndef SAP_USERNAME
$(error SAP_USERNAME is not set, sap-username keyvault secret)
endif

ifndef SAP_PASSWORD
$(error SAP_PASSWORD is not set, sap-password keyvault secret)
endif

ifndef SPARK_HOST
$(error SPARK_HOST is not set, spark-host keyvault secret)
endif

ifndef SPARK_USERNAME
$(error SPARK_USERNAME is not set, spark-username keyvault secret)
endif

ifndef SPARK_PASSWORD
$(error SPARK_PASSWORD is not set, spark-password keyvault secret)
endif

ifndef DATALAKE_HOST
$(error DATALAKE_HOST is not set, datalake-host keyvault secret)
endif

ifndef DATALAKE_CLIENT_ID
$(error DATALAKE_CLIENT_ID is not set, datalake-clientid keyvault secret)
endif

ifndef DATALAKE_CLIENT_SECRET
$(error DATALAKE_CLIENT_SECRET is not set, datalake-clientsecret keyvault secret)
endif

ifndef DATALAKE_TENANT
$(error DATALAKE_TENANT is not set, datalake-tenant keyvault secret)
endif

ifndef INFORMATICA_HOST
$(error INFORMATICA_HOST is not set, informatica-host keyvault secret)
endif

ifndef INFORMATICA_APP
$(error INFORMATICA_APP is not set, informatica-app keyvault secret)
endif

ifndef INFORMATICA_PASSWORDKEY
$(error INFORMATICA_PASSWORDKEY is not set, informatica-passwordkey keyvault secret)
endif

ifndef INFORMATICA_USERNAME
$(error INFORMATICA_USERNAME is not set, informatica-username keyvault secret)
endif

ifndef INFORMATICA_PASSWORD
$(error INFORMATICA_PASSWORD is not set, informatica-password keyvault secret)
endif

ifndef INFORMATICA_ORG
$(error INFORMATICA_ORG is not set, informatica-org keyvault secret)
endif

ifndef TABLEAU_HOST
$(error TABLEAU_HOST is not set, tableau-host keyvault secret)
endif

ifndef TABLEAU_USERNAME
$(error TABLEAU_USERNAME is not set, tableau-username keyvault secret)
endif

ifndef TABLEAU_PASSWORD
$(error TABLEAU_PASSWORD is not set, tableau-password keyvault secret)
endif

ifndef TABLEAU_CERT
$(error TABLEAU_CERT is not set, tableau-cert keyvault secret)
endif

ifndef EXUM_ACCOUNT
$(error EXUM_ACCOUNT is not set, exum-account keyvault secret)
endif

ifndef EXUM_PASSWORD
$(error EXUM_PASSWORD is not set, exum-password keyvault secret)
endif

ifndef SESSION_SECRET
$(error SESSION_SECRET is not set, session-secret keyvault secret)
endif

ifndef ARTIFACTORY_URL
$(error ARTIFACTORY_URL is not set, artifactory-url keyvault secret)
endif

ifndef ARTIFACTORY_USERNAME
$(error ARTIFACTORY_USERNAME is not set, artifactory-username keyvault secret)
endif

ifndef ARTIFACTORY_PASSWORD
$(error ARTIFACTORY_PASSWORD is not set, artifactory-password keyvault secret)
endif

ifndef DOMAIN
$(error DOMAIN is not set, domain keyvault secret)
endif

ifndef APP_NAME1
$(error APP_NAME1 is not set, app-name1 keyvault secret)
endif

ifndef APP_NAME2
$(error APP_NAME2 is not set, app-name2 keyvault secret)
endif

ifndef APP_NAME3
$(error APP_NAME3 is not set, app-name3 keyvault secret)
endif

ifndef APP_NAME4
$(error APP_NAME4 is not set, app-name4 keyvault secret)
endif

ifndef APP_NAME5
$(error APP_NAME5 is not set, app-name5 keyvault secret)
endif

ifndef APP_NAME6
$(error APP_NAME6 is not set, app-name6 keyvault secret)
endif

ifndef TAXPLATFORM_URL
$(error TAXPLATFORM_URL is not set, taxplatform-url keyvault secret)
endif

ifndef TAXPLATFORM_CLIENT
$(error TAXPLATFORM_CLIENT is not set, taxplatform-client keyvault secret)
endif

ifndef TAXPLATFORM_CER
$(error TAXPLATFORM_CER is not set, taxplatform-cer keyvault secret)
endif

ifndef SDS_URL
$(error SDS_URL is not set, sds-url keyvault secret)
endif

ifndef OMNITURE_ACCOUNT
$(error OMNITURE_ACCOUNT is not set, omniture-account keyvault secret)
endif

ifndef TLS_CRT
$(error TLS_CRT is not set, tls-crt keyvault secret)
endif

ifndef TLS_KEY
$(error TLS_KEY is not set, tls-key keyvault secret)
endif

ifndef RESTRICTED_TLS_CRT
$(error RESTRICTED_TLS_CRT is not set, restricted-tls-crt keyvault secret)
endif

ifndef RESTRICTED_TLS_KEY
$(error RESTRICTED_TLS_KEY is not set, restricted-tls-key keyvault secret)
endif

ifndef INT_TLS_CRT
$(error INT_TLS_CRT is not set, int-tls-crt keyvault secret)
endif

ifndef INT_TLS_KEY
$(error INT_TLS_KEY is not set, int-tls-key keyvault secret)
endif

ifndef MSSQL_ENCRYPT_KEY
$(error MSSQL_ENCRYPT_KEY is not set, mssql-encrypt-key keyvault secret)
endif
# ifndef SMTP_USERNAME
# $(error SMTP_USERNAME is not set, smtp-username keyvault secret)
# endif
#
# ifndef SMTP_PASSWORD
# $(error SMTP_PASSWORD is not set, smtp-password keyvault secret)
# endif
#
# ifndef SMTP_HOST
# $(error SMTP_HOST is not set, smtp-host keyvault secret)
# endif
#
# ifndef SMTP_PORT
# $(error SMTP_PORT is not set, smtp-port keyvault secret)
# endif

ifndef CERT_SVC1_CRT
$(error CERT_SVC1_CRT is not set, cert-svc1-crt keyvault secret)
endif

ifndef CERT_SVC1_P12
$(error CERT_SVC1_P12 is not set, cert-svc1-p12 keyvault secret)
endif

ifndef CERT_SVC1_PASSWORD
$(error CERT_SVC1_PASSWORD is not set, cert-svc1-password keyvault secret)
endif

ifndef CERT_SPN_PASSWORD
$(error CERT_SPN_PASSWORD is not set, cert-spn-password keyvault secret)
endif

ifndef CERT_SVC2_PASSWORD
$(error CERT_SVC2_PASSWORD is not set, cert-svc2-password keyvault secret)
endif

.PHONY: init tiller-patch ingress secrets.yaml ingress-expose kube-lego logging monitoring install
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	HELM_SRC='https://jfrog.bintray.com/helm//2.7.2-j/linux-amd64/helm'
endif
ifeq ($(UNAME_S),Darwin)
	HELM_SRC='https://jfrog.bintray.com/helm//2.7.2-j/mac-386/helm'
endif

login:
	rm -rf ~/.azure # cleanup needed if we change client_id, cleint_secret
	az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant deloitte.onmicrosoft.com

kubeconfig:
	rm -rf ~/.kube
	mkdir ~/.kube
	az keyvault secret show --vault-name $(ENV) --name kubeconfig | jq -r '.value' | base64 --decode > ~/.kube/config

init:
	echo $(HELM_SRC)
	$(shell curl -L $(HELM_SRC) -o /usr/local/bin/helm-artifactory)
	$(shell chmod +x /usr/local/bin/helm-artifactory)
	rm -rf ~/.helm
	# -kubectl delete deploy tiller-deploy -n kube-system
	kubectl apply -f rbac-roles/globaladmin-clusterrolebinding.yaml
	kubectl apply -f rbac-roles/readonlyrole.yaml
	helm init --override "spec.template.spec.containers[0].resources.limits.cpu"="2" --override "spec.template.spec.containers[0].resources.limits.memory"="1Gi" --override "spec.template.spec.containers[0].readinessProbe.timeoutSeconds"="30" --upgrade
	kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
	# helm init --kube-context=$(ENV); kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system --context=$(ENV)
	/usr/local/bin/helm-artifactory repo add stable https://kubernetes-charts.storage.googleapis.com/
	/usr/local/bin/helm-artifactory repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
	/usr/local/bin/helm-artifactory repo add influx https://influx-charts.storage.googleapis.com
	#helm repo add cortex https://deloittehelm.blob.core.windows.net/helm/
	@/usr/local/bin/helm-artifactory repo add cortex https://artifactory.usinnovation.io/artifactory/helm $(DOCKER_USERNAME) $(DOCKER_PASSWORD)
	/usr/local/bin/helm-artifactory repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
	helm plugin install https://github.com/technosophos/helm-template --version 2.5.1
	# remove before generate
	rm -rf secrets.yaml nginx-ingress-ext.yaml nginx-ingress-ext-expose-port.yaml nginx-ingress-int.yaml nginx-ingress-metrics.yaml nginx-ingress-restricted.yaml
ifeq ($(KUBE_LEGO),1)
kube-lego:
	/usr/local/bin/helm-artifactory upgrade kube-lego stable/kube-lego --install -f kube-lego.yaml
else
kube-lego:
	@echo 'kube-lego is disabled'
endif

tiller-patch:
	kubectl apply -f tiller-patch.yaml

nginx-ingress-ext.yaml:
	$(shell sed 's/__LB_IP__/$(LB_EXT_IP)/g' nginx-ingress-ext.yaml.template | sed 's/__LB_TYPE__/$(LB_INTERNAL)/g' | sed 's/__ENV__/$(ENV)/g' > nginx-ingress-ext.yaml)

nginx-ingress-ext-expose-port.yaml:
	$(shell sed 's/__LB_IP__/$(LB_EXT_IP)/g' nginx-ingress-ext-expose-port.yaml.template | sed 's/__LB_TYPE__/$(LB_INTERNAL)/g' | sed 's/__ENV__/$(ENV)/g' > nginx-ingress-ext-expose-port.yaml)

nginx-ingress-int.yaml:
	$(shell sed 's/__LB_IP__/$(LB_INT_IP)/g' nginx-ingress-int.yaml.template | sed 's/__LB_TYPE__/$(LB_INTERNAL)/g' > nginx-ingress-int.yaml)

nginx-ingress-metrics.yaml:
	$(shell sed 's/__LB_IP__/$(LB_METRICS_IP)/g' nginx-ingress-metrics.yaml.template | sed 's/__LB_TYPE__/$(LB_INTERNAL)/g' > nginx-ingress-metrics.yaml)

nginx-ingress-restricted.yaml:
	$(shell sed 's/__LB_IP__/$(LB_RESTRICTED_IP)/g' nginx-ingress-restricted.yaml.template | sed 's/__LB_TYPE__/$(LB_INTERNAL)/g' > nginx-ingress-restricted.yaml)

telegraf-s.yaml:
	$(shell sed 's/_MONGO_PASSWORD_/$(MONGO_PASSWORD)/g' telegraf-s.yaml.template | \
	 sed 's/_RABBIT_PASSWORD_/$(RABBIT_PASSWORD)/g' | \
	 sed 's/_REDIS_PASSWORD_/$(REDIS_PASSWORD)/g'| \
	 sed 's/_MYSQL_PASSWORD_/$(MYSQL_PASSWORD)/g' > telegraf-s.yaml)

ifeq ($(KUBE_LEGO),1)
ingress: nginx-ingress-ext.yaml nginx-ingress-int.yaml nginx-ingress-metrics.yaml nginx-ingress-restricted.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-ext stable/nginx-ingress --install -f nginx-ingress-ext.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-int stable/nginx-ingress --install -f nginx-ingress-int.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-metrics stable/nginx-ingress --install -f nginx-ingress-metrics.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-restricted stable/nginx-ingress --install -f nginx-ingress-restricted.yaml
else
ingress: nginx-ingress-ext.yaml nginx-ingress-int.yaml nginx-ingress-metrics.yaml nginx-ingress-restricted.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-ext stable/nginx-ingress --install -f nginx-ingress-ext.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-int stable/nginx-ingress --install -f nginx-ingress-int.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-metrics stable/nginx-ingress --install -f nginx-ingress-metrics.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-restricted stable/nginx-ingress --install -f nginx-ingress-restricted.yaml
	cp tls-secret.yaml.template templates/tls-secret.yaml
endif

ifeq ($(EXPOSE_PORT),1)
ingress-expose: nginx-ingress-ext-expose-port.yaml
	/usr/local/bin/helm-artifactory upgrade --install ingress-ext stable/nginx-ingress --install -f nginx-ingress-ext-expose-port.yaml
else
ingress-expose:
	@echo 'expose port is disabled'
endif

logging:
	#https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/auth
	#metrics/cortex.1
	-kubectl create secret generic basic-auth --from-file=auth --namespace metrics
	kubectl apply -f metrics-namespace.yaml
	/usr/local/bin/helm-artifactory upgrade elasticsearch cortex/elasticsearch --install -f elastic.yaml --set nodeSelector.pool=main --namespace metrics
	/usr/local/bin/helm-artifactory upgrade fluentd cortex/fluentd --install --namespace metrics
monitoring: telegraf-s.yaml
	/usr/local/bin/helm-artifactory upgrade --install prometheus-operator coreos/prometheus-operator --namespace metrics
	/usr/local/bin/helm-artifactory upgrade --install kube-prometheus coreos/kube-prometheus --set rbacEnable=true -f prometheus.yaml --namespace metrics --set exporter-kube-etcd.endpoints="{$(KUBE_MASTERS)}"
	/usr/local/bin/helm-artifactory upgrade --install kube-prometheus-exporter-mongodb cortex/kube-prometheus-exporter-mongodb --namespace metrics -f secrets.yaml
	/usr/local/bin/helm-artifactory upgrade --install kube-prometheus-exporter-rabbit cortex/kube-prometheus-exporter-rabbit --namespace metrics -f secrets.yaml
	-/usr/local/bin/helm-artifactory upgrade --install grafana cortex/grafana --namespace metrics -f grafana.yaml
	/usr/local/bin/helm-artifactory upgrade influxdb stable/influxdb --install -f influxdb.yaml --set nodeSelector.pool=main --namespace metrics
	/usr/local/bin/helm-artifactory upgrade telegraf-s cortex/telegraf-s --install -f telegraf-s.yaml --namespace metrics
	# kubectl apply -f ./Istio/servicegraph.yaml
	# kubectl apply -f ./Istio/zipkin.yaml
	# kubectl apply -f ./Istio/istio.yaml
	-kubectl delete -f ./Istio/istio-initializer.yaml
	# kubectl apply -f ./Istio/istio-initializer.yaml
	/usr/local/bin/helm-artifactory upgrade --install omsagent --set omsagent.secret.wsid=$(OMS_WSID),omsagent.secret.key=$(OMS_KEY) stable/msoms --namespace metrics
	/usr/local/bin/helm-artifactory upgrade oms-exporter cortex/oms-exporter --install --namespace metrics --set omsagent.secret.wsid=$(OMS_WSID)

# ifeq ($(SECRETS),)
secrets.yaml:
	$(eval DOCKERCONFIGJSON_WITHSPACE := $(shell printf '{"auths":{"%s":{"auth":"%s"}}}' $(DOCKER_REGISTRY) $(shell printf '%s:%s' $(DOCKER_USERNAME) $(DOCKER_PASSWORD) | base64) | base64))
	$(eval DOCKERCONFIGJSON := $(shell echo $(DOCKERCONFIGJSON_WITHSPACE) | sed 's/ //g')) # HACK: remove white space, probably bug in bash
	@/usr/local/bin/helm-artifactory template . -x /dev/null --debug \
	--set tls_crt=$(TLS_CRT) \
	--set tls_key=$(TLS_KEY) \
	--set metrics_tls_crt=$(METRICS_TLS_CRT) \
	--set metrics_tls_key=$(METRICS_TLS_KEY) \
	--set restricted_tls_crt=$(RESTRICTED_TLS_CRT) \
	--set restricted_tls_key=$(RESTRICTED_TLS_KEY) \
	--set int_tls_crt=$(INT_TLS_CRT) \
	--set int_tls_key=$(INT_TLS_KEY) \
	--set cortex.env=$(ENV) \
	--set cortex.stage=$(STAGE) \
	--set cortex.aspnetcore_environment=$(ASPNET_ENV) \
	--set cortex.session_secret=$(SESSION_SECRET) \
	--set cortex.backup_share=$(BACKUP_SHARE) \
	--set cortex.backup_key=$(BACKUP_SHARE_KEY) \
	--set cortex.backup_sas=$(BACKUP_SHARE_SAS) \
	--set cortex.domain=$(DOMAIN) \
	--set cortex.app_name1=$(APP_NAME1) \
	--set cortex.app_name2=$(APP_NAME2) \
	--set cortex.app_name3=$(APP_NAME3) \
	--set cortex.app_name4=$(APP_NAME4) \
	--set cortex.app_name5=$(APP_NAME5) \
	--set cortex.app_name6=$(APP_NAME6) \
	--set cortex.artifactory.url=$(ARTIFACTORY_URL) \
	--set cortex.artifactory.username=$(ARTIFACTORY_USERNAME) \
	--set cortex.artifactory.password=$(ARTIFACTORY_PASSWORD) \
	--set cortex.subscription_id=$(SUBSCRIPTION_ID) \
	--set cortex.resource_group=$(RESOURCE_GROUP) \
	--set cortex.svc1.tenant=$(TENANT_ID) \
	--set cortex.svc1.client_id=$(CLIENT_ID) \
	--set cortex.svc1.client_secret=$(CLIENT_SECRET) \
	--set cortex.svc1.crt=$(CERT_SVC1_CRT) \
	--set cortex.svc1.p12=$(CERT_SVC1_P12) \
	--set cortex.svc1.cert_password="$(CERT_SVC1_PASSWORD)" \
	--set cortex.svc2.tenant=$(SP2_TENANT_ID) \
	--set cortex.svc2.client_id=$(SP2_CLIENT_ID) \
	--set cortex.svc2.cert_password="$(CERT_SVC2_PASSWORD)" \
	--set cortex.auth.tenant=$(AUTH_TENANT_ID) \
	--set cortex.auth.client_id=$(AUTH_CLIENT_ID) \
	--set cortex.auth.client_secret=$(AUTH_CLIENT_SECRET) \
	--set cortex.auth.cert_password="$(CERT_SPN_PASSWORD)" \
	--set dockerconfigjson=$(DOCKERCONFIGJSON) \
	--set cortex.x509=\"$(X509)\" \
	--set cortex.deloitte=\"$(DELOITTE)\" \
	--set cortex.internal_balancer_ip=$(LB_INT_IP) \
	--set cortex.external_balancer_ip=$(LB_EXT_IP) \
	--set cortex.metrics_balancer_ip=$(LB_METRICS_IP) \
	--set cortex.restricted_balancer_ip=$(LB_RESTRICTED_IP) \
	--set cortex.taxplatform=$(TAXPLATFORM_CER) \
	--set cortex.taxplatform_url=$(TAXPLATFORM_URL) \
	--set cortex.taxplatform_client=$(TAXPLATFORM_CLIENT) \
	--set cortex.sds_url=$(SDS_URL) \
	--set cortex.omniture_account=$(OMNITURE_ACCOUNT) \
	--set cortex.ca=$(CA_CERT) \
	--set cortex.ca_key=$(CA_KEY) \
	--set cortex.docker.registry=$(DOCKER_REGISTRY) \
	--set cortex.mssql_encrypt.key=$(MSSQL_ENCRYPT_KEY) \
	--set cortex.mongo.host="$(MONGO_HOST)" \
	--set cortex.mongo.username=$(MONGO_USERNAME) \
	--set cortex.mongo.password=$(MONGO_PASSWORD) \
	--set cortex.mongo.admin_password=$(MONGO_ADMIN_PASSWORD) \
	--set cortex.mongo.auth.key=$(MONGO_KEY) \
	--set cortex.mongo.stor.encrypt.key=$(MONGO_STOR_KEY) \
	--set cortex.mongo.cert.tradechain_web=$(MONGO_TRADECHAINWEB_CERT) \
	--set cortex.mongo.cert.tradechain_workpaper=$(MONGO_TRADECHAINWORKPAPER_CERT) \
	--set cortex.mongo.cert.analytics_ui=$(MONGO_ANALYTICS-UI_CERT) \
	--set cortex.mongo.cert.espresso=$(MONGO_ESPRESSO_CERT) \
	--set cortex.mongo.cert.auditlog=$(MONGO_AUDITLOG_CERT) \
	--set cortex.mongo.cert.bundle=$(MONGO_BUNDLE_CERT) \
	--set cortex.mongo.cert.broker=$(MONGO_BROKER_CERT) \
	--set cortex.mongo.cert.client=$(MONGO_CLIENT_CERT) \
	--set cortex.mongo.cert.datarequest=$(MONGO_DATAREQUEST_CERT) \
	--set cortex.mongo.cert.engagement=$(MONGO_ENGAGEMENT_CERT) \
	--set cortex.mongo.cert.informatica=$(MONGO_INFORMATICA_CERT) \
	--set cortex.mongo.cert.notification=$(MONGO_NOTIFICATION_CERT) \
	--set cortex.mongo.cert.prep_orchestrator=$(MONGO_PREPORCHESTRATOR_CERT) \
	--set cortex.mongo.cert.security=$(MONGO_SECURITY_CERT) \
	--set cortex.mongo.cert.staging=$(MONGO_STAGING_CERT) \
	--set cortex.mongo.cert.workpaper=$(MONGO_WORKPAPER_CERT) \
	--set cortex.mongo.cert.exporter=$(MONGO_EXPORTER_CERT) \
	--set cortex.mongo.cert.corptax=$(MONGO_CORPTAX_CERT) \
	--set cortex.mongo.cert.backup=$(MONGO_BACKUP_CERT) \
	--set cortex.mongo.cert.encrypt=$(MONGO_BACKUP_ENCRYPT_CERT) \
	--set cortex.rabbit.host="$(RABBIT_HOST)" \
	--set cortex.product="$(PRODUCT)" \
	--set cortex.rabbit.username=$(RABBIT_USERNAME) \
	--set cortex.rabbit.password=$(RABBIT_PASSWORD) \
	--set cortex.rabbit.cert.server=$(RABBIT_SERVER_CERT) \
	--set cortex.rabbit.cert.key=$(RABBIT_SERVER_KEY) \
	--set cortex.rabbit.erlangcookie=$(RABBIT_ERLANG_COOKIE) \
	--set cortex.rabbit.cert.analytics_ui=$(RABBIT_ANALYTICS-UI_CERT) \
	--set cortex.rabbit.cert.corptax=$(RABBIT_CORPTAX_CERT) \
	--set cortex.rabbit.cert.auditlog=$(RABBIT_AUDITLOG_CERT) \
	--set cortex.rabbit.cert.bundle=$(RABBIT_BUNDLE_CERT) \
	--set cortex.rabbit.cert.broker=$(RABBIT_BROKER_CERT) \
	--set cortex.rabbit.cert.client=$(RABBIT_CLIENT_CERT) \
	--set cortex.rabbit.cert.datarequest=$(RABBIT_DATAREQUEST_CERT) \
	--set cortex.rabbit.cert.engagement=$(RABBIT_ENGAGEMENT_CERT) \
	--set cortex.rabbit.cert.informatica=$(RABBIT_INFORMATICA_CERT) \
	--set cortex.rabbit.cert.notification=$(RABBIT_NOTIFICATION_CERT) \
	--set cortex.rabbit.cert.prep_orchestrator=$(RABBIT_PREPORCHESTRATOR_CERT) \
	--set cortex.rabbit.cert.security=$(RABBIT_SECURITY_CERT) \
	--set cortex.rabbit.cert.staging=$(RABBIT_STAGING_CERT) \
	--set cortex.rabbit.cert.workpaper=$(RABBIT_WORKPAPER_CERT) \
	--set cortex.security.recertification=$(RECERTIFICATION) \
	--set cortex.redis.host="$(REDIS_HOST)" \
	--set cortex.redis.password=$(REDIS_PASSWORD) \
	--set cortex.redis.cert.analytics_ui=$(REDIS_ANALYTICS-UI_CERT) \
	--set cortex.redis.cert.prep_orchestrator=$(REDIS_PREPORCHESTRATOR_CERT) \
	--set cortex.redis.cert.datarequest=$(REDIS_DATAREQUEST_CERT) \
	--set cortex.redis.cert.engagement=$(REDIS_ENGAGEMENT_CERT) \
	--set cortex.redis.cert.informatica=$(REDIS_INFORMATICA_CERT) \
	--set cortex.redis.cert.staging=$(REDIS_STAGING_CERT) \
	--set cortex.mysql.host="$(MYSQL_HOST)" \
	--set cortex.mysql.password=$(MYSQL_PASSWORD) \
	--set cortex.mysql.jobserverUsername=$(MYSQL_JOBSERVER_USERNAME) \
	--set cortex.mysql.jobserverPassword=$(MYSQL_JOBSERVER_PASSWORD) \
	--set cortex.mysql.informaticaUsername=$(MYSQL_INFORMATICA_USERNAME) \
	--set cortex.mysql.informaticaPassword=$(MYSQL_INFORMATICA_PASSWORD) \
	--set cortex.mysql.replUsername=$(MYSQL_REPL_USERNAME) \
	--set cortex.mysql.replPassword=$(MYSQL_REPL_PASSWORD) \
	--set cortex.mysql.monitoringUsername=$(MYSQL_MONITORING_USERNAME) \
	--set cortex.mysql.monitoringPassword=$(MYSQL_MONITORING_PASSWORD) \
	--set cortex.mysql.cortexadminUsername=$(MYSQL_CORTEXADMIN_USERNAME) \
	--set cortex.mysql.cortexadminPassword=$(MYSQL_CORTEXADMIN_PASSWORD) \
	--set cortex.mysql.cortexbackupUsername=$(MYSQL_CORTEXBACKUP_USERNAME) \
	--set cortex.mysql.cortexbackupPassword=$(MYSQL_CORTEXBACKUP_PASSWORD) \
	--set cortex.mysql.encrypt_mysql_key=$(ENCRYPT_MYSQL_KEY) \
	--set cortex.mysql.cert=$(MYSQL_SERVER_CERT) \
	--set cortex.mysql.jobserver.cert=$(MYSQL_JOBSERVER_CERT) \
	--set cortex.mssql_eng.host="$(MSSQL_ENG_HOST)" \
	--set cortex.mssql_eng.pool="$(MSSQL_ENG_POOL)" \
	--set cortex.mssql_eng.username=$(MSSQL_ENG_USERNAME) \
	--set cortex.mssql_eng.password=$(MSSQL_ENG_PASSWORD) \
	--set cortex.mssql_int.host="$(MSSQL_INT_HOST)" \
	--set cortex.mssql_int.pool="$(MSSQL_INT_POOL)" \
	--set cortex.mssql_int.username=$(MSSQL_INT_USERNAME) \
	--set cortex.mssql_int.password=$(MSSQL_INT_PASSWORD) \
	--set cortex.mat.host="$(MAT_HOST)" \
	--set cortex.mat.db=$(MAT_DB) \
	--set cortex.mat.username=$(MAT_USERNAME) \
	--set cortex.mat.password=$(MAT_PASSWORD) \
	--set cortex.sap.host="$(SAP_HOST)" \
	--set cortex.sap.username=$(SAP_USERNAME) \
	--set cortex.sap.password="$(SAP_PASSWORD)" \
	--set cortex.spark.account="$(SPARK_HOST)" \
	--set cortex.spark.username=$(SPARK_USERNAME) \
	--set cortex.spark.password=$(SPARK_PASSWORD) \
	--set cortex.datalake.account="$(DATALAKE_HOST)" \
	--set cortex.datalake.client_id=$(DATALAKE_CLIENT_ID) \
	--set cortex.datalake.client_secret=$(DATALAKE_CLIENT_SECRET) \
	--set cortex.datalake.tenant=$(DATALAKE_TENANT) \
	--set cortex.informatica.host="$(INFORMATICA_HOST)" \
	--set cortex.informatica.app=$(INFORMATICA_APP) \
	--set cortex.informatica.passwordkey=$(INFORMATICA_PASSWORDKEY) \
	--set cortex.broker.encryptionkey=$(BROKER_ENCRYPTIONKEY) \
	--set cortex.informatica.username=$(INFORMATICA_USERNAME) \
	--set cortex.informatica.password=$(INFORMATICA_PASSWORD) \
	--set cortex.informatica.org=$(INFORMATICA_ORG) \
	--set cortex.informatica_cloud.cert=$(MYSQL_INFORMATICA_CLOUD_CERT) \
	--set cortex.sftp.passwordkey=$(SFTP_PASSWORDKEY) \
	--set cortex.tableau.host="$(TABLEAU_HOST)" \
	--set cortex.tableau.username="$(TABLEAU_USERNAME)" \
	--set cortex.tableau.password="$(TABLEAU_PASSWORD)" \
	--set cortex.tableau.cert="$(TABLEAU_CERT)" \
	--set cortex.tableau.cl_role="$(TABLEAU_CL_ROLE)" \
	--set cortex.tableau.engagement_role="$(TABLEAU_ENGAGEMENT_ROLE)" \
	--set cortex.exum.account=$(EXUM_ACCOUNT) \
	--set cortex.exum.password=$(EXUM_PASSWORD) \
	--set cortex.exum.exum_flag=$(EXUM_FLAG) \
	--set cortex.appinsights.analytics_ui="$(APPINSIGHTS_ANALYTICS_UI)" \
	--set cortex.appinsights.analytics_worker="$(APPINSIGHTS_ANALYTICS_WORKER)" \
	--set cortex.appinsights.auditlog="$(APPINSIGHTS_AUDITLOG)" \
	--set cortex.appinsights.bundle="$(APPINSIGHTS_BUNDLE)" \
	--set cortex.appinsights.client="$(APPINSIGHTS_CLIENT)" \
	--set cortex.appinsights.datarequest="$(APPINSIGHTS_DATAREQUEST)" \
	--set cortex.appinsights.engagement="$(APPINSIGHTS_ENGAGEMENT)" \
	--set cortex.appinsights.extraction_ui="$(APPINSIGHTS_EXTRACTION_UI)" \
	--set cortex.appinsights.informatica="$(APPINSIGHTS_INFORMATICA)" \
	--set cortex.appinsights.notification="$(APPINSIGHTS_NOTIFICATION=)" \
	--set cortex.appinsights.prep_orchestrator="$(APPINSIGHTS_PREP_ORCHESTRATOR)" \
	--set cortex.appinsights.security="$(APPINSIGHTS_SECURITY)" \
	--set cortex.appinsights.sftp="$(APPINSIGHTS_SFTP)" \
	--set cortex.appinsights.staging="$(APPINSIGHTS_STAGING)" \
	--set cortex.appinsights.workpaper="$(APPINSIGHTS_WORKPAPER)" \
	--set cortex.appinsights.corptax="$(APPINSIGHTS_CORPTAX)" \
	--set cortex.appinsights.jobserver="$(APPINSIGHTS_JOBSERVER)" \
	--set cortex.appinsights.scheduler="$(APPINSIGHTS_SCHEDULER)" \
	--set cortex.appinsights.broker="$(APPINSIGHTS_BROKER)" \
	--set analytics_ui.imageTag=$(ANALYTICS_UI_TAG) \
	--set espresso.imageTag=$(ESPRESSO_TAG) \
	--set analytics_worker.imageTag=$(ANALYTICS_UI_TAG) \
	--set tradechain_web.imageTag=$(TRADECHAIN_WEB_TAG) \
	--set tradechain_workpaper.imageTag=$(TRADECHAIN_ANALYTICS_UI_TAG) \
	--set tradechain_worker.imageTag=$(TRADECHAIN_ANALYTICS_UI_TAG) \
	--set auditlog.imageTag=$(AUDITLOG_TAG) \
	--set broker.imageTag=$(BROKER_TAG) \
	--set bundle.imageTag=$(BUNDLE_TAG) \
	--set client.imageTag=$(CLIENT_TAG) \
	--set workpaper.imageTag=$(WORKPAPER_TAG) \
	--set corptax.imageTag=$(CORPTAX_TAG) \
	--set corptax_worker.imageTag=$(CORPTAX_TAG) \
	--set datarequest.imageTag=$(DATAREQUEST_TAG) \
	--set engagement.imageTag=$(ENGAGEMENT_TAG) \
	--set extraction_ui.imageTag=$(EXTRACTION_UI_TAG) \
	--set factiva.imageTag=$(FACTIVA_TAG) \
	--set informatica.imageTag=$(INFORMATICA_TAG) \
	--set notification.imageTag=$(NOTIFICATION_TAG) \
	--set prep_orchestrator.imageTag=$(PREP_ORCHESTRATOR_TAG) \
	--set sap.imageTag=$(SAP_TAG) \
	--set scheduler.imageTag=$(SCHEDULER_TAG) \
	--set security.imageTag=$(SECURITY_TAG) \
	--set sftp.imageTag=$(SFTP_TAG) \
	--set staging.imageTag=$(STAGING_TAG) \
	--set tableau_api.imageTag=$(TABLEAU_API_TAG) \
	--set jobserver_ui.image=jobserver-ui-$(ENV) \
	--set jobserver_ui.jar_version=$(JOBSERVER_JAR_VERSION) \
	--set jobserver_ui.username=$(JOBSERVER_UI_USERNAME) \
	--set jobserver_ui.password=$(JOBSERVER_UI_PASSWORD) \
	--set cortex.notify_email=$(NOTIFY_EMAIL) \
	--set cortex.ingress.auth.tenantid=$(AUTH_ING_TENANT_ID) \
	--set cortex.ingress.auth.app.id=$(AUTH_ING_APP_ID) \
	--set staging.filedeletiondays=$(FILEDELETIONDAYS) \
	--set cortex.ingress.auth.app.secret=$(AUTH_ING_APP_SECRET) | grep -A 999999999 "COMPUTED VALUES:"  | sed -e '1d' |  sed -e :a -e '$d;N;2,4ba' -e 'P;D' > secrets.yaml
	# ENV=$(ENV) /bin/bash ./secrets.sh push
# else
# secrets.yaml:
# 	ENV=$(ENV) /bin/bash ./secrets.sh pull
# endif

cortex:
	#HACK: delete all jobs before start anyway
	-kubectl delete jobs --all
	helm upgrade cortex . --install --recreate-pods --force -f values.yaml -f secrets.yaml --wait --timeout 3000
	-kubectl delete pods -l app=cortex-jobserver-ui
	#restart and ingress balancers, if need more, please add special class name
	-kubectl delete pods -l release=ingress-ext
	-kubectl delete pods -l release=ingress-int
	-kubectl delete pods -l release=ingress-restricted
	-kubectl delete pods -l release=ingress-metrics
	-kubectl scale --replicas=0 deployments/kubernetes-dashboard -n kube-system
cleanup:
	-$(shell rm -rf ~/.kube/config)

install: login kubeconfig tiller-patch init secrets.yaml kube-lego cortex logging monitoring ingress ingress-expose cleanup
