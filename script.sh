!#/bin/sh

read -p "enter connection string: " connectionString
read -p "enter dbcontext name: " dbContextName

if  [ "${dbContextName: -7}" != "Context" ] || [ "${dbContextName: -7}" != "context" ];
then
	dbContextName="${dbContextName}Context"
fi

# install all needed nuget packages
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.VisualStudio.Web.Codegeneration
dotnet add package Microsoft.VisualStudio.Web.Codegeneration.Design

# scaffold dbcontext and models
dotnet ef dbcontext scaffold "$connectionString" Microsoft.EntityFrameworkCore.SqlServer -o Models -d -f -c $dbContextName

# scaffold all controllers with views
for filename in ./Models/*; do
	
	# remove './' from filename
	filename="${filename:9}"
	
	# remove '.cs' from filename
	filename="${filename%???}"
 
	if [ "${filename}" != "ErrorViewModel" ] && [ "${filename: -7}" != "Context" ];
	then
		echo "${filename: -7}"
		dotnet aspnet-codegenerator --project . controller -name ${filename}Controller -m $filename -dc $dbContextName --no-build -c Release -outDir ./Controllers/
	fi
done
