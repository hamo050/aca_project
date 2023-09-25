#!/bin/bash
echo "RUN Terrafor"
cd aca_project/terraform
export AWS_ACCESS_KEY_ID="AKIARQOEUK5YB3VEHFCR"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_REGION="us-east-1"
sudo terraform init
terraform apply -auto-approve  

terraform output | grep elastic_ip | awk -F'"' '/"/ {print $2}' >> ../ansible/inventory

mysql_host=$(terraform output | grep db_ip | awk -F'"' '/"/ {print $2}')
cd ..

echo "RUN Ansible"
ansible-playbook ansible/wordpress-playbook.yaml -i ansible/inventory -e mysql_host=$mysql_host --ssh-common-args='-o StrictHostKeyChecking=no'

echo "Project Successfully completed!"
