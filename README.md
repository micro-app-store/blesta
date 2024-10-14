# Blesta Docker Image

This repository contains a Docker image for running [Blesta](https://www.blesta.com/), a billing and client management system, on PHP 8.1, Apache, and Debian Bookworm.

## Features

- Blesta pre-installed
- PHP 8.1 with necessary extensions
- Apache web server
- Debian Bookworm base
- Configurable environment variables

## Prerequisites

To run this Docker image, you need to have:

- Docker installed: [Install Docker](https://docs.docker.com/get-docker/)
- A valid Blesta License
  - **Note:** Blesta requires a license to function. For Docker installations, you may need a [Blesta License](https://www.blesta.com/pricing/).

## Usage

1. **Pull the image from GitHub Container Registry**:
   ```bash
   docker pull ghcr.io/micro-app-store/blesta:latest
   ```

2. **Run the container** with the following command:
   ```bash
   docker run -d \
   --name blesta \
   -p 8080:8080 \
   -v /path/to/your/config:/var/www/html/config/ \
   -v /path/to/your/uploads:/var/www/html/uploads/ \
   -e MYSQL_HOST=localhost \
   -e MYSQL_USER=blesta \
   -e MYSQL_PASSWORD=blesta \
   -e MYSQL_DATABASE=blesta \
   ghcr.io/micro-app-store/blesta:latest
   ```

3. **Access Blesta**:
   Open a browser and go to `http://localhost:8080/`. Follow the Blesta setup steps to complete the installation.

## Environment Variables

The following environment variables are used to configure the database connection for Blesta:

- `MYSQL_HOST`: The database host (default: `localhost`).
- `MYSQL_USER`: The database username (default: `blesta`).
- `MYSQL_PASSWORD`: The database password (default: `blesta`).
- `MYSQL_DATABASE`: The name of the database to use (default: `blesta`).

These should be updated to match your database setup if using a custom configuration.

## Volumes

You can use Docker volumes to persist important data such as Blesta's configuration and uploaded files:

- `/var/www/html/config/`: Blesta configuration files.
- `/var/www/html/uploads/`: Blesta file uploads.

Make sure these paths are mapped to your host machine for data persistence.

## License Requirement

Blesta requires a valid license to operate. When running Blesta in Docker, a [Blesta License](https://www.blesta.com/pricing/) may be required. Ensure you have the appropriate license before deploying this image in production.

## Building the Image

If you want to build the image locally, clone this repository and run:

```bash
docker build -t blesta:latest .
```