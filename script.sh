#!/bin/bash
echo "RUN Terrafor"
cd ./terraform
terraform apply -auto-approve  

terraform output | awk -F'"' '/"/ {print $2}' >> ../ansible/inventory
cd ..

echo "RUN Ansible"
ansible-playbook ansible/wordpress-playbook.yaml -i ansible/inventory --ssh-common-args='-o StrictHostKeyChecking=no'

echo "Project Successfully completed!"
