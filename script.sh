#!/bin/bash
echo "RUN Terrafor"
cd aca_project/terraform
terraform apply -auto-approve  

terraform output | grep elastic_ip | awk -F'"' '/"/ {print $2}' >> ../ansible/inventory

mysql_host=$(terraform output | grep db_ip | awk -F'"' '/"/ {print $2}')
cd ..

echo "RUN Ansible"
ansible-playbook ansible/wordpress-playbook.yaml -i ansible/inventory -e mysql_host=$mysql_host --ssh-common-args='-o StrictHostKeyChecking=no'

echo "Project Successfully completed!"
