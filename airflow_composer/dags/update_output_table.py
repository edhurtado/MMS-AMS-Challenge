from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.python import PythonOperator
from datetime import timedelta
from utils.sql_utils import load_sql_file

# Defining DAG Variables
gcp_sql_path = "/home/airflow/gcs/dags/sql/" # Path to all SQL files
sql_file_name = "update_output_table.sql" # Specific SQL file
destination_table = "project.dataset.output_table" # Target table 
project_location = "northamerica-northeast1" # GCP Project location
default_args = {
    "owner": "MMS A&SM",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5)
}

dag = DAG(
        "update_output_table",
        default_args=default_args,
        description='Update the data for the output_table, append results',
        schedule_interval="0 0 * * *"
        start_date=datetime(2024, 6, 1),
        catchup=False
        )

with dag:

    get_query = PythonOperator(
                    task_id="load_query",
                    python_callable=load_sql_file,
                    op_kwargs={"path_to_file": gcp_sql_path, "file_name": sql_file_name},
                    provide_context=True,
                    dag=dag,
                )

    update_table = BigQueryInsertJobOperator(
                        task_id="updatre_output_table",
                        configuration={"query":{
                                                "query":"{{ ti.xcom_pull(key='trgt_ds_tbl_nm_arr', task_ids='get_trgt_tbl') }}",
                                                "destinationTable":{"projectId": destination_table.split(".")[0], "datasetId":  destination_table.split(".")[1], "tableId":  destination_table.split(".")[2]},
                                                "useLegacySql":False,
                                                "writeDisposition":'WRITE_APPEND',
                                        }},
                        location=project_location
                    )

    get_query >> update_table
