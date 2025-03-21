# Set up of postgres database

## 1.Deploy the PostgreSQL stack in Portainer:

1. Go to your Portainer dashboard
2. Navigate to Stacks -> Add stack
3. Name it something like "shared-postgres"
4. Paste the docker-compose
5. Click "Deploy the stack"


## 2.Create databases for n8n and Airflow after PostgreSQL is running:

1. In Portainer, go to Containers
2. Find and click on "shared-postgres" container
3. Click on "Console" or "Exec Console"
4. Choose "/bin/bash" as the command
5. Run these commands to create the databases:

```bash
psql -U postgres

```

```SQL
CREATE DATABASE n8n;
CREATE USER n8n WITH PASSWORD 'n8npassword';
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;

CREATE DATABASE airflow;
CREATE USER airflow WITH PASSWORD 'airflowpassword';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

\l  -- List databases to verify
\q  -- Quit

```