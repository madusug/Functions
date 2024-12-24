#!/bin/bash

# Environment variable passed as the first argument
ENVIRONMENT=$1

# Function to check the number of arguments
check_num_of_args() {
    # Checking if exactly one argument is passed
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <environment>"
        exit 1
    fi
}

# Function to activate infrastructure environment
activate_infra_environment() {
    # Acting based on the argument value
    if [ "$ENVIRONMENT" == "local" ]; then
        echo "Running script for Local Environment..."
    elif [ "$ENVIRONMENT" == "testing" ]; then
        echo "Running script for Testing Environment..."
    elif [ "$ENVIRONMENT" == "production" ]; then
        echo "Running script for Production Environment..."
    else
        echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
        exit 2
    fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it before proceeding."
        exit 3
    fi
}

# Function to check if AWS profile is set
check_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        echo "AWS profile environment variable is not set."
        return 1
    fi
}

# Function to create EC2 instances
create_ec2_instances() {
    # Specify the parameters for the EC2 instances
    instance_type="t2.micro"
    ami_id="ami-01816d07b1128cd2d"
    count=2  # Number of instances to create
    region="us-east-1"  # AWS region to create cloud resources
    
    # Create the EC2 instances using AWS CLI
    aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --count $count \
        --region "$region" \
        --key-name DareyNext

    # Check if the EC2 instances were created successfully
    if [ $? -eq 0 ]; then
        echo "EC2 instances created successfully."
    else
        echo "Failed to create EC2 instances."
        exit 5
    fi
}

# Function to create S3 buckets for different departments
create_s3_buckets() {
    # Define a company name as prefix
    company="datawise"
    # Array of department names
    departments=("Marketing" "Sales" "HR" "Operations" "Media")
    
    # Loop through the array and create S3 buckets for
    for department in "${departments[@]}"; do
        bucket_name="${company}-${department,,}-data-bucket"  # Convert to lowercase
        # Create S3 bucket using AWS CLI
        aws s3api create-bucket --bucket "$bucket_name" --region "us-east-1"
        if [ $? -eq 0 ]; then
            echo "S3 bucket '$bucket_name' created successfully."
        else
            echo "Failed to create S3 bucket '$bucket_name'."
        fi
    done
}

# Function to create IAM users
create_IAM_users(){
	# Store the usernames in an array variable
	users=("John" "Peter" "Mike" "James" "Jill")

	# Create new user by iterating through the users array
	for user in "${users[@]}"; do
		aws iam create-user \
			--user-name $user
	done
}

# Function to create IAM group
create_IAM_group(){
	# Define parameters
	group_name="admin"

	# Create IAM Group
	aws iam create-group \
		--group-name $group_name
}

# Function to attach IAM policy to IAM Group
attach_policy_to_group(){
	aws iam attach-group-policy \
		--policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
		--group-name $group_name
}

# Assign Users to Groups
assign_users_to_group(){
	for user in "${users[@]}"; do
		aws iam add-user-to-group \
			--user-name $user \
			--group-name $group_name
	done
}

# Main execution
check_num_of_args "$@"                 # Check arguments
activate_infra_environment             # Validate and handle environment
check_aws_cli                          # Ensure AWS CLI is installed
check_aws_profile                      # Ensure AWS profile is set
create_ec2_instances                   # Create EC2 instances
create_s3_buckets                      # Create S3 buckets
create_IAM_users		       # Create IAM users
create_IAM_group		       # Create IAM group
attach_policy_to_group		       # Attach policy to IAM group
assign_users_to_group		       # Assign IAM users to IAM group
