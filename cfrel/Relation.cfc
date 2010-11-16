<cfcomponent output="false">
	<cfinclude template="functions.cfm" />
	
	<cffunction name="init" returntype="struct" access="public" hint="Constructor">
		<cfscript>
			variables.sql = {
				select = [],
				from = false,
				joins = [],
				joinParameters = [],
				wheres = [],
				whereParameters = [],
				orders = []
			};
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="new" returntype="struct" access="public" hint="Create new instance of relation">
		<cfscript>
			return CreateObject("component", "cfrel.relation").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="clone" returntype="struct" access="public" hint="Duplicate the relation object">
		<cfscript>
			return Duplicate(this);
		</cfscript>
	</cffunction>
	
	<cffunction name="select" returntype="struct" access="public" hint="Append to the SELECT clause of the relation">
		<cfscript>
			var loc = {};
			switch (StructCount(arguments)) {
				
				// do not allow empty call
				case 0:
					throwException("Arguments are required to select()", "Expression");
					break;
					
				// treat single arguments as a list and append each list item
				case 1:
					loc.arguments = ListToArray(arguments[1]);
					loc.iEnd = ArrayLen(loc.arguments);
					for (loc.i = 1; loc.i LTE loc.iEnd; loc.i++)
						ArrayAppend(sql.select, loc.arguments[loc.i]);
					break;
				
				// loop and append if many arguments are passed
				default:
					for (loc.key in arguments)
						ArrayAppend(sql.select, arguments[loc.key]);
					break;
			}
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="include" returntype="struct" access="public" hint="Add a JOIN to the relation using predefined relationships">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="join" returntype="struct" access="public" hint="Add a JOIN to the relation">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="where" returntype="struct" access="public" hint="Append to the WHERE clause of the relation">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="group" returntype="struct" access="public" hint="Append to GROUP BY clause of the relation">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="order" returntype="struct" access="public" hint="Append to ORDER BY clause of the relation">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="limit" returntype="struct" access="public" hint="Restrict the number of records when querying">
		<cfargument name="value" type="numeric" required="true" />
		<cfscript>
			sql.limit = Int(arguments.value);
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="offset" returntype="struct" access="public" hint="Skip some records when querying">
		<cfargument name="value" type="numeric" required="true" />
		<cfscript>
			sql.offset = Int(arguments.value);
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="paginate" returntype="struct" access="public" hint="Calculate LIMIT and OFFSET with page number and per-page constraint">
		<cfargument name="page" type="numeric" required="true" />
		<cfargument name="perPage" type="numeric" required="true" />
		<cfscript>
			
			// throw error if bad values are passed
			if (arguments.page LT 1 OR arguments.perPage LT 1)
				throwException("Page and per-page must be greater than zero", "Expression");
			
			// calculate limit and offset
			sql.limit = Int(arguments.perPage);
			sql.offset = (Int(arguments.page) - 1) * sql.limit;
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="toSql" returntype="string" access="public" hint="Convert relational data into a SQL string">
	</cffunction>
</cfcomponent>