<!----------------------
--- Helper Functions ---
----------------------->

<cffunction name="relation" returntype="struct" access="private" hint="Created a new Relation instance">
	<cfreturn CreateObject("component", addCfcPrefix("cfrel.Relation")).init(argumentCollection=arguments) />
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
				return stripCfcPrefix(loc.meta.fullname);
			else
				return "model";
			
		// a few are easy checks
		else if (IsCustomFunction(arguments.obj))
			return "function";
		else if (IsBinary(arguments.obj))
			return "binary";
		else if (IsArray(arguments.obj))
			return "array";
		else if (IsQuery(arguments.obj))
			return "query";
		// this function requires a value for arguments.obj so we could never return null	
		// else if (!StructKeyExists(arguments, "obj"))
		// 	return "null";
				
		// some will just be structs, but nodes will have $class set
		else if (IsStruct(arguments.obj))
		{
			if (StructKeyExists(arguments.obj, "$class"))
			{
				return arguments.obj.$class; 
			}
			return "struct";
		}	
		// everything else is a simple value
		else
			return "simple";
	</cfscript>
</cffunction>

<cffunction name="addCfcPrefix" returntype="string" access="private" hint="Append CFC prefix to path">
	<cfargument name="path" type="string" required="true">
	<cfscript>
		if (IsDefined("application.cfrel.cfcPrefix"))
			arguments.path = ListAppend(application.cfrel.cfcPrefix, arguments.path, ".");
	</cfscript>
	<cfreturn arguments.path />
</cffunction>

<cffunction name="stripCfcPrefix" returntype="string" access="private" hint="Remove CFC prefix from path">
	<cfargument name="path" type="string" required="true">
	<cfscript>
		if (IsDefined("application.cfrel.cfcPrefix"))
			arguments.path = REReplace(arguments.path, "^" & application.cfrel.cfcPrefix & "\.", "");
	</cfscript>
	<cfreturn arguments.path />
</cffunction>

<cffunction name="$arrayFind" returntype="boolean" access="public">
	<cfargument name="thearray" type="array" required="true">
	<cfargument name="value" type="string" required="true">
	<cfif ListFind(ArrayToList(arguments.thearray, chr(7)), arguments.value, chr(7))>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>

<cffunction name="$arrayFindNoCase" returntype="boolean" access="public">
	<cfargument name="thearray" type="array" required="true">
	<cfargument name="value" type="string" required="true">
	<cfif ListFindNoCase(ArrayToList(arguments.thearray, chr(7)), arguments.value, chr(7))>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>

<cffunction name="$arrayContains" returntype="boolean" access="public">
	<cfargument name="thearray" type="array" required="true">
	<cfargument name="value" type="string" required="true">
	<cfif ListContains(ArrayToList(arguments.thearray, chr(7)), arguments.value, chr(7))>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>

<cffunction name="$arrayContainsNoCase" returntype="boolean" access="public">
	<cfargument name="thearray" type="array" required="true">
	<cfargument name="value" type="string" required="true">
	<cfif ListContainsNoCase(ArrayToList(arguments.thearray, chr(7)), arguments.value, chr(7))>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>