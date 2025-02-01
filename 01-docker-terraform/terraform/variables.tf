variable "credentials" {
  description = "My Credentials"
  default     = "/workspaces/data-engineering-zoomcamp/01-docker-terraform/keys/my-creds.json"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}


variable "project" {
  description = "Project"
  default     = "de-zoomcamp-449519"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default = "europe-west1-b"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default = "EU"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default = "de_zoomcamp_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default = "de-zoomcamp-449519-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}