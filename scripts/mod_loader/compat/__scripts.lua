local scripts = {
	"sdlext",
	"modApi",
	"event",
	"asserts",
	"dialog_helper"
}

local rootpath = GetParentPath(...)
for i, filepath in ipairs(scripts) do
	require(rootpath..filepath)
end
