import requests

def get_redirected_url(starting_url):
    """
    Check the final redirected URL of a starting URL.

    Parameters:
    starting_url (str): The URL to start with.

    Returns:
    str: The final redirected URL.
    """
    try:
        response = requests.get(starting_url)
        # Check if the response was successful
        if response.status_code == 200:
            return response.url
        else:
            return f"Error: Request failed with status code {response.status_code}"
    except Exception as e:
        return f"Error: {str(e)}"

# Example usage
starting_url = "http://www.opengis.net/ont/sf#Point"
redirected_url = get_redirected_url(starting_url)
print(redirected_url)
