-- "Packages in Branch" (Branch gekozen in ProjectBrowser)

SELECT Package_ID, Name
FROM t_package
WHERE t_package.Package_ID IN (#Branch#)
ORDER BY Name