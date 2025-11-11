from typing import Annotated
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from azure.identity import EnvironmentCredential
from azure.storage.blob import BlobServiceClient
from azure.keyvault.secrets import SecretClient
from azure.core.exceptions import ResourceExistsError

import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

origins = [
      os.getenv("ORIGIN", "http://localhost:3000")
]

app.add_middleware(
   CORSMiddleware,
   allow_origins=origins,
   allow_credentials=True,
   allow_methods=["*"],
   allow_headers=["*"],
)

KVUri = f"https://{os.getenv('KEY_VAULT_NAME')}.vault.azure.net"
credential = EnvironmentCredential(additionally_allowed_tenants=[os.getenv("AZURE_TENANT_ID")])
client = SecretClient(vault_url=KVUri, credential=credential)

storAccConnStr = client.get_secret(f"{os.getenv('STORAGE_ACCOUNT_NAME')}-conn-str")
connection_string = storAccConnStr.value

blob_service_client = BlobServiceClient.from_connection_string(connection_string)

@app.get("/")
def first_example():
  '''
     FG Example First Fast API Example 
  '''
  return {"GFG Example": "FastAPI"}

@app.post("/files/")
async def create_file(file: Annotated[bytes, File()]):
    return {
       "file": file,
       "file_size": len(file)
    }

@app.get("/containers/")
async def list_containers():
    containers = blob_service_client.list_containers()
    return [{"name": container.name} for container in containers]

@app.post("/containers/create/")
async def create_container(container_name: str):
    try:
        blob_service_client.create_container(name=container_name)
    except ResourceExistsError:
        print('A container with this name already exists')
    return list_containers()

@app.post("/containers/uploadfile/")
async def upload_blob(container_name: str, file: UploadFile):
    file_name = file.filename
    container_client = blob_service_client.get_container_client(container=container_name)
    blob_client = container_client.upload_blob(name=file_name, data=file.file, overwrite=True)
    print(f"Blob URL: {blob_client.url}")
    return {"blob_url": blob_client.url}

@app.get("/containers/blobs/")
async def list_blobs(container_name: str):
    container_client = blob_service_client.get_container_client(container=container_name)
    blobs = container_client.list_blobs()
    return [{"name": blob.name, "size": blob.size} for blob in blobs]