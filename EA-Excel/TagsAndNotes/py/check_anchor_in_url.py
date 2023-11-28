from urllib.parse import urlparse
import requests
from bs4 import BeautifulSoup
import rdflib

def is_rdf(url, content_type):
    return 'rdf' in content_type or url.endswith('.rdf') or url.endswith('.xml')

def check_anchor_in_rdf(url, anchor):
    graph = rdflib.Graph()
    graph.parse(url)
    for s, p, o in graph:
        if anchor == s.split('#')[-1] or anchor == p.split('#')[-1] or anchor == o.split('#')[-1]:
            return True
    return False

def check_anchor_in_html(url, anchor, parser):
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, features=parser)
            return bool(soup.find(id=anchor) or soup.find_all(attrs={"name": anchor}))
        return False
    except requests.RequestException as e:
        print(f"Error fetching page for URL {url}: {e}")
        return False

def check_anchor_in_url(url):
    parsed_url = urlparse(url)
    page_url = parsed_url.scheme + "://" + parsed_url.netloc + parsed_url.path
    anchor = parsed_url.fragment

    if not anchor:
        return True  # No anchor to check

    try:
        response = requests.head(url, allow_redirects=True, timeout=5)
        content_type = response.headers.get('Content-Type', '')

        if is_rdf(page_url, content_type):
            return check_anchor_in_rdf(page_url, anchor)
        else:
            parser = 'xml' if 'xml' in content_type else 'lxml'
            return check_anchor_in_html(page_url, anchor, parser)

    except requests.RequestException as e:
        print(f"Error fetching page for URL {url}: {e}")
        return False


# Example usage
url = "http://www.w3.org/2004/02/skos/core#Concept"
print(check_anchor_in_url(url))
