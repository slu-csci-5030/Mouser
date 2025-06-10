from tokenize import String

import requests

RERUM_BASE = "http://localhost:3001/v1/api"

def get_token(path="rerum_server_nodejs/token.txt"):
    with open(path, "r") as f:
        return f.read().strip()

def submit_annotation(annotation_text, experiment_id):
    token = get_token()
    annotation = {
        "@context": "http://www.w3.org/ns/anno.jsonld",
        "type": "Annotation",
        "body": {
            "type": "TextualBody",
            "value": annotation_text
        },
        "target": experiment_id
    }
    headers = {"Authorization": f"Bearer {token}"}
    try:
        response = requests.post(f"{RERUM_BASE}/create", json=annotation, headers=headers)
        if response.status_code in (200, 201):
            data = response.json()
            annotation_id = data.get('@id', None)

            return True, annotation_id
        else:
            return False, response.text
    except Exception as e:
        return False, str(e)

def get_annotations(experiment_id):
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    query = {"target": experiment_id}
    try:
        response = requests.post(f"{RERUM_BASE}/query", json=query, headers=headers)
        if response.status_code == 200:
            return response.json(), None
        else:
            return None, response.text
    except Exception as e:
        return None, str(e)

def retrieve_annotation(annotation_id):
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}
    if "/" in annotation_id:
        ann_hash = annotation_id.split("/")[-1]
    else:
        ann_hash = annotation_id
    try:
        response = requests.get(f"{RERUM_BASE}/retrieve/{ann_hash}", headers=headers)
        if response.status_code == 200:
            return response.json(), None
        else:
            return None, f"Retrieve failed: {response.status_code} - {response.text}"
    except Exception as e:
        return None, str(e)

# Construct updated annotation
def create_updated_annotation(original_annotation, new_text):
    updated = {
        "@id": original_annotation.get("@id") or original_annotation.get("id"),
        "body": {
            "type": "TextualBody",
            "value": new_text,
            "format": "text/plain"
        },
        "target": original_annotation.get("target")
    }
    return updated

def update_annotation(annotation_id, new_text):
    token = get_token()
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # Step 1: Retrieve full original annotation
    full_annotation, err = retrieve_annotation(annotation_id)
    if not full_annotation:
        return False, f"Failed to retrieve original annotation: {err}"

    # Step 2: Construct the updated version
    updated = create_updated_annotation(full_annotation, new_text)

    # Step 3: Send the PUT request to update
    try:
        ann_hash = annotation_id.split("/")[-1] if "/" in annotation_id else annotation_id
        url = f"{RERUM_BASE}/update/{ann_hash}"
        print(f"Sending PUT to {url}")
        response = requests.put(url, json=updated, headers=headers)

        if response.status_code in (200, 201):
            return True, response.json()
        else:
            return False, f"Update failed: {response.status_code} - {response.text}"
    except Exception as e:
        return False, str(e)
