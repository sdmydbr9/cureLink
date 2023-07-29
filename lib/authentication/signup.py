from flask import Flask, request, jsonify
import os
import uuid
import requests
from google.cloud import storage
import io
import pymysql
import json
import base64
from flask_cors import CORS
from flask import Response

save = Flask(__name__)
CORS(save)

# Database connection settings
db_host = "localhost"
db_user = "vetuser"
db_password = "SUDH@m0y"
db_name = "vetdata"

# Function to fetch all medication data from the database
def fetch_all_medication_data():
    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name)

    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Retrieve all medication data
            sql = "SELECT * FROM medication"
            cursor.execute(sql)
            medication_data = cursor.fetchall()

            return medication_data

    except Exception as e:
        print("Error fetching medication data:", e)
        return []

    finally:
        # Close the connection
        connection.close()

# Function to fetch medication data from the database for a specific ID
def fetch_medication_data(medication_id):
    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name)

    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            # Retrieve medication data for the given ID
            sql = "SELECT * FROM medication WHERE id = %s"
            cursor.execute(sql, (medication_id,))
            medication_data = cursor.fetchone()

            return medication_data

    except Exception as e:
        print("Error fetching medication data:", e)
        return None

    finally:
        # Close the connection
        connection.close()

# Define your Google Cloud Storage bucket name
bucket_name = "pethealthwizard"

# Initialize the Google Cloud Storage client with credentials
storage_client = storage.Client.from_service_account_json("credentials.json")

def generate_unique_filename(filename):
    # Use UUID to generate a unique filename and keep the original extension
    unique_id = str(uuid.uuid4())
    _, extension = os.path.splitext(filename)
    return f"{unique_id}{extension}"

def upload_image_to_bucket(image_data, filename):
    try:
        # Generate a unique filename for the image
        unique_filename = generate_unique_filename(filename)
        bucket = storage_client.bucket(bucket_name)
        image_blob = bucket.blob(unique_filename)

        # Decode the base64 image data
        decoded_image_data = base64.b64decode(image_data)

        # Upload the image to the Google Cloud Storage bucket
        with io.BytesIO(decoded_image_data) as image_stream:
            image_blob.upload_from_file(image_stream, content_type="image/png")  # Adjust content_type as needed

        # Set the image URL to the publicly accessible URL of the uploaded image
        image_url = image_blob.public_url
        return image_url

    except Exception as e:
        raise RuntimeError("Failed to upload the image to the bucket.") from e



@save.route('/submit', methods=['POST'])
def submit_medication_form():
    data = request.get_json()

    # Extract form data
    category = data.get('category', '')
    name = data.get('name', '')
    dosage_list = data.get('dosageList', [])
    medication_list = data.get('medicationList', [])

    # Convert dosage and medication lists to JSON strings
    dosage_json = json.dumps(dosage_list, ensure_ascii=False)
    medication_json = json.dumps(medication_list, ensure_ascii=False)

    # Create a new database connection
    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name)

    try:
        with connection.cursor() as cursor:
            # Prepare the SQL statement to insert the data
            sql = "INSERT INTO medication (category, name, dosage, medication_details) VALUES (%s, %s, %s, %s)"

            # Prepare a list to hold all medication details for the current entry
            all_medication_details = []

            for medication_detail in medication_list:
                # Check if the image is already in base64 format
                image_data = medication_detail.get('image', '')
                image_url = ''

                print("Received image data:", image_data)
                print("Length of image data:", len(image_data))

                if image_data:
                    try:
                        # If image_data is a base64-encoded image, directly use it
                        # Generate a unique filename for the image
                        filename = generate_unique_filename("medication_image.png")
                        image_url = upload_image_to_bucket(image_data, filename)

                        print("Image uploaded successfully. Image URL:", image_url)

                    except Exception as e:
                        print("Error while processing the image:", str(e))
                        return jsonify({"error": "Failed to process the image."}), 500

                # Update the "image" key in the current medication_detail with the image URL
                medication_detail["image"] = image_url

                # Add the current medication_detail to the list
                all_medication_details.append(medication_detail)

            # Execute the SQL statement with all medication details as a single JSON string
            cursor.execute(sql, (category, name, dosage_json, json.dumps(all_medication_details, ensure_ascii=False)))

        # Commit the transaction
        connection.commit()

        return jsonify({"message": "Medication form submitted successfully."})

    except Exception as e:
        # Rollback the transaction in case of an error
        connection.rollback()
        print("Error while inserting data into the database:", str(e))
        return jsonify({"error": str(e)}), 500

    finally:
        # Close the connection
        connection.close()




def is_base64(s):
    try:
        return base64.b64encode(base64.b64decode(s)) == s
    except Exception:
        return False


@save.route('/medication', methods=['GET'])
def get_all_medication():
    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, database=db_name)

    try:
        with connection.cursor() as cursor:
            sql = "SELECT id, category, name, dosage, medication_details, images FROM medication"
            cursor.execute(sql)
            result = cursor.fetchall()

            # Convert blob data to base64 encoded string
            medication_data = []
            for row in result:
                medication = {
                    'id': row[0],
                    'category': row[1],
                    'name': row[2],
                    'dosage': json.loads(row[3]),
                    'medication_details': json.loads(row[4]),  # Corrected the key name to match the column name
                }

                # Handle the image data, if available
                if row[5]:
                    medication['image'] = base64.b64encode(row[5]).decode('utf-8')
                else:
                    medication['image'] = ''  # Set an empty string if image data is missing

                medication_data.append(medication)

            # Return the data with proper JSON formatting
            response_data = json.dumps(medication_data, ensure_ascii=False, indent=2)
            return Response(response_data, content_type='application/json')

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        connection.close()



@save.route('/medication/<int:medication_id>', methods=['GET'])
def get_medication_by_id(medication_id):
    # Fetch medication data from the database for a specific ID
    medication_data = fetch_medication_data(medication_id)

    if medication_data:
        try:
            # Decode the image from bytes to base64-encoded string
            if medication_data.get('images'):
                image_bytes = medication_data['images']
                encoded_image = base64.b64encode(image_bytes).decode('utf-8')
                medication_data['images'] = encoded_image

            # Convert any other bytes data to base64-encoded strings
            for key, value in medication_data.items():
                if isinstance(value, bytes):
                    encoded_value = base64.b64encode(value).decode('utf-8')
                    medication_data[key] = encoded_value

            # Convert dosage from string to a list of dictionaries
            if 'dosage' in medication_data:
                dosage_data = json.loads(medication_data['dosage'])
                medication_data['dosage'] = dosage_data

            # Convert medication_details from string to a dictionary
            if 'medication_details' in medication_data:
                medication_detail_data = json.loads(medication_data['medication_details'])
                medication_data['medication_details'] = medication_detail_data

            # Return the data with proper JSON formatting
            response_data = json.dumps(medication_data, ensure_ascii=False, indent=2)
            return Response(response_data, content_type='application/json')

        except Exception as e:
            error_msg = f"Failed to process the data: {str(e)}"
            return jsonify({"error": error_msg}), 500

    else:
        return jsonify({"error": "Medication not found."}), 404


if __name__ == '__main__':
    save.run(host='0.0.0.0', port=9999, ssl_context=('/etc/letsencrypt/live/pethealthwizard.tech/fullchain.pem', '/etc/letsencrypt/live/pethealthwizard.tech/privkey.pem'))
