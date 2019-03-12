# BCDC Rails API

Subscribe to datasets and be notified of changes via webhook.
This dockerized solution inludes Redis (optional) and Postgres (for users authentication, if needed).

API documentation: http://localhost:3000/api/v1/api_doc



# Requirements
Docker installed on machine.

https://www.docker.com/products/docker-desktop



# Running

## Local Setup 
1) Extract the ZIP file

2) edit both docker-compose yml files to change the environment variables:

      under "db",

          - POSTGRES_DB=rails-api-prod
          - POSTGRES_USER=user
          - POSTGRES_PASSWORD=password

      under "rails-app",

          - DB_USER=user        <= from db settings above
	        - DB_PASS=password    <= from db settings above
          - SECRET_KEY_BASE=mySecretRailsKeyBase    <= Rails secret key
          - ID=admin                    <= Rails api key header param 
          - X-API-KEY=mySecretKey       <= Rails api key header param 
          - BC_API_URL=http://python_api:3003     <= Rails api url
          - RAILS_API_URL=http://rails_app:3000   <= Python api url
          - BC_API_ID=user1 <= Python api key header param
          - BC_API_KEY=pass1 <= Python api key header param

3) in the Terminal, cd into the path of the extracted folder  

4) run "docker-compose up --build"

5) enter the "rails_app" container bash and launch the following to create and populate the db:
   - rake db:schema:load 
   - rake db:seed 




## Extra (for local development)
Using a docker-compose yml file, all containers for different services can easily communicate with each other.
These are the steps.

1) create an image of the other api
2) edit docker-compose_2.yml, which contains the following extra services, reflecting the mongo settings in the "default.json" file, under api/config of the the other api:
   
      
      python_api:
        image: bc-python-api  <= or whatever the name of the image for the other api
        ports:
          - "3003:3003"
        depends_on:
         - mongo
       
      mongo:
        image: mongo
        restart: always
        ports:
        - "27017:27017"
        environment: 
          - MONGO_INITDB_DATABASE=lightning
          - MONGO_INITDB_ROOT_USERNAME=lightning
          - MONGO_INITDB_ROOT_PASSWORD=lightningPass


3) run "docker-compose -f docker-compose_with_python_api.yml up --build"




## Production Setup
1) if deploying using a docker-compose yml file (or just as a starting point), make sure to replicate and edit the same environment variables in your deployment setup.
