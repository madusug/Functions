# Function to create S3 buckets for different departments
create_s3_buckets() {
    # Define a company name as prefix
    company="datawiseugo"
    # Array of department names
    departments=("Marketing" "Sales" "HR" "Operations" "Media")
    
    # Loop through the array and create S3 buckets for each department
    for department in "${departments[@]}"; do
        # Convert department name to lowercase
        bucket_name="${company}-${department,,}-data-bucket"
        # Create S3 bucket using AWS CLI
        aws s3api create-bucket --bucket "$bucket_name" --region us-east-1
        if [ $? -eq 0 ]; then
            echo "S3 bucket '$bucket_name' created successfully."
        else
            echo "Failed to create S3 bucket '$bucket_name'."
        fi
    done
}

# Call the function to create S3 buckets for different departments
create_s3_buckets

