-- "Uri tags containing "data.vlaanderen.be" on Classifiers (Classes, DataTypes, Enumerations), Attributes and Connectors in Branch" (Branch gekozen in ProjectBrowser)
-- NOTE: Toont ook een regel voor niet toegekende uri's - vandaar sortering DESC...

-- Class, Datatype, Enumeration
SELECT 
	(SELECT t_package.Name FROM t_package WHERE t_object.Package_ID = t_package.Package_ID) & ":" & t_object.Name AS Element,
    Object_Type AS Aard,
    (SELECT top 1 t_objectproperties.value FROM t_objectproperties WHERE t_objectproperties.property = 'uri' AND t_objectproperties.Object_ID = t_object.Object_ID AND t_objectproperties.value LIKE "#WC#data.vlaanderen.be#WC#") AS 'uri'
FROM t_object
WHERE (Object_Type = "Class" OR Object_Type = "DataType" OR Object_Type = "Enumeration")
	AND t_object.Package_ID IN (#Branch#)


UNION ALL 
-- Attribute
SELECT 
	(SELECT t_package.Name FROM t_package WHERE t_object.Package_ID = t_package.Package_ID) & ":" & t_object.Name & "." & t_attribute.Name AS Element,
	"Attribute" AS Aard,
	(SELECT top 1 t_attributetag.VALUE FROM t_attributetag WHERE t_attributetag.Property = 'uri' AND t_attributetag.ElementID = t_attribute.id AND t_attributetag.VALUE LIKE "#WC#data.vlaanderen.be#WC#") AS 'uri'
	FROM t_object
    INNER JOIN t_attribute ON t_attribute.Object_ID = t_object.Object_ID
WHERE t_object.Package_ID IN (#Branch#)


UNION ALL 
-- Connector - richtingspijl niet in acht genomen - associatieklassen niet in acht genomen
SELECT 
	(SELECT package_from.Name FROM t_package package_from WHERE object_from.Package_ID = package_from.Package_ID) & ":" & object_from.Name & " | " & t_connector.Name & " | " & (SELECT package_to.Name FROM t_package package_to where object_to.Package_ID = package_to.Package_ID) & ":" & object_to.Name AS Element,
    "Associatie" AS Aard,                 
    (SELECT top 1 t_connectortag.VALUE FROM t_connectortag WHERE t_connectortag.Property = 'uri' AND t_connectortag.ElementID = t_connector.connector_id AND t_connectortag.VALUE LIKE "#WC#data.vlaanderen.be#WC#") AS 'uri'
FROM
	(t_connector INNER JOIN t_object object_from ON t_connector.Start_Object_ID = object_from.Object_ID)
    INNER JOIN t_object object_to ON object_to.Object_ID = t_connector.End_Object_ID
WHERE (t_connector.Connector_Type  = "Association" OR t_connector.Connector_Type  = "Aggregation" OR t_connector.Connector_Type  = "Composition")
	AND object_from.Package_ID IN (#Branch#)


ORDER BY 3 DESC