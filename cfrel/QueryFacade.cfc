<cfcomponent output="false">

	<cfset variables.$class = {}>
	<cfset variables.$class.accessibleAttributes = "name,blockFactor,cachedAfter,cachedWithin,dataSource,dbtype,debug,maxRows,password,timeout,username,sql">
	<cfset variables.$class.accessibleParamAttributes = "name,value,cfsqltype,list,maxlength,null,scall,separator">
	<cfset variables.$class.attributes = {}>
	<cfset variables.$class.params = []>
	<cfset variables.$class.data = {}>
	
	<cffunction name="execute">
		<cfset var loc = {}>
		<cfset setAttributes(argumentCollection=arguments)>
		<cfset loc.r = performQuery(parseSql())>
		<cfreturn loc.r>
	</cffunction>
	
	<cffunction name="clearAttributes">
		<cfset StructClear(variables.$class.attributes)>
	</cffunction>
	
	<cffunction name="clearParams">
		<cfset ArrayClear(variables.$class.params)>
	</cffunction>
	
	<cffunction name="addParam">
		<cfset var loc = {}>
		<cfloop collection="#arguments#" item="loc.i">
			<cfif not ListFindNoCase(variables.$class.accessibleParamAttributes, loc.i)>
				<cfset StructDelete(arguments, loc.i, false)>
			</cfif>
		</cfloop>
		<cfif not StructIsEmpty(arguments)>
			<cfset ArrayAppend(variables.$class.params, arguments)>
		</cfif>
	</cffunction>
	
	<cffunction name="getResult">
		<cfreturn variables.$class.data.result>
	</cffunction>
	
	<cffunction name="getPrefix">
		<cfreturn variables.$class.data.prefix>
	</cffunction>
	
	<!--- private methods: everyone of these was "borrowed" from Railo --->
	
	<cffunction name="parseSql" returntype="Array" access="private">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfset loc.result = []>
		<cfset loc.sql = getSql()>
		<cfset loc.namedParams = getNamedParams()>
		<cfset loc.positionalParams = getPositionalParams()> 
		<cfset loc.positionalCursor = 1>
		<cfset loc.str = "">
		<cfset loc.cursor = 1>
		<cfset loc.regex = ":[a-z]*|\?">
		<cfset loc.match = refindNoCase(loc.regex, loc.sql, loc.cursor, true)>
		
		<!--- if no match there is no need to enter in the loop --->
		<cfif loc.match.pos[1] eq 0>
			<cfset loc.temp = {type='String',value=loc.sql}>
			<cfset ArrayAppend(loc.result, loc.temp)>
			<cfreturn loc.result>
		</cfif>
		
		<cfloop condition="#loc.cursor# neq 0">
			<cfset loc.match = refindNoCase(loc.regex, loc.sql, loc.cursor, true)>
			
			<cfif loc.match.pos[1] gt 0>
				<!--- string from cursor to match --->			
				<cfset loc.str = mid(loc.sql, loc.cursor, loc.match.pos[1] - loc.cursor)>
				<cfset loc.temp = {type='String',value=loc.str}>
				<cfset ArrayAppend(loc.result, loc.temp)>
				
				<!--- add match --->
				<cfset loc.str = mid(loc.sql, loc.match.pos[1], loc.match.len[1])>
				<cfif left(loc.str, 1) eq ":">
					<cfset loc.temp = findNamedParam(loc.namedParams, right(loc.str, len(loc.str) - 1))>
					<cfif not StructIsEmpty(loc.temp)>
						<cfset ArrayAppend(loc.result, loc.temp)>
					</cfif>
				<cfelse>
					<cfset ArrayAppend(loc.result, loc.positionalParams[loc.positionalCursor])>
					<cfset positionalCursor ++>				
				</cfif>
			</cfif>
			
			<!--- point the cursor after the match --->
			<cfset loc.cursor = loc.match.pos[1] + loc.match.len[1]>	
		</cfloop>
		
		<cfreturn loc.result>	
	</cffunction>
	
	
	<cffunction name="getNamedParams" access="private" returntype="array">
		<cfset var loc = {}>
		<cfset loc.params = getParams()>
		<cfset loc.result = []>
		
		<cfloop array="#loc.params#" index="loc.item">
			<cfif structKeyExists(loc.item, "name")>
				<cfset ArrayAppend(loc.result, loc.item)>
			</cfif>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="getPositionalParams" access="private" returntype="array">
		<cfset var loc = {}>
		<cfset loc.params = getParams()>
		<cfset loc.result = []>

		<cfloop array="#loc.params#" index="loc.item">
			<cfif not structKeyExists(loc.item, "name")>
				<cfset ArrayAppend(loc.result, loc.item)>
			</cfif>
		</cfloop>
	
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="findNamedParam" access="private" returntype="struct">
		<cfargument name="params" type="array" required="true">
		<cfargument name="name" type="string" required="true">
		<cfset var loc = {}>
		<cfset loc.ret = {}>
		<cfloop array="#loc.params#" index="loc.item">
			<cfif structKeyExists(loc.item, "name") AND arguments.name eq loc.item.name>
				<cfreturn loc.item>
			</cfif>
		</cfloop>
		<cfreturn loc.ret>
	</cffunction>
	
	<cffunction name="performQuery" access="private" returntype="any">
		<cfargument name="sql" type="array" required="true">
		<cfset var loc = {}>
		<cfset loc.args = duplicate(variables.$class.attributes)>
		<cfset loc.args.result = "loc.ret">
		<cfset loc.args.name = "loc.queryname">
		<cfset loc.sql = loc.args.sql>
		<cfset StructDelete(loc.args, "sql", false)>
		<cfquery attributeCollection="#loc.args#">#loc.sql#</cfquery>
		<cfset loc.obj = createobject("component", "QueryResultFacade").init(loc.queryname, loc.ret)>
		<cfreturn loc.obj>
		<!--- <cfquery attributeCollection="#loc.args#"><cfloop array="#loc.sql#" index="loc.i"><cfif IsStruct(loc.i)><cfset loc.queryParamAttributes = $CFQueryParameters(loc.i)><cfif StructKeyExists(loc.queryParamAttributes, "useNull")>NULL<cfelseif StructKeyExists(loc.queryParamAttributes, "list")><cfif arguments.parameterize>(<cfqueryparam attributeCollection="#loc.queryParamAttributes#">)<cfelse>(#PreserveSingleQuotes(loc.i.value)#)</cfif><cfelse><cfif arguments.parameterize><cfqueryparam attributeCollection="#loc.queryParamAttributes#"><cfelse>#$quoteValue(loc.i.value)#</cfif></cfif><cfelse><cfset loc.i = Replace(PreserveSingleQuotes(loc.i), "[[comma]]", ",", "all")>#PreserveSingleQuotes(loc.i)#</cfif>#chr(13)##chr(10)#</cfloop><cfif arguments.limit>LIMIT #arguments.limit#<cfif arguments.offset>#chr(13)##chr(10)#OFFSET #arguments.offset#</cfif></cfif></cfquery> --->
	</cffunction>

	<!--- accessors --->
	<cffunction name="setName">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.name = arguments.value>
	</cffunction>
	<cffunction name="getName">
		<cfreturn variables.$class.attributes.name>
	</cffunction>
	
	<cffunction name="setBlockFactor">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.blockFactor = arguments.value>
	</cffunction>
	<cffunction name="getBlockFactor">
		<cfreturn variables.$class.attributes.BlockFactor>
	</cffunction>
	
	<cffunction name="setCachedAfter">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.CachedAfter = arguments.value>
	</cffunction>
	<cffunction name="getCachedAfter">
		<cfreturn variables.$class.attributes.CachedAfter>
	</cffunction>
	
	<cffunction name="setCachedWithin">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.CachedWithin = arguments.value>
	</cffunction>
	<cffunction name="getCachedWithin">
		<cfreturn variables.$class.attributes.CachedWithin>
	</cffunction>
	
	<cffunction name="setDataSource">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.DataSource = arguments.value>
	</cffunction>
	<cffunction name="getDataSource">
		<cfreturn variables.$class.attributes.DataSource>
	</cffunction>
	
	<cffunction name="setDBtype">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.DBtype = arguments.value>
	</cffunction>
	<cffunction name="getDBtype">
		<cfreturn variables.$class.attributes.DBtype>
	</cffunction>
	
	<cffunction name="setDebug">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.Debug = arguments.value>
	</cffunction>
	<cffunction name="getDebug">
		<cfreturn variables.$class.attributes.Debug>
	</cffunction>
	
	<cffunction name="setMaxRows">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.MaxRows = arguments.value>
	</cffunction>
	<cffunction name="getMaxRows">
		<cfreturn variables.$class.attributes.MaxRows>
	</cffunction>
	
	<cffunction name="setPassword">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.Password = arguments.value>
	</cffunction>
	<cffunction name="getPassword">
		<cfreturn variables.$class.attributes.Password>
	</cffunction>
	
	<cffunction name="setTimeout">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.Timeout = arguments.value>
	</cffunction>
	<cffunction name="getTimeout">
		<cfreturn variables.$class.attributes.Timeout>
	</cffunction>
	
	<cffunction name="setUsername">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.Username = arguments.value>
	</cffunction>
	<cffunction name="getUsername">
		<cfreturn variables.$class.attributes.Username>
	</cffunction>
	
	<cffunction name="setSQL">	
		<cfargument name="value" type="string" required="true">
		<cfset variables.$class.attributes.SQL = arguments.value>
	</cffunction>
	<cffunction name="getSQL">
		<cfreturn variables.$class.attributes.SQL>
	</cffunction>

	<cffunction name="setAttributes">
		<cfset var loc = {}>
		<cfloop collection="#arguments#" item="loc.i">
			<cfif not ListFindNoCase(variables.$class.accessibleAttributes, loc.i)>
				<cfset StructDelete(arguments, loc.i, false)>
			</cfif>
		</cfloop>
		<cfif not StructIsEmpty(arguments)>
			<cfset structAppend(variables.$class.attributes, arguments)>
		</cfif>
	</cffunction>
	<cffunction name="getAttributes">
		<cfargument name="attributeList" type="string" required="false" default="">
		<cfset var loc = {}>
		
		<cfif not Len(arguments.attributeList)>
			<cfreturn variables.$class.attributes>
		</cfif>
		
		<cfset loc.ret = {}>
		<cfloop list="#arguments.attributeList#" index="loc.i">
			<cfset loc.i = trim(loc.i)>
			<cfif StructKeyExists(variables.$class.attributes, loc.i)>
				<cfset StructInsert(loc.ret, loc.i, variables.$class.attributes[loc.i])>
			</cfif>
		</cfloop>
		
		<cfreturn loc.ret>
	</cffunction>
	
	<cffunction name="getParams">
		<cfreturn variables.$class.params>
	</cffunction>

</cfcomponent>