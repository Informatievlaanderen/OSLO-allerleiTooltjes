-- "Diagrams in Branch" (Branch gekozen in ProjectBrowser)

SELECT Diagram_ID, Name
FROM t_diagram
WHERE t_diagram.Package_ID IN (#Branch#)
ORDER BY Name