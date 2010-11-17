<cfcomponent extends="tests.TestCase" output="false">
	
	<cffunction name="setup" returntype="void" access="public">
		<cfscript>
			super.setup();
			variables.cfc = "cfrel.relation";
		</cfscript>
	</cffunction>
	
	<cffunction name="testInit" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.obj = new(init=false);
			loc.varCount1 = StructCount(loc.obj._inspect());
			loc.instance = loc.obj.init();
			loc.varCount2 = StructCount(loc.instance._inspect());
			
			// make sure init modifies instance, not creating a new one
			assertIsTypeOf(loc.instance, "cfrel.relation");
			assertSame(loc.obj, loc.instance, "init() should return same instance");
			assertTrue(loc.varCount2 GT loc.varCount1, "init() should define private variables");
		</cfscript>
	</cffunction>
	
	<cffunction name="testNew" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.factory = new(init=false);
			loc.instance = loc.factory.new();
			assertIsTypeOf(loc.instance, "cfrel.relation");
			assertNotSame(loc.instance, loc.factory, "new() should create a new instance");
		</cfscript>
	</cffunction>
	
	<cffunction name="testClone" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.clone = loc.instance.clone();
			
			// make sure that call returns a different relation object
			assertIsTypeOf(loc.clone, "cfrel.relation");
			assertNotSame(loc.clone, loc.instance, "clone() should return copy of object, not same one")
		</cfscript>
	</cffunction>
	
	<cffunction name="testCallsAreChainable" returntype="void" access="public">
		<cfscript>
			var instance = new();
			var key = "";
			var loc = {};
			
			// call each of the basic chainable methods
			loc.select = instance.select("a");
			loc.distinct = instance.distinct();
			loc.from = instance.from("users")
			loc.include = instance.include();
			loc.join = instance.join();
			loc.where = instance.where(a=5);
			loc.group = instance.group("a");
			loc.having = instance.having("a > ?", [0]);
			loc.order = instance.order("a ASC");
			loc.limit = instance.limit(5);
			loc.offset = instance.offset(10);
			loc.paginate = instance.paginate(1, 5);
			
			// chain each call together for further testing
			loc.multiple = instance.select("b").distinct().from("posts").include().join().where(b=10).group("b").having("b >= 10").order("b DESC").limit(2).offset(8).paginate(3, 10);
			
			// assert that each return is still the same object
			for (key in loc)
				assertSame(instance, loc[key]);
		</cfscript>
	</cffunction>
	
	<cffunction name="testSelectSyntax" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance1 = new();
			loc.instance2 = new();
			loc.instance3 = new();
			loc.testVal = ListToArray("a,b,c");
			
			// run SELECT in various ways
			loc.instance1.select("*");
			loc.instance2.select("a,b,c");
			loc.instance3.select("a","b","c");
			
			// make sure the items were added
			loc.select1 = loc.instance1._inspect().sql.select;
			loc.select2 = loc.instance2._inspect().sql.select;
			loc.select3 = loc.instance3._inspect().sql.select;
			assertEquals(["*"], loc.select1, "SELECT clause should accept '*'");
			assertEquals(loc.testVal, loc.select2, "SELECT clause should accept a list of columns");
			assertEquals(loc.testVal, loc.select3, "SELECT clause should accept a columns as multiple arguments");
		</cfscript>
	</cffunction>
	
	<cffunction name="testSelectAppend" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			
			// run chained selects to confirm appending with both syntaxes
			loc.instance.select("a,b").select("c","d").select("e,f");
			
			// make sure items were stacked/appended
			loc.select = loc.instance._inspect().sql.select;
			assertEquals(ListToArray("a,b,c,d,e,f"), loc.select, "SELECT should append additional selects");
		</cfscript>
	</cffunction>
	
	<cffunction name="testEmptySelect" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			loc.instance = new();
			
			// confirm that exception is thrown
			try {
				loc.instance.select();
			} catch (Any e) {
				loc.pass = true;
			}
			
			assertTrue(loc.pass, "Empty parameters to SELECT should throw an error");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDistinct" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new().distinct().distinct(); // yes, call twice
			loc.flags = loc.instance._inspect().sql.selectFlags;
			assertEquals("DISTINCT", loc.flags[1], "distinct() should set DISTINCT flag");
			assertEquals(1, ArrayLen(loc.flags), "DISTINCT should only be set once");
		</cfscript>
	</cffunction>
	
	<cffunction name="testEmptyFrom" returntype="void" access="public">
		<cfscript>
			assertFalse(StructKeyExists(new()._inspect().sql, "from"), "FROM clause should not be set initially");
		</cfscript>
	</cffunction>
	
	<cffunction name="testFromWithString" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			
			loc.instance.from("users");
			assertEquals("users", loc.instance._inspect().sql.from, "FROM clause should be set to passed value");
		</cfscript>
	</cffunction>
	
	<cffunction name="testFromWithRelation" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance2 = new().from(loc.instance);
			assertSame(loc.instance, loc.instance2._inspect().sql.from, "FROM clause should be set to passed relation");
		</cfscript>
	</cffunction>
	
	<cffunction name="testFromWithInvalidObject" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			try {
				new().from(StructNew());
			} catch (custom_type e) {
				loc.pass = true;
			}
			assertTrue(loc.pass, "from() should throw exception when given invalid object");
		</cfscript>
	</cffunction>
	
	<cffunction name="testSingleWhere" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.where("1 = 1");
			loc.sql = loc.instance._inspect().sql;
			assertEquals(1, ArrayLen(loc.sql.wheres), "where() should only set one condition");
			assertEquals(0, ArrayLen(loc.sql.whereParameters), "where() should not set any parameters");
			assertEquals("1 = 1", loc.sql.wheres[1], "where() should append the correct condition");
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppendWhere" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.where("1 = 1").where("2 = 2");
			assertEquals("2 = 2", loc.instance._inspect().sql.wheres[2], "where() should append the second condition");
		</cfscript>
	</cffunction>
	
	<cffunction name="testWhereWithParameters" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.whereClause = "id = ? OR name = '?' OR role IN ?";
			loc.whereParameters = [50, "admin", [1,2,3]];
			loc.instance = new();
			loc.instance.where(loc.whereClause, loc.whereParameters);
			loc.sql = loc.instance._inspect().sql;
			assertEquals(loc.whereClause, loc.sql.wheres[1], "where() should set the passed condition");
			assertEquals(loc.whereParameters, loc.sql.whereParameters, "where() should set parameters in correct order");
		</cfscript>
	</cffunction>
	
	<cffunction name="testWhereParameterCount" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			loc.instance = new();
			try {
				loc.instance.where("id = ? OR name = '?'", [2]);
			} catch (custom_type e) {
				loc.pass = true;
			}
			assertTrue(loc.pass, "where() should throw an error if wrong count of parameters is passed");
		</cfscript>
	</cffunction>
	
	<cffunction name="testWhereWithNamedArguments" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new().where(a=45, b="BBB", c=[1,2,3]);
			loc.sql = loc.instance._inspect().sql;
			assertEquals(["a = ?", "b = ?", "c IN ?"], loc.sql.wheres, "Named arguments should be in WHERE clause");
			assertEquals([45, "BBB", [1,2,3]], loc.sql.whereParameters, "Parameters should be set and in correct order");
		</cfscript>
	</cffunction>
	
	<cffunction name="testGroupSyntax" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance1 = new();
			loc.instance2 = new();
			loc.testVal = ListToArray("a,b,c");
			
			// run GROUP in various ways
			loc.instance1.group("a,b,c");
			loc.instance2.group("a","b","c");
			
			// make sure the items were added
			loc.groups1 = loc.instance1._inspect().sql.groups;
			loc.groups2 = loc.instance2._inspect().sql.groups;
			assertEquals(loc.testVal, loc.groups1, "GROUP BY clause should accept a list of columns");
			assertEquals(loc.testVal, loc.groups2, "GROUP BY clause should accept a columns as multiple arguments");
		</cfscript>
	</cffunction>
	
	<cffunction name="testGroupAppend" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			
			// run chained groups to confirm appending with both syntaxes
			loc.instance.group("a,b").group("c","d").group("e,f");
			
			// make sure items were stacked/appended
			loc.groups = loc.instance._inspect().sql.groups;
			assertEquals(ListToArray("a,b,c,d,e,f"), loc.groups, "GROUP should append additional fields");
		</cfscript>
	</cffunction>
	
	<cffunction name="testEmptyGroup" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			loc.instance = new();
			
			// confirm that exception is thrown
			try {
				loc.instance.group();
			} catch (Any e) {
				loc.pass = true;
			}
			
			assertTrue(loc.pass, "Empty parameters to GROUP should throw an error");
		</cfscript>
	</cffunction>
	
	<cffunction name="testSingleHaving" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.having("a > 1");
			loc.sql = loc.instance._inspect().sql;
			assertEquals(1, ArrayLen(loc.sql.havings), "having() should only set one condition");
			assertEquals(0, ArrayLen(loc.sql.havingParameters), "having() should not set any parameters");
			assertEquals("a > 1", loc.sql.havings[1], "having() should append the correct condition");
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppendHaving" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.having("a > 1").having("b < 0");
			assertEquals("b < 0", loc.instance._inspect().sql.havings[2], "having() should append the second condition");
		</cfscript>
	</cffunction>
	
	<cffunction name="testHavingWithParameters" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.havingClause = "id = ? OR name = '?' OR role IN ?";
			loc.havingParameters = [50, "admin", [1,2,3]];
			loc.instance = new();
			loc.instance.having(loc.havingClause, loc.havingParameters);
			loc.sql = loc.instance._inspect().sql;
			assertEquals(loc.havingClause, loc.sql.havings[1], "having() should set the passed condition");
			assertEquals(loc.havingParameters, loc.sql.havingParameters, "having() should set parameters in correct order");
		</cfscript>
	</cffunction>
	
	<cffunction name="testHavingParameterCount" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			loc.instance = new();
			try {
				loc.instance.having("id = ? OR name = '?'", [2]);
			} catch (custom_type e) {
				loc.pass = true;
			}
			assertTrue(loc.pass, "having() should throw an error if wrong count of parameters is passed");
		</cfscript>
	</cffunction>
	
	<cffunction name="testHavingWithNamedArguments" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new().having(a=45, b="BBB", c=[1,2,3]);
			loc.sql = loc.instance._inspect().sql;
			assertEquals(["a = ?", "b = ?", "c IN ?"], loc.sql.havings, "Named arguments should be in HAVING clause");
			assertEquals([45, "BBB", [1,2,3]], loc.sql.havingParameters, "Parameters should be set and in correct order");
		</cfscript>
	</cffunction>
	
	<cffunction name="testOrderSyntax" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance1 = new();
			loc.instance2 = new();
			loc.testVal = ListToArray("a ASC,b DESC,c");
			
			// run ORDER in various ways
			loc.instance1.order("a ASC,b DESC,c");
			loc.instance2.order("a ASC","b DESC","c");
			
			// make sure the items were added
			loc.orders1 = loc.instance1._inspect().sql.orders;
			loc.orders2 = loc.instance2._inspect().sql.orders;
			assertEquals(loc.testVal, loc.orders1, "ORDER BY clause should accept a list of columns");
			assertEquals(loc.testVal, loc.orders2, "ORDER BY clause should accept a columns as multiple arguments");
		</cfscript>
	</cffunction>
	
	<cffunction name="testOrderAppend" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			
			// run chained orders to confirm appending with both syntaxes
			loc.instance.order("a,b").order("c","d").order("e,f");
			
			// make sure items were stacked/appended
			loc.orders = loc.instance._inspect().sql.orders;
			assertEquals(ListToArray("a,b,c,d,e,f"), loc.orders, "ORDER should append additional fields");
		</cfscript>
	</cffunction>
	
	<cffunction name="testEmptyOrder" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.pass = false;
			loc.instance = new();
			
			// confirm that exception is thrown
			try {
				loc.instance.order();
			} catch (Any e) {
				loc.pass = true;
			}
			
			assertTrue(loc.pass, "Empty parameters to ORDER should throw an error");
		</cfscript>
	</cffunction>
	
	<cffunction name="testLimit" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.limit(31);
			loc.sql = loc.instance._inspect().sql;
			assertTrue(StructKeyExists(loc.sql, "limit"), "LIMIT should be set in SQL");
			assertEquals(31, loc.sql.limit, "LIMIT should be equal to value set");
		</cfscript>
	</cffunction>
	
	<cffunction name="testOffset" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.instance.offset(15);
			loc.sql = loc.instance._inspect().sql;
			assertTrue(StructKeyExists(loc.sql, "offset"), "OFFSET should be set in SQL");
			assertEquals(15, loc.sql.offset, "OFFSET should be equal to value set");
		</cfscript>
	</cffunction>
	
	<cffunction name="testSqlGeneration" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.visitor = CreateObject("component", "cfrel.visitors.sql");
			
			// generate a simple relation
			loc.instance = new().select("a").from("b").where("a > 5").order("a ASC").paginate(2, 15);
			
			// make sure visitor is being called
			assertEquals(loc.visitor.visit(loc.instance), loc.instance.toSql(), "toSql() should be calling Sql visitor for SQL generation");
		</cfscript>
	</cffunction>
	
	<cffunction name="testPaginateSyntax" returntype="void" access="public">
		<cfscript>
			var loc = {};
			
			// an example: 5th page of 10 per page
			loc.instance = new();
			loc.instance.paginate(5, 10);
			loc.sql = loc.instance._inspect().sql;
			
			// make sure proper values were set in LIMIT and OFFSET clauses
			assertTrue(StructKeyExists(loc.sql, "limit"), "LIMIT should be set in SQL");
			assertTrue(StructKeyExists(loc.sql, "offset"), "OFFSET should be set in SQL");
			assertEquals(10, loc.sql.limit, "LIMIT should be equal to value set");
			assertEquals(40, loc.sql.offset, "OFFSET should equal (page - 1) * per-page");
		</cfscript>
	</cffunction>
	
	<cffunction name="testPaginateBounds" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.instance = new();
			loc.pass1 = false;
			loc.pass2 = false;
			
			// test <1 value for page
			try {
				loc.instance.paginate(0, 5);
			} catch (Any e) {
				loc.pass1 = true;
			}
			
			// test <1 value for perPage
			try {
				loc.instance.paginate(1, 0);
			} catch (Any e) {
				loc.pass2 = true;
			}
			
			// make sure errors are thrown
			assertTrue(loc.pass1, "paginate() should throw error when page < 1");
			assertTrue(loc.pass1, "paginate() should throw error when perPage < 1");
		</cfscript>
	</cffunction>
</cfcomponent>