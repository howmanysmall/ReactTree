--!optimize 2
--!strict
local t = require(script.Parent.Parent.t)

local TypeChecks = {}

TypeChecks.IsReactHandle = t.strictInterface({
	key = t.union(t.number, t.string);
	parent = t.optional(t.Instance);
	root = t.table;
})

TypeChecks.MountTuple = t.tuple(t.table, t.optional(t.Instance), t.optional(t.string))
TypeChecks.UpdateTuple = t.tuple(TypeChecks.IsReactHandle, t.table)

table.freeze(TypeChecks)
return TypeChecks
