import json
import requests
from flask import Flask, request, jsonify, _app_ctx_stack
from injections import calculate_injection_medication
from reconstitutable import calculate_reconstitutable_medication
from tablets import calculate_tablet_medication
from flask_cors import CORS

app = Flask(__name__)

@app.after_request
def add_cors_headers(response):
    print("Adding CORS headers...")
    response.headers['Access-Control-Allow-Origin'] = '*'  # Allow requests from any origin
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    return response


def parse_dose_range(dose_rate_str):
    if '-' in dose_rate_str:
        start, end = dose_rate_str.split('-')
        dose_range = (float(start), float(end))
    else:
        dose_range = float(dose_rate_str)
    return dose_range

def calculate_medication(name, species, body_weight):
    # Make API request
    api_url = f'https://pethealthwizard.tech:8081/api/medication/{name}/{species}'
    print(f"Sending request to URL: {api_url}")
    response = requests.get(api_url)
    print(f"API Response: {response.text}")

    # Check if the response status code indicates success (200)
    if response.status_code == 200:
        try:
            data = response.json()
        except json.JSONDecodeError as e:
            print(f"JSON Decode Error: {e}")
            return jsonify({'error': 'Invalid JSON response from the API'})

        if 'dosage' in data:
            dosage = data['dosage'][0]
            dose_rate_str = dosage['dosage']
            dose_range = parse_dose_range(dose_rate_str)

            medication_body_weight = float(body_weight)
            medication_details = dosage['medication_details']

            result = {
                'medication': name,
                'species': species,
                'dose_rate': dose_range,
                'body_weight': medication_body_weight,
                'medications': [],
            }

            for medication in medication_details:
                medication_type = medication['type']

                if medication_type and medication_type.lower() in ['inj', 'vial']:
                    concentration = float(medication['concentration'])
                    medication_name = f"{medication['name']} {medication['concentration']}{medication['unit']}"
                    volume = calculate_injection_medication(dose_rate_str, medication_body_weight, concentration)
                    if isinstance(volume, tuple):
                        volume_str = f"{volume[0]}-{volume[1]}"
                    else:
                        volume_str = str(volume)
                    calculated_medication = {
                        'name': medication_name,
                        'volume': volume_str,
                        'type': medication_type
                    }
                    result['medications'].append(calculated_medication)
                elif medication_type and medication_type.lower() in ['reconstitutable injectables', 'reconstitutable solution']:
                    medication_name = medication['name']
                    presentation = float(medication['presentation'])
                    volume_water = float(medication['value'])
                    dose_rate_parts = dose_rate_str.split('-')

                    if len(dose_rate_parts) == 1:
                        dose_rate_value = float(dose_rate_parts[0])
                        concentration, injection_volume = calculate_reconstitutable_medication(
                            presentation, volume_water, medication_body_weight, dose_rate_value)
                        calculated_medication = {
                            'name': medication_name,
                            'concentration': concentration,
                            'injection_volume_range': str(injection_volume),
                            'type': medication_type
                        }
                        result['medications'].append(calculated_medication)
                    elif len(dose_rate_parts) == 2:
                        dose_rate_start = float(dose_rate_parts[0])
                        dose_rate_end = float(dose_rate_parts[1])
                        concentration, injection_volume_start = calculate_reconstitutable_medication(
                            presentation, volume_water, medication_body_weight, dose_rate_start)
                        concentration, injection_volume_end = calculate_reconstitutable_medication(
                            presentation, volume_water, medication_body_weight, dose_rate_end)
                        injection_volume_range = f"{injection_volume_start}-{injection_volume_end}"
                        calculated_medication = {
                            'name': medication_name,
                            'concentration': concentration,
                            'injection_volume_range': injection_volume_range,
                            'type': medication_type
                        }
                        result['medications'].append(calculated_medication)

                elif medication_type and medication_type.lower() == 'tab':
                    concentration_str = medication['concentration']
                    concentration = float(''.join(filter(str.isdigit, concentration_str)))
                    if concentration:
                        medication_name = f"{medication['name']} {medication['concentration']}{medication['unit']}"
                    else:
                        medication_name = medication['name']

                    dose_rate_parts = dose_rate_str.split('-')
                    if len(dose_rate_parts) == 1:
                        dose_rate_value = float(dose_rate_parts[0])
                        tablets_range = calculate_tablet_medication(concentration, dose_rate_value, medication_body_weight)
                    elif len(dose_rate_parts) == 2:
                        dose_rate_start = float(dose_rate_parts[0])
                        dose_rate_end = float(dose_rate_parts[1])
                        tablets_range = calculate_tablet_medication(concentration, (dose_rate_start, dose_rate_end), medication_body_weight)
                    else:
                        tablets_range = None

                    if isinstance(tablets_range, tuple):
                        volume_str = f"{tablets_range[0]}-{tablets_range[1]}"
                    else:
                        volume_str = str(tablets_range)
                    calculated_medication = {
                        'name': medication_name,
                        'tablets_range': volume_str if volume_str else dose_rate_str,
                        'type': medication_type
                    }
                    result['medications'].append(calculated_medication)
                else:
                    continue

            return jsonify(result)

        elif 'medications' in data:
            medications = data['medications']
            result = {
                'medications': medications
            }
            return jsonify(result)

        else:
            return jsonify({'error': 'Unknown response format'})

    else:
        print(f"Failed to retrieve data. Status code: {response.status_code}")
        return jsonify({'error': f'Failed to retrieve data. Status code: {response.status_code}'})


@app.route('/calculate-medication/<string:name>/<string:species>/<string:body_weight>/', methods=['GET'])

def calculate_medication_route(name, species, body_weight):
    try:
        body_weight = float(body_weight)
    except ValueError:
        return jsonify({'error': 'Invalid body weight format'})

    print(f"Calculating medication for: {name}/{species}/{body_weight}")
    response = calculate_medication(name, species, body_weight)

    if isinstance(response, dict):
        # If the response is already a JSON-serializable dictionary, return it directly
        return jsonify(response)
    else:
        # If the response is a Flask Response object, extract the data and return as JSON
        data = response.get_json()
        return jsonify(data)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, ssl_context=('/etc/letsencrypt/live/pethealthwizard.tech/fullchain.pem', '/etc/letsencrypt/live/pethealthwizard.tech/privkey.pem'))
