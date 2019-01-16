#!/usr/bin/env bash

show_usage()
{
    echo "app.sh - bash script to control application status"
    echo
    echo "Usage:"
    echo "  ./app.sh <action> <parameters>"
    echo
    echo "Actions:"
    echo "  create    [env] - create infrastructure using Terraform"
    echo "  destroy   [env] - destroy infrastructure"
    echo "  provision [env] - provision application on infrastructure"
    echo "  deploy    [env] - deploy configuration for application"
    echo
    echo "Parameters:"
    echo "  Environment [env] : dev|prod (required)"
}

ansible_playbook ()
{
    # Remove temporary files
    rm -rf base/ansible/*.retry
    rm -rf base/terraform/.terraform
    rm -rf base/terraform/terraform.tf

    # Run playbook
	cd base/ansible; \
	ansible-playbook --vault-id @prompt -i $1 $2 -e env=$3
}

case $1 in 
    create)
        case $2 in
            dev|prod)
                ansible_playbook ../inventory/localhost ./terraform.yml $2
                cd ../terraform && terraform apply
            ;;
            *)
                show_usage
            ;;
        esac
    ;;
    destroy)
        case $2 in
            dev|prod)
                ansible_playbook ../inventory/localhost ./terraform.yml $2
                cd ../terraform && terraform destroy
            ;;
            *)
                show_usage
            ;;
        esac
    ;;
    provision|deploy)
        case $2 in
            dev|prod)
                ansible_playbook ../inventory/ec2.py ./$1.yml $2 $3
            ;;
            *)
                show_usage
            ;;
        esac
    ;;
    *)
        show_usage
    ;;
esac
