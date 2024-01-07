# Database Population Guide

To populate the database, a specific structure has been created due to the large size of our data, making direct uploads impractical. Follow the steps below to properly run the data:

### Step 1: Run Data Generator

- Execute the provided data generator Python file, which will generate the following CSV files in the current directory:

    - airplane.csv
    - airplanemodel.csv
    - checks.csv
    - FidelityCard.csv
    - flight.csv
    - passenger.csv
    - passengercard.csv
    - reservation.csv
    - ticket.csv
    - user_.csv

### Step 2: Run Data Loader SQL File

- After running the data generator, a data loader SQL file will be created in the 'sql/' directory.
- Execute this SQL file within the project to generate the complete dataset in the database.
