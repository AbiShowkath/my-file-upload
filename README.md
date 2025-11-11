# FileUpload Application

A basic, back-end file upload application built with FastAPI backend, featuring azure keyvault, azure storage containers, and Docker containerization.

(Plan to include frontend, database, user registration, login, etc in the future)

## Features

- **File Upload**: Upload a file to an azure storage container
- **List Existing Containers**: Fetch list of existing storage containers
- **Create Containers**: Create a new storage container
- **Containerized**: Full Docker setup for easy deployment

## Technology Stack

### Backend (`/`)
- **FastAPI**: Modern, fast web framework for APIs

## Project Structure

```
file_upload/
├── py-file-upload/        # Python FastAPI backend
│   ├── main.py            # FastAPI application connection
│   ├── requirements.txt   # Python dependencies
│   ├── .env               # Environment variables
│   └── Dockerfile         # API container config
├── rt-file-upload/        # React frontend
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── context/       # React context providers
│   │   ├── services/      # API service layer
│   │   └── index.js       # App entry point
│   ├── public/            # Static assets
│   └── package.json       # Node.js dependencies
```

## Quick Start

### Prerequisites
- Docker
- Git
- Azure Subscription
- Azure App Registration
- Azure Keyvault
- Azure Storage Account
- Azure Storage Account Container

### Installation and Setup

1. **Clone and navigate to the project:**
   ```bash
   cd file_upload
   ```

2. **Start all services:**
   ```bash
   docker build -t py-file-upload-image .
   docker run -d --name py-file-upload-container -p 8000:8000 py-file-upload-image:latest
   ```

3. **Access the application:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs


### Manual Setup (Development)

#### Backend Setup
```bash
cd api
pip install -r requirements.txt
py -3.13 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

## API Endpoints

### File upload
- `GET /containers/` - List all storage containers
- `POST /containers/create/` - Create a storage containers
- `POST /containers/uploadfile/` - Upload a file to the container
- `GET /containers/blobs/` - List all files of a container

## Usage

1. List all available containers
2. Pick on container
3. Upload a file to that container
4. Check the container by listing all files

## Environment Variables

### Backend (.env)
```
ORIGIN=<frontend_url>
KEY_VAULT_NAME=<keyvault_name>
STORAGE_ACCOUNT_NAME=<storage_account_name>
AZURE_CLIENT_ID=<appId>
AZURE_TENANT_ID=<tenantId>
AZURE_CLIENT_SECRET=<password>
```


## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the MIT License.