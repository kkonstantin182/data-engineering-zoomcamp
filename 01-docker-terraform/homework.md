# Module 1 Homework: Docker & SQL

In this homework we'll prepare the environment and practice
Docker and SQL

## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.

What's the version of `pip` in the image?

- 24.3.1
- 24.2.1
- 23.3.1
- 23.2.1

### Solution 

To run the python docker container, use:  
```
docker run -it  --entrypoint=bash python:3.12.8  
```
Then, pip version is 24.3.1.

**Answer:** 24.3.1 


## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- postgres:5432
- db:5432

If there are more than one answers, select only one of them

### Solution

We need to execute given docker-compose.yml using 
```
docker-compose up
```
Then, we can access pgadmin using this address: *http://localhost:8080*.     
After, we need to create a server inside pgadmin and to connect to Postgres database.  

In our docker-compose.yml  the port of Postgres in a host machine is 5433. But the port inside the container is 5432.
Since both pgadmin and postgres are inside the Docker, we need to use 
- the port **5432**
- the host is the name of the service (**'db'**)

**Answer:** db:5432

##  Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from October 2019:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
```

You will also need the dataset with zones:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

Download this data and put it into Postgres.

You can use the code from the course. It's up to you whether
you want to use Jupyter or a python script.

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

Answers:

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
- 104,838;  199,013;  109,645;  27,688;  35,202


### Solution

```
SELECT 
	CASE
		WHEN trip_distance <= 1 THEN '<1'
		WHEN trip_distance  <= 3 AND trip_distance > 1 THEN '1-3'
		WHEN trip_distance  <= 7 AND trip_distance > 3 THEN '3-7'
		WHEN trip_distance  <= 10 AND trip_distance > 7 THEN '7-10'
		ELSE '>10'
	END AS distance_interval,
	COUNT(*)

FROM public.green_tripdata
WHERE 
	CAST(lpep_pickup_datetime AS date) >= '2019-10-01' AND
	CAST(lpep_dropoff_datetime AS date) < '2019-11-01'
	
GROUP BY distance_interval

```

**Aswer:** 104,802; 198,924; 109,603; 27,678; 35,189

## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance. 

- 2019-10-11
- 2019-10-24
- 2019-10-26
- 2019-10-31

### Solution

```
SELECT 
	DATE(lpep_pickup_datetime) AS trip_day,
	MAX(trip_distance) AS max_distance
FROM public.green_tripdata
GROUP BY trip_day
ORDER BY max_distance DESC
LIMIT 1
```

**Answer:** 2019-10-31

## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.
 
- East Harlem North, East Harlem South, Morningside Heights
- East Harlem North, Morningside Heights
- Morningside Heights, Astoria Park, East Harlem South
- Bedford, East Harlem North, Astoria Park

### Solution

```
WITH table_with_zone_names AS(

	SELECT 
		total_amount,
		pulu."Zone" AS pick_up_zone
		-- dolu."Zone" AS drop_off_zone
	FROM green_tripdata AS t
	
	INNER JOIN taxi_zone_lookup AS pulu
	   ON t."PULocationID" = pulu."LocationID"
	INNER JOIN taxi_zone_lookup AS dolu
		ON t."DOLocationID" = dolu."LocationID"

	WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
	
)

SELECT 
	pick_up_zone,
	SUM(total_amount) AS total_per_trip
FROM table_with_zone_names
GROUP BY pick_up_zone
ORDER BY total_per_trip DESC
LIMIT 5
```

**Answer:**   East Harlem North, East Harlem South, Morningside Heights

## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
named "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

- Yorkville West
- JFK Airport
- East Harlem North
- East Harlem South

### Solution

```
SELECT 
	tip_amount
	,dolu."Zone" AS drop_off_zone
	
FROM green_tripdata AS t

INNER JOIN taxi_zone_lookup AS pulu
   ON t."PULocationID" = pulu."LocationID"
INNER JOIN taxi_zone_lookup AS dolu
	ON t."DOLocationID" = dolu."LocationID"

WHERE date_part('month', lpep_pickup_datetime) = 10 AND
	pulu."Zone" = 'East Harlem North'

ORDER BY tip_amount DESC
LIMIT 1

```

**Answer:**  JFK Airport


## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. 
Copy the files from the course repo
[here](../../../01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.


## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:
- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm

### Solution

To create GCP bucket and Big Query Dataset we need to do the following:

* Create *main.tf* file where we specify: 
  * Provider (in our case GCP)
  * Google Cloud Storage (GCS) bucket
  * BigQuery dataset 

* (Optional) Create *variables.tf* to parametrize *main.tf*

**Answer:** terraform init, terraform apply -auto-approve, terraform destroy


## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2025/homework/hw1