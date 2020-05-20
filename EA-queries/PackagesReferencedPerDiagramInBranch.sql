-- "Packages referenced per Diagram in Branch" (Branch gekozen in ProjectBrowser)

SELECT DISTINCT t_diagram.Diagram_ID, t_diagram.Name, t_package.Name
FROM
	((t_diagramobjects INNER JOIN t_diagram ON t_diagramobjects.Diagram_ID = t_diagram.Diagram_ID)
	INNER JOIN t_object ON t_object.Object_ID = t_diagramobjects.Object_ID)
	INNER JOIN t_package ON t_package.Package_ID = t_object.Package_ID
WHERE t_diagram.Package_ID IN (#Branch#)
ORDER BY t_diagram.Name, t_package.Name