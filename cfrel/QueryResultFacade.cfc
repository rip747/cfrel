<cfcomponent output="false">

	<cfset variables.$class = {}>

	<cffunction name="init">
		<cfargument name="records" type="query" required="true">
		<cfargument name="metainfo" type="struct" required="true">
		<cfset variables.$class.result = arguments.records>
		<cfset variables.$class.prefix = arguments.metainfo>
		<cfreturn this>
	</cffunction>

	<cffunction name="getResult">
		<cfreturn variables.$class.result>
	</cffunction>
	
	<cffunction name="getPrefix">
		<cfreturn variables.$class.prefix>
	</cffunction>

</cfcomponent>