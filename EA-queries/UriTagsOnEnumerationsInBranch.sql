-- "URI Tags on Enumerations in Branch" (Branch gekozen in ProjectBrowser)

SELECT 
	(SELECT t_package.Name FROM t_package WHERE t_object.Package_ID = t_package.Package_ID) & ":" & t_object.Name AS Element,
    Object_Type AS Aard,
    (SELECT top 1 t_objectproperties.value FROM t_objectproperties WHERE t_objectproperties.property = 'uri' AND t_objectproperties.Object_ID = t_object.Object_ID) AS 'uri'
FROM t_object
WHERE (Object_Type = "Enumeration")
	AND t_object.Package_ID IN (#Branch#)

ORDER BY 1, 2