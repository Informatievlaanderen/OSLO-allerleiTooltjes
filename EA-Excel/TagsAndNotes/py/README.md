# Validation python script `validation.py`

## Overview
validation.py is a Python script designed to validate URIs in an Excel file "TagsAndNotes.xlsm", the scraped excel file of the macro PullFromEA inside TagsAndNotes. Its main purpose is to identify dead links and incorrect anchors in the URIs listed in this file.

The script highlights the cells in the TagsAndNotes excel file where errors potentially occur:
![image](https://github.com/Informatievlaanderen/OSLO-allerleiTooltjes/assets/15192194/65baa259-6d79-4c23-bc8c-05191ff10c8c)

## Quick start

```python
pip install -r requirements.txt
```

```python
python validation.py
```

## Features
The script provides several key features:

### URI Extraction
Extracts all URIs from the 'uri' column in the 'TagsAndNotes' sheet of the "TagsAndNotes.xlsm" file.

### Dead Link Detection
Checks each URI to determine if it is accessible (i.e., not a dead link).

### Anchor Verification
Verifies the correctness of anchors in URIs. This involves checking whether the specified anchor exists in the target document, which can be either an HTML page or an RDF document.

### Error Highlighting
Marks problematic URIs directly in the Excel file by changing the background color of the corresponding cell to red for easier identification.

### Requirements
The script requires the following Python packages:

openpyxl
requests
bs4 (BeautifulSoup)
rdflib
urllib.parse
os
shutil
time

