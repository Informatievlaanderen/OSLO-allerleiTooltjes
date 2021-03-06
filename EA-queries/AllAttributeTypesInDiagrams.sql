-- "All Attributes and their types in Diagrams" (Diagram_ID in <Search Term> - meerdere Diagram_IDs gescheiden door komma's toegelaten)
-- NOTE: Scope is niet beperkt tot een package of een branh

SELECT t_diagram.Diagram_ID, t_diagram.Name AS DiagramName, t_package.Name & ":" & t_object.Name & "." & t_attribute.Name As AttributeName, t_attribute.Type AS AttributeType
FROM
	(((t_diagramobjects INNER JOIN t_diagram ON t_diagramobjects.Diagram_ID = t_diagram.Diagram_ID)
	INNER JOIN t_object ON t_object.Object_ID = t_diagramobjects.Object_ID)
	INNER JOIN t_package ON t_object.Package_ID = t_package.Package_ID)
	INNER JOIN t_attribute ON t_attribute.Object_ID = t_object.Object_ID
WHERE
	t_diagram.Diagram_ID IN (<Search Term>)
	
ORDER BY t_attribute.Type