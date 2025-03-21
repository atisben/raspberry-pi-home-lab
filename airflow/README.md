[Check this guide](https://www.justinwagg.com/docker-airflow-tutorial/)

## Fernet Key

Fernet key must be added as part of an environment variable

## How to: Run DAGs

### Creating a Simple DAG

__Locate your DAGs folder:__ 
By default, Airflow looks for DAGs in the /opt/airflow/dags directory within the container. When you set up Airflow with Docker, you likely mapped this directory to a local directory on your Raspberry Pi.
__Create a new Python file:__
Create a file named my_first_dag.py in your DAGs folder.
Write a basic DAG: Here's a simple example DAG that runs every day and has three tasks that execute in sequence:

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 21),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'my_first_dag',
    default_args=default_args,
    description='My first Airflow DAG',
    schedule_interval=timedelta(days=1),
)

# Define a Python function
def print_hello():
    return 'Hello from my first Airflow DAG!'

# Task 1 - Run a bash command
t1 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag,
)

# Task 2 - Run a Python function
t2 = PythonOperator(
    task_id='print_hello',
    python_callable=print_hello,
    dag=dag,
)

# Task 3 - Run another bash command
t3 = BashOperator(
    task_id='print_dir',
    bash_command='ls -la',
    dag=dag,
)

# Set task dependencies
t1 >> t2 >> t3

```

### Testing the Dag

1. Check for syntax errors:
```bash
docker exec -it [your-airflow-container-name] python -c "import your_dag_file"
```

2. Test specific tasks: You can test individual tasks using the airflow tasks test command:
```bash
docker exec -it [your-airflow-container-name] airflow tasks test my_first_dag print_date 2025-03-21
```

3. Test the entire DAG: Run all tasks in your DAG for a specific execution date:
```bash
docker exec -it [your-airflow-container-name] airflow dags test my_first_dag 2025-03-21
```

## Other commands
- list all the dags
```bash
airflow dags list
```

- restarting airflow webserver
```bash
airflow webserver -p 8080 -D
```