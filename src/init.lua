--!optimize 2
--!strict
local LuauPolyfill = require(script.Parent.LuauPolyfill)
local ReactRoblox = require(script.Parent.ReactRoblox)

local TypeChecks = require(script:FindFirstChild("TypeChecks"))
local WarnOnce = require(script:FindFirstChild("WarnOnce"))

local inspect = LuauPolyfill.util.inspect

--[=[
	A utility library that allows Roact styled mounting and unmounting for React.

	@class ReactTree
]=]
local ReactTree = {}

--[=[
	Whether or not to perform strict validation on the React tree.
	@prop StrictValidation boolean
	@within ReactTree
]=]
ReactTree.StrictValidation = false

--[=[
	This is what is returned when you call [ReactTree.mount], and it
	is used for unmounting with [ReactTree.unmount].

	@interface IReactHandle
	.key number | string -- The key of the element.
	.parent Instance? -- The parent of the element.
	.root any -- The root of the element. This is the return result of `React.createElement`.
	@within ReactTree
]=]
export type IReactHandle = {
	key: number | string,
	parent: Instance?,
	root: any,
}

--[=[
	Used to mount a React element into the Roblox instance tree.

	Creates a Roblox Instance given a Roact element, and optionally a
	`parent` to put it in, and a `key` to use as the instance's `Name`.

	The return result is an [IReactHandle], which can be used to unmount
	the element later using [ReactTree.unmount].

	@param element any -- The React element to mount. This is the return result of `React.createElement`.
	@param parent? Instance -- Where you want to mount the tree to.
	@param key? string -- The key of the element. Essentially just [Instance.Name].
	@return IReactHandle -- The handle to the mounted element.
]=]
function ReactTree.mount(element: any, parent: Instance?, key: string?): IReactHandle
	if ReactTree.StrictValidation then
		assert(TypeChecks.MountTuple(element, parent, key))
	end

	if parent and typeof(parent) ~= "Instance" then
		error(
			string.format(
				"Cannot mount element (`%*`) into a parent that is not a Roblox Instance (got type `%*`) \n%*",
				if element then tostring(element.type) else "<unknown>",
				typeof(parent),
				if parent ~= nil then inspect(parent) else ""
			)
		)
	end

	local root
	if _G.__ROACT_17_COMPAT_LEGACY_ROOT__ then
		root = ReactRoblox.createLegacyRoot(Instance.new("Folder"))
	else
		root = ReactRoblox.createRoot(Instance.new("Folder"))
	end

	local trueParent: Instance
	if parent == nil then
		trueParent = Instance.new("Folder")
		trueParent.Name = "Target"
	else
		trueParent = parent
	end

	if key == nil then
		if _G.__ROACT_17_COMPAT_LEGACY_ROOT__ then
			key = "ReactLegacyRoot"
		else
			key = "ReactRoot"
		end
	end

	if _G.__ROACT_17_INLINE_ACT__ then
		ReactRoblox.act(function()
			root:render(ReactRoblox.createPortal({[key] = element}, trueParent))
		end)
	else
		root:render(ReactRoblox.createPortal({[key] = element}, trueParent))
	end

	return {
		root = root,
		-- To preserve the same key and portal to the same parent on update, we
		-- need to stash them in the opaque "tree" reference returned by `mount`
		parent = trueParent,
		key = key :: string,
	}
end

--[=[
	Unmounts an element that was mounted with [ReactTree.mount].

	@param reactHandle IReactHandle -- The handle to unmount.
]=]
function ReactTree.unmount(reactHandle: IReactHandle)
	if ReactTree.StrictValidation then
		assert(TypeChecks.IsReactHandle(reactHandle))
	end

	if _G.__ROACT_17_INLINE_ACT__ then
		ReactRoblox.act(function()
			reactHandle.root:unmount()
		end)
	else
		reactHandle.root:unmount()
	end
end

--[=[
	Updates an existing instance handle with a new element, returning
	the same handle. This can be used to update a UI created with
	[ReactTree.mount] by passing in a new element with new props.

	:::warning
	This is really not recommended to use, it's extremely slow
	and can cause major performance issues. Find a better way
	to handle your trees.
	:::

	@param reactHandle IReactHandle -- The handle to update.
	@param element any -- The new element to update the handle with. This is the return result of `React.createElement`.
	@return IReactHandle -- The same handle that was passed in.
]=]
function ReactTree.update(reactHandle: IReactHandle, element: any)
	if ReactTree.StrictValidation then
		assert(TypeChecks.UpdateTuple(reactHandle, element))
	end

	if _G.__DEV__ then
		WarnOnce(
			"ReactTree.update",
			"You shouldn't really be using ReactTree.update, find a better way to handle your trees."
		)
	end

	local key = reactHandle.key
	local parent = reactHandle.parent

	if _G.__ROACT_17_INLINE_ACT__ then
		ReactRoblox.act(function()
			reactHandle.root:render(ReactRoblox.createPortal({[key :: string] = element}, parent))
		end)
	else
		reactHandle.root:render(ReactRoblox.createPortal({[key :: string] = element}, parent))
	end

	return reactHandle
end

ReactTree.reconcile = ReactTree.update
ReactTree.reify = ReactTree.mount
ReactTree.teardown = ReactTree.unmount

return ReactTree
