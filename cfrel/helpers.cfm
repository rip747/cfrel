<!----------------------
--- Helper Functions ---
----------------------->

<cffunction name="relation" returntype="struct" access="private" hint="Created a new Relation instance">
	<cfreturn CreateObject("component", "cfrel.Relation").init(argumentCollection=arguments) />
</cffunction>

<cffunction name="throwException" returntype="void" access="private" hint="Throw an exception with CFTHROW">
	<cfargument name="message" type="string" required="true" />
	<cfargument name="type" type="string" default="custom_type" />
	<cfargument name="detail" type="string" required="false" />
	<cfthrow attributeCollection="#arguments#" />
</cffunction>

<cffunction name="typeOf" returntype="string" access="private" hint="Return type of object as a string">
	<cfargument name="obj" type="any" required="true" />
	<cfscript>
		var loc = {};
		loc.meta = getMetaData(arguments.obj);
		
		// if the argument is a component/object, return its path
		if (IsArray(loc.meta) EQ false AND StructKeyExists(loc.meta, "fullname"))
			if (REFindNoCase("^models\.", loc.meta.fullname) EQ 0)
				return loc.meta.fullname;
			else
				return "model";
			
		// the rest are simple
		else if (IsCustomFunction(arguments.obj))
			return "function";
		else if (IsBinary(arguments.obj))
			return "binary";
		else if (IsArray(arguments.obj))
			return "array";
		else if (IsQuery(arguments.obj))
			return "query";
		else if (IsStruct(arguments.obj))
			return "struct";
		else if (IsNull(arguments.obj))
			return "null";
		else
			return "simple";
	</cfscript>
</cffunction>