<cfcomponent extends="tests.TestCase" output="false">
	
	<cffunction name="setup" returntype="void" access="public">
		<cfscript>
			super.setup();
			variables.cfc = "cfrel.visitors.Sql";
		</cfscript>
	</cffunction>
	
	<cffunction name="testVisitRelation" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.sql = new();
			loc.factory = CreateObject("component", "cfrel.Relation");
			
			// build a variety of queries
			loc.rel1 = loc.factory.new().select("1 + 2", 3, 4).distinct();
			loc.args = [0];
			loc.rel2 = loc.factory.new().select("a, SUM(b)").from("example").group("a").having("SUM(b) > ?", loc.args);
			loc.rel3 = loc.factory.new().from("example").where("c > 5 OR c < 2").where(a=5).order("c ASC");
			loc.rel4 = loc.factory.new().from("example").order("a DESC").paginate(7, 10);
			loc.args = [10];
			loc.rel5 = loc.factory.new().from(loc.rel4).where("b > ?", loc.args);
			loc.rel6 = loc.factory.new().from(QueryNew(''));
			
			// set expected values
			loc.exp1 = "SELECT DISTINCT 1 + 2, 3, 4";
			loc.exp2 = "SELECT a, SUM(b) FROM example GROUP BY a HAVING SUM(b) > ?";
			loc.exp3 = "SELECT * FROM example WHERE (c > 5 OR c < 2) AND a = ? ORDER BY c ASC";
			loc.exp4 = "SELECT * FROM example ORDER BY a DESC LIMIT 10 OFFSET 60";
			loc.exp5 = "SELECT * FROM (#loc.exp4#) subquery WHERE b > ?";
			loc.exp6 = "SELECT * FROM resultSet";
			
			// test each value
			for (loc.i = 1; loc.i LTE 6; loc.i++)
				assertEquals(loc["exp#loc.i#"], loc.sql.visit(loc["rel#loc.i#"]));
		</cfscript>
	</cffunction>
	
	<cffunction name="testVisitSimple" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.visitor = new();
			assertEquals(5, loc.visitor.visit(5));
			assertEquals("boo", loc.visitor.visit("boo"));
			assertEquals(true, loc.visitor.visit(true));
			assertEquals(Now(), loc.visitor.visit(Now()));
		</cfscript>
	</cffunction>
	
	<cffunction name="testVisitArray" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.visitor = new();
			loc.rel = new("cfrel.Relation").select(1).from("a");
			loc.input = [5, "a", sqlLiteral("b"), loc.rel];
			loc.output = [5, "a", "b", "SELECT 1 FROM a"];
			assertEquals(loc.output, loc.visitor.visit(loc.input));
		</cfscript>
	</cffunction>
	
	<cffunction name="testVisitNodesLiteral" returntype="void" access="public">
		<cfscript>
			var loc = {};
			loc.sql = new();
			assertEquals("SELECT 1", loc.sql.visit(sqlLiteral("SELECT 1")), "visit_literal() should just retain plain text contents");
		</cfscript>
	</cffunction>
</cfcomponent>