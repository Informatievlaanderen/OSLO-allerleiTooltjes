-- "Attributes and their types, for types not linked to a classifier, in Diagrams" (Diagram_ID in <Search Term> - meerdere Diagram_IDs gescheiden door komma's toegelaten)
-- NOTE: Scope is niet beperkt tot een package of een branch
-- NOTE: Volgende uitgesloten uit de output:
--        - attributen met leeg type
--        - attributen met type dat niet mag gelinkt worden aan een classifier (cfr. modelling rules)
--        - attributen behorend tot een parent element waarop een tag ignore=true
--        - attributes waarop een tag ignore=true

SELECT t_diagram.Diagram_ID, t_diagram.Name AS DiagramName, t_package.Name & ":" & t_object.Name & "." & t_attribute.Name AS AttributeName, t_attribute.Type AS AttributeType
FROM
	(((t_diagramobjects INNER JOIN t_diagram ON t_diagramobjects.Diagram_ID = t_diagram.Diagram_ID)
	INNER JOIN t_object ON t_object.Object_ID = t_diagramobjects.Object_ID)
	INNER JOIN t_package ON t_object.Package_ID = t_package.Package_ID)
	INNER JOIN t_attribute ON t_attribute.Object_ID = t_object.Object_ID
WHERE
	t_diagram.Diagram_ID IN (<Search Term>)
	AND (t_attribute.Classifier IS NULL OR t_attribute.Classifier = '0')
	AND t_attribute.Type IS NOT NULL
	AND t_attribute.Type NOT IN ('Boolean', 'Date', 'DateTime', 'Double', 'Duration', 'HTML', 'Integer', 'LangString', 'Literal', 'Month', 'MonthDay', 'String', 'Time', 'URI', 'Year', 'YearMonth')
	AND 'true' NOT IN (SELECT t_objectproperties.Value FROM t_objectproperties WHERE t_objectproperties.Property = 'ignore' AND t_objectproperties.Object_ID = t_object.Object_ID)
	AND 'true' NOT IN (SELECT t_attributetag.VALUE FROM t_attributetag WHERE t_attributetag.Property = 'ignore' AND t_attributetag.ElementID = t_attribute.ID)
ORDER BY 2, 3