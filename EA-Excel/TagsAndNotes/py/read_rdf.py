import requests

def search_for_anchor_in_rdf(rdf_url, anchor):
    try:
        response = requests.get(rdf_url)
        response.raise_for_status()
        if anchor in response.text:
            return True
        else:
            return False

    except requests.RequestException as e:
        print(f"An error occurred while fetching RDF data: {e}")
        return None

def convert_base_url(base_url):
    # Splitting the base URL at '#' to separate the URL part and the anchor
    parts = base_url.split('#')
    if len(parts) != 2:
        raise ValueError("Invalid base URL format. It should contain an anchor.")

    url_part, anchor = parts

    # Construct the RDF URL by inserting 'ontologies/' and appending '.rdf'
    url_parts = url_part.split('/')
    rdf_url = '/'.join(url_parts[:3]) + '/ontologies/' + '/'.join(url_parts[3:]) + '.rdf'

    return rdf_url, anchor

# Example usage
base_url = "http://def.isotc211.org/iso19156/2011/SamplingPoint#SF_SamplingPoint"
rdf_url, anchor = convert_base_url(base_url)


print(search_for_anchor_in_rdf(rdf_url, anchor))
