({
	doInitialize: function(component, event, helper) {
        var factMap = component.get('v.factMap');

        if (factMap) {
			var groupingKey = component.get("v.groupingKey");
            component.set("v.aggRows", factMap[groupingKey+"!T"].aggregates);
        }
	}
})