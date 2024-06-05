# Ethereum Monitoring Stack

This repository contains the infrastructure and configurations for monitoring an Ethereum-based smart contract using Prometheus and Grafana. The stack is deployed using Docker and managed by Terraform.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Smart Contract](#smart-contract)
- [Monitoring Setup and Deployment](#monitoring-setup-and-deployment)
- [Monitoring Configuration](#monitoring-configuration)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- Docker
- Terraform
- EOA address recovery phrase to deploy the contract from (should hold some ETH on Sepolia)
- Alchemy API key for the Sepolia network

## Project Structure

    ├── grafana
    │   ├── alerts.json
    │   ├── contacts.json.tmpl
    │   ├── dashboard.json
    │   ├── default.yaml
    │   └── grafana.datasources.yaml
    ├── prometheus
    │   └── prometheus.yml
    ├── scraper
    │   └── config.yml.tmpl
    ├── main.tf
    └── UpToken
        ├── contracts
        │   └── UpToken.sol
        ├── migrations
        │   └── 1_initial_migration.js
        ├── test
        │   └── .gitkeep
        └── truffle-config.js
    └── .gitignore

## Getting Started

1. **Clone the repository:**

    ```sh
    git clone https://github.com/goooff/sre-task-ethereum-monitoring-stack.git
    cd sre-task-ethereum-monitoring-stack/
    ```

## Smart Contract

The UpToken smart contract is located in the `UpToken/contracts` directory. It is a simple ERC-20 token used for monitoring.

### Compilation and Deployment

To compile and deploy the UpToken contract:

1. Navigate to the UpToken directory:

    ```sh
    cd UpToken
    ```

2. Install the dependencies:

    ```sh
    npm install -g truffle
    npm install @openzeppelin/contracts
    npm install @truffle/hdwallet-provider
    npm install dotenv
    ```

3. Create a .env file

    ```sh
        cat <<EOF > .env
        MNEMONIC = "your_EOA_recovery_phrase"
        PROJECT_ID = "your_sepolia_alchemy_API_key"
        EOF
    ```

4. Compile the contract:

    ```sh
    truffle compile
    ```

4. Deploy the contract:

    ```sh
    truffle migrate --reset --network sepolia
    ```

## Monitoring Setup and Deployment

1. From the project root, navigate to the terraform directory:

    ```sh
    cd Monitoring/terraform
    ```

2. **Create a `secrets.tfvars` file:**

    This file should contain the API key for the scraper.

    ```sh
        cat <<EOF > secrets.tfvars
        api_key = "your_api_key"
        slack_webhook = "your_slack_webhook"
        grafana_admin_password = "your_grafana_admin_password"
        EOF
    ```

3. **Initialize Terraform:**

    ```sh
    terraform init
    ```

4. **Deploy the stack:**

    ```sh
    terraform apply --var-file=secrets.tfvars -auto-approve
    ```

5. **Access Grafana and Prometheus:**

    - Grafana: [http://localhost:3000](http://localhost:3000) 
    - Prometheus: [http://localhost:9090](http://localhost:9090)

6. **Verify the setup:**

    - Check if the Grafana dashboard and alerts are imported and the metrics are displayed correctly.
    - Check Prometheus for the metrics scraped by the Ethereum address metrics exporter.

## Monitoring Configuration

### Grafana Dashboard

The Grafana dashboard is pre-configured with the necessary data sources, dashboards and alerts. It is provisioned from the files in the `grafana/` folder. Contact points are configured to use a slack webhook from the `secrets.tfvars` file.

### Prometheus Configuration

The Prometheus configuration file is located at `prometheus/prometheus.yml`. This file defines the scrape configurations and targets.

### Scraper Configuration

The scraper configuration template is located at `scraper/config.yml.tmpl`. This file uses the API key provided in `secrets.tfvars` to fetch data.

## License

This project is licensed under the MIT License.