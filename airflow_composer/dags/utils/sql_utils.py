# Defining function to Load any query from SQL file and passed it to XCom
def load_sql_file(path_to_file:str=None, file_name:str=None, **kwargs):
    """Load the sql file

    Args:
        path_to_file (str, optional): _description_. Defaults to None.
        file_name (str, optional): _description_. Defaults to None.
    """
    query = ""

    if path_to_file is None and file_name is None:
        print(f"Cannot load the SQL files, please check the variables:  path={path_to_file}, file_name={file_name}")
        print("Passing empty query to the next task")
    else:
        file_path = f"{path_to_file}{file_name}"
        with open(file_path, 'r') as file:
            query = file.read()

    # Pushing query to XCom
    kwargs['ti'].xcom_push(key='update_query', value=query)
